import argparse
import json
import re
import requests
import subprocess
from pathlib import Path
from packaging.version import parse as parse_version
from urllib.parse import urlparse


# --- Files to read/write ---
JSON_FILE = Path("cmake/libraries.json")
CMAKE_FILE = Path("CMakeLists.txt")
CMAKE_FILE_NINJA = Path("ninja/CMakeLists.txt")
CMAKE_FILE_MOLD = Path("mold/CMakeLists.txt")
DCS2_FILE = Path("dcs2.sh")


# --- Functions ---
def normalize_version(tag):
    """
    Extracts a semantic version (x.y.z or w.x.y.z) from tags like:
    'v7.7.0', 'release-14-4-0', '3-12-1', '4_14_0'
    Falls back to the raw tag if no match.
    """
    # Try to find a 4-digit version first
    match_4 = re.search(r'(\d+)[_.\-](\d+)[_.\-](\d+)[_.\-](\d+)', tag)
    if match_4:
        return ".".join(match_4.groups())

    # Fallback to 3-digit version
    match_3 = re.search(r'(\d+)[_.\-](\d+)[_.\-](\d+)', tag)
    if match_3:
        return ".".join(match_3.groups())
    
    # Fallback to original tag if no recognizable pattern
    return tag  


def is_valid_tag(tag):
    # Reject tags with pre-release or experimental markers even if attached
    blacklist = ["rc", "alpha", "beta", "preview", "test", "sample", "dev", "debug"]
    tag_lower = tag.lower()
    
    if any(re.search(rf'\b{marker}\d*\b', tag_lower) or re.search(rf'\b{marker}\b', tag_lower) for marker in blacklist):
        return False

    return bool(re.search(r'(\d+)[_.\-](\d+)[_.\-](\d+)([_.\-](\d+))?$', tag))


def get_latest_release_tag(package_name, host):
    if "github" in host:
        try:
            # Find latest release
            url = f"https://api.github.com/repos/{package_name}/releases/latest"
            response = requests.get(url)
            response.raise_for_status()
            data = response.json()
            return data["tag_name"]

        except requests.HTTPError as e:
            # Search the tag for a version number
            if e.response.status_code == 404:
                url = f"https://api.github.com/repos/{package_name}/tags"
                response = requests.get(url)
                response.raise_for_status()
                data = response.json()
                if not data:
                    raise RuntimeError("No tags found for {package_name}.")

                # Search for the most recent tag, that looks like a version number
                for tag in data:
                    name = tag["name"]
                    if is_valid_tag(name):
                        return name
                raise ValueError("No valid release-like tags found.")
            raise

    elif "gitlab" in host:
        # Find latest release
        encoded_package_name = package_name.replace("/", "%2F")
        url = f"https://{host}/api/v4/projects/{encoded_package_name}/releases"
        response = requests.get(url)
        response.raise_for_status()
        data = response.json()

        # Search the tag for a version number instead
        if not data:
            url = f"https://{host}/api/v4/projects/{encoded_package_name}/repository/tags"
            response = requests.get(url)
            response.raise_for_status()
            data = response.json()

            # Search for the most recent tag, that looks like a version number
            for tag in data:
                name = tag["name"]
                if is_valid_tag(name):
                    return name
            raise ValueError("No valid release-like tags found.")

        else:
            # Return the most recent release:
            return data[0]["tag_name"]

        # Test if we found a tag.
        if not data:
            raise ValueError("No GitLab releases found.")

    else:
        raise NotImplementedError(f"Unsupported host: {host}")


def get_current_max_version(database):
    versions = [
        v for v in database.keys()
        if v != "git" and not v.startswith("_")  # ignore metadata fields
        and isinstance(database[v], dict)
        and re.match(r'^\d+(\.\d+){1,3}$', v)  # matches x.x or x.x.x or x.x.x.x
    ]
    return max(versions, key=parse_version) if versions else None


def update_json(database, package_name, package_url, package_tag, cmake_tag, dry_run=False):
    database[package_name][cmake_tag] = {"tag": package_tag}

    if dry_run:
        print(f"[Dry Run] Would updated {package_name} entry in {JSON_FILE}, by adding the new tag {cmake_tag} (with tag: {package_tag}).")
    else:
        with open(JSON_FILE, "w") as f:
            json.dump(database, f, indent=2)
        print(f"Updated {package_name} entry in {JSON_FILE}, by adding the new tag {cmake_tag} (with tag: {package_tag}).")


def update_cmake(cmake_name, package_tag, package, cmake_file, dry_run=False):
    version_pattern = re.compile(
        rf'set\({re.escape(cmake_name)}\s+"[^"]*"\s+CACHE STRING ".*?"\)'
    )
    content = cmake_file.read_text()
    new_line = f'set({cmake_name} "{package_tag}" CACHE STRING "Specify the version of {package.upper()} to be used")'
    updated = version_pattern.sub(new_line, content)

    if dry_run:
        print(f"[Dry Run] Would update {cmake_name} in {cmake_file} (with tag: {package_tag}).")
    else:
        cmake_file.write_text(updated)
        print(f"Updated {cmake_name} in {cmake_file} (with tag: {package_tag}).")


def update_bash(package_tag, package_name, dcs2_file, dry_run=False):
    if not dcs2_file.exists():
        raise FileNotFoundError(f"{dcs2_file} not found")

    version_pattern = re.compile(
        rf'{re.escape(package_name)}=[^\n]+'
    )
    content = dcs2_file.read_text()
    new_line = f'{package_name}={package_tag}'
    updated = version_pattern.sub(new_line, content)

    if dry_run:
        print(f"[Dry Run] Would update {package_name} in {dcs2_file} (with tag: {package_tag}).")
    else:
        dcs2_file.write_text(updated)
        print(f"Updated {package_name} in {dcs2_file} (with tag: {package_tag}).")



def print_git_diff():
    result = subprocess.run(["git", "diff", "--stat"], capture_output=True, text=True)
    print("Git diff summary:")
    print(result.stdout)


# --- Stitch everything together into the update package method ---
def update_package(database, package, parent_name="", dry_run=False):
    if parent_name == "":
        cmake_name = f"{package.upper()}_VERSION"
    else:
        cmake_name = f"{parent_name.upper()}_{package.upper()}_VERSION"

    try:
        if package not in database:
            if parent_name == "":
                print(f"Error: Unknown package '{package}'")
            else:
                print(f"Error: Unknown package '{parent_name}-{package}'")
            return

        if "git" not in database[package]:
            if parent_name == "":
                raise ValueError(f"Invalid entry for '{package}' in {JSON_FILE}")
            else:
                raise ValueError(f"Invalid entry for '{parent_name}-{package}' in {JSON_FILE}")

        # Parse the url
        package_url = database[package]["git"]
        package_url_parsed = urlparse(package_url)
        package_host = package_url_parsed.hostname
        package_path = package_url_parsed.path.lstrip("/").removesuffix(".git")

        latest_tag = get_latest_release_tag(package_path, package_host)
        cmake_tag = normalize_version(latest_tag)
        current_version = get_current_max_version(database[package])

        if current_version and parse_version(cmake_tag) <= parse_version(current_version):
            print(f"{parent_name} {package} is already up to date (current version: {cmake_tag}). Nothing to do.")
            return 0 # this is not an error return code, we use this to count the number of updated packages

        update_json(database, package, package_url, latest_tag, cmake_tag, dry_run)

        if "cmake" in package:
            update_bash(cmake_tag, "CMAKE_VERSION", DCS2_FILE, dry_run)
        elif "ninja" in package:
            update_cmake(cmake_name, cmake_tag, package, CMAKE_FILE_NINJA, dry_run)
        elif "mold" in package:
            update_cmake(cmake_name, cmake_tag, package, CMAKE_FILE_MOLD, dry_run)
            update_bash(cmake_tag, "MOLD_VERSION", DCS2_FILE, dry_run)
        else:
            update_cmake(cmake_name, cmake_tag, package, CMAKE_FILE, dry_run)
        return 1 # this is not an error return code, we use this to count the number of updated packages

    except Exception as e:
        print(f"Failed to update {package}: {e}")
        return 0 # this is not an error return code, we use this to count the number of updated packages


# --- Main function ---
def main():
    # Parse the input parameter:
    parser = argparse.ArgumentParser(description="Update dependency version from latest GitHub release")
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("--package", help="Package name to update")
    group.add_argument("--all", action="store_true", help="Update all packages")
    parser.add_argument("--dry-run", action="store_true", help="Preview changes without writing them")
    args = parser.parse_args()

    # Check if the CMakeLists.txt exists
    if not CMAKE_FILE.exists():
        print(f"Could not find the CMakeLists.txt: '{CMAKE_FILE}'")
        return

    # Read the database and perform some basic sanity checks:
    database = {}
    if JSON_FILE.exists():
        with open(JSON_FILE, "r") as f:
            database = json.load(f)
    else:
        print(f"Could not find the database: '{JSON_FILE}'")
        return

    package_counter = 0
    update_counter = 0
    if args.all:
        for package, info in database.items():
            if package == "meta" or not isinstance(info, dict):
                continue    

            # Detect nested groups like 'amd'
            if "git" not in info:
                for subpkg, subdatabase in database[package].items():
                    if isinstance(subdatabase, dict) and "git" in subdatabase:
                        print(f"-> {package}/{subpkg}:")
                        update_counter += update_package(database[package], subpkg.lower(), package, dry_run=args.dry_run)
                        package_counter += 1
                        print(f"\n")
            else:
                # update the package:
                print(f"-> {package}:")
                update_counter += update_package(database, package.lower(), "", dry_run=args.dry_run)
                package_counter += 1
                print(f"\n")
        
        print("Summary:")
        print(f"{update_counter} out of {package_counter} packages were updated.")

    else:
        # Get the package name we want to update in all lower case (so the input is case insensitive)
        update_package(database, args.package.lower(), dry_run=args.dry_run)


    if not args.dry_run:
        print_git_diff()


if __name__ == "__main__":
    main()

