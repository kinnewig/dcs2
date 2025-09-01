import curses
import os
import re
import subprocess
from packaging import version as v

def tpls_read_from_cmake(file_path):
    pattern = re.compile(r'option\(\s*(TPL_ENABLE_\w+)\s*"([^"]*)"\s*(ON|OFF)\s*\)')
    tpls = []

    with open(file_path, 'r') as f:
        for line in f:
            match = pattern.search(line)
            if match:
                name, description, enabled = match.groups()
                tpls.append({
                    "name": name,
                    "description": description,
                    "enabled": enabled == "ON"
                })

    return tpls 



def tpls_tui_select(tpls):
    curses.curs_set(0)
    current = 0

    # Precompute the max width of the name field for alignment
    name_width     = max(len(opt["name"].removeprefix("TPL_ENABLE_")) for opt in tpls)
    desc_start_col = name_width + 4 + 1  # +4 for "[x] " or "[ ] " and +1 for spacing

    while True:
        stdscr = curses.initscr()
        stdscr.clear()
        stdscr.addstr(0, 0, "Select TPL packages (space to toggle, enter to confirm:")

        for idx, opt in enumerate(tpls):
            mark = "[x]" if opt["enabled"] else "[ ]"
            name = opt["name"].removeprefix("TPL_ENABLE_")
            line = f"{mark} {name}"
            if "description" in opt:
                line = line.ljust(desc_start_col) + f"- {opt['description']}"
            if idx == current:
                stdscr.addstr(idx + 2, 0, line, curses.A_REVERSE)
            else:
                stdscr.addstr(idx + 2, 0, line)

        key = stdscr.getch()
        if key == curses.KEY_UP and current > 0:
            current -= 1
        elif key == curses.KEY_DOWN and current < len(tpls) - 1:
            current += 1
        elif key == ord(" "):
            tpls[current]["enabled"] = not tpls[current]["enabled"]
        elif key == ord("\n"):
            break

    return tpls

 

def tpls_update_cmake(tpls, file_path="CMakeLists.txt"):
    # Create a lookup dictionary keyed by full name
    tpl_lookup = {tpl["name"]: tpl for tpl in tpls}

    pattern = re.compile(r'option\(\s*(TPL_ENABLE_\w+)\s*"([^"]*)"\s*(ON|OFF)\s*\)')

    updated_lines = []

    with open(file_path, "r") as f:
        lines = f.readlines()

    for line in lines:
        match = pattern.search(line)
        if match:
            name, old_description, old_status = match.groups()
            if name in tpl_lookup:
                tpl = tpl_lookup[name]
                new_status = "ON" if tpl["enabled"] else "OFF"
                new_description = tpl["description"]
                line = f'option({name} "{new_description}" {new_status})\n'
        updated_lines.append(line)

    with open(file_path, "w") as f:
        f.writelines(updated_lines)



def program_available(program, env, min_version="0.0.0"):
    try:
        output = subprocess.check_output([f"{program}", "--version"], stderr=subprocess.STDOUT, env=env)
        line = output.decode().splitlines()[0]

        if v.parse(line.split()[-1]) >= v.parse(min_version):
            return True 
        else:
            return False
    except Exception:
        return False



def tui_read_path(default_path, instructions):
    stdscr = curses.initscr()
    curses.curs_set(1)
    prefix = os.path.expanduser(default_path)
    max_y, max_x = stdscr.getmaxyx()

    input_y = 2

    while True:
        stdscr.clear()
        stdscr.addstr(0, 0, instructions, curses.A_BOLD)
        stdscr.addstr(input_y, 0, prefix, curses.A_REVERSE)
        stdscr.refresh()

        key = stdscr.getch()

        if key in (curses.KEY_ENTER, ord("\n")):
            break
        elif key in (curses.KEY_BACKSPACE, 127):
            prefix = prefix[:-1]
        elif key == 27:  # ESC
            prefix = None
            break
        elif 32 <= key <= 126:
            prefix += chr(key)

    curses.curs_set(0)
    return prefix



def tui_install_tools():
    stdscr = curses.initscr()
    curses.curs_set(0)
    modes = ["download", "ON", "OFF"]  # Order matters for toggling
    tools = [
        {"name": "mold", "mode": "download"},
        {"name": "ninja", "mode": "download"}
    ]
    current = 0

    instructions = "Choose which build tools to use: (space to cycle: Download →  ON (build from source) →  OFF, Enter to confirm):"

    while True:
        stdscr.clear()
        stdscr.addstr(0, 0, instructions, curses.A_BOLD)

        for idx, tool in enumerate(tools):
            line = f"[{tool['mode']:^8}] {tool['name']} (recommended)"
            if idx == current:
                stdscr.addstr(idx + 2, 0, line, curses.A_REVERSE)
            else:
                stdscr.addstr(idx + 2, 0, line)

        stdscr.refresh()
        key = stdscr.getch()

        if key == curses.KEY_UP and current > 0:
            current -= 1
        elif key == curses.KEY_DOWN and current < len(tools) - 1:
            current += 1
        elif key == ord(" "):
            # Cycle through modes
            current_mode = tools[current]["mode"]
            next_index = (modes.index(current_mode) + 1) % len(modes)
            tools[current]["mode"] = modes[next_index]
        elif key == ord("\n"):
            break

    return {tool["name"]: tool["mode"] for tool in tools}



if __name__ == "__main__":
    # === Package selection ===
    # Read the TPLs from the CMakeLists.txt
    tpls = tpls_read_from_cmake("CMakeLists.txt")

    # These TPLs are handeled by the BLAS stack option
    excluded_tpls = {"TPL_ENABLE_BLIS", "TPL_ENABLE_LIBFLAME", "TPL_ENABLE_SCALAPACK"}
    filtered_tpls = [tpl for tpl in tpls if tpl["name"] not in excluded_tpls]

    # Let the user select
    selected_tpls = curses.wrapper(lambda stdscr: tpls_tui_select(filtered_tpls))

    # Write the changes to the CMakeLists.txt
    tpls_update_cmake(selected_tpls, "CMakeLists.txt")

    dcs2_args = []
    instructions = "Please enter the path where to install deal.II (Enter to confirm, ESC to cancel):"
    prefix = curses.wrapper(lambda stdscr: tui_read_path("~/dcs2", instructions))

    instructions = "Please enter the path where to store the temporarie build files (Enter to confirm, ESC to cancel):"
    build = curses.wrapper(lambda stdscr: tui_read_path("~/dcs2/tmp", instructions))
    dcs2_args.append(f"--build {build}")

    instructions = "Please enter the path where to store binary files (Enter to confirm, ESC to cancel):"
    bin_dir = curses.wrapper(lambda stdscr: tui_read_path("~/dcs2/bin", instructions))
    dcs2_args.append(f"--bin-dir {bin_dir}")

    # Set the prefix, in case CMake, Ninja or mold where already installed.
    current_prefix = os.environ.get("PREFIX", "")
    os.environ["PREFIX"] = f"{bin_dir}:{current_prefix}"

    install_tools = curses.wrapper(lambda stdscr: tui_install_tools())
    for tool, enabled in install_tools.items():
        dcs2_args.append(f"--{tool} {enabled}")

    cmake_available = program_available("cmake", os.environ)
    ninja_available = program_available("ninja", os.environ)
    mold_available  = program_available("mold", os.environ)
    

    #print(" ".join(cmake_args))
    #print(cmake_args)
    #print(dcs2_args)

    #subprocess.run(f"bash scripts/install_cmake.sh {}", stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    #subprocess.run(f"./test.sh {prefix} {build} {bin_dir}", stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    #if result.returncode != 0:
    #    print("Script failed.")

    if cmake_available = False
        script_path = ".scripts/install_cmake.sh"
        args = [f"{prefix}", f"{build}", f"{bin_dir}"]

        result = subprocess.run([script_path] + args, capture_output=True, text=True)
        if result.returncode != 0:
            print("STDERR:", result.stderr)
            exit 1

    if ninja_available = False
        script_path = ".scripts/install_ninja.sh"
        args = [f"{prefix}", f"{build}", f"{bin_dir}"]

        result = subprocess.run([script_path] + args, capture_output=True, text=True)
        if result.returncode != 0:
            print("STDERR:", result.stderr)
            exit 1

    if mold_available = False
        script_path = ".scripts/install_mold.sh"
        args = [f"{prefix}", f"{build}", f"{bin_dir}"]

        result = subprocess.run([script_path] + args, capture_output=True, text=True)
        if result.returncode != 0:
            print("STDERR:", result.stderr)
            exit 1
