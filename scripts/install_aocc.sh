# Colours for progress and error reporting
ERROR="\033[1;31m"
GOOD="\033[1;32m"
WARN="\033[1;35m"
INFO="\033[1;34m"
BOLD="\033[1m"

cecho() {
  # Display messages in a specified colour
  COL=$1; shift
  echo -e "${COL}$@\033[0m"
}


# Read the CMake version from VERSIONS.cmake
AOCC_VERSION=5.0.0

OS=$(uname -s)
SYSTEM=$(uname -m)
ARCHITECTURE="${SYSTEM}-${OS,,}"

download_and_install_aocc() {
  local aocc_found=false

  AOCC_VERSION=5.0.0
  ARCHITECTURE=x86_64-linux

  # Check if AOCC is installed at the default path
  if [[ "$aocc_found" == false ]]; then
    if ls /opt/AMD/aocc-compiler-* &>/dev/null; then
      echo "  AMD AOCC found in /opt/AMD/, trying to activate it..."
      source /opt/AMD/aocc-compiler-*/setenv_AOCC.sh

      if clang --version 2>/dev/null | grep -q "AMD"; then
        cecho ${GOOD} "  Found AMD AOCC Compiler"
        clang --version
        aocc_found=true
      fi
    fi
  fi

  # Attempt to install AOCC from local archive
  if [[ "$aocc_found" == false ]]; then
    for archive in aocc-compiler-*.tar; do
      [[ -e "$archive" ]] || continue  # Skip if there is no file: aocc-compiler-*.tar
      cecho ${INFO} "  Found AMD AOCC archive: $archive, attempting automatic installation..."
      
      AOCC_VERSION=$(echo "$archive" | sed -E 's/aocc-compiler-([0-9]+\.[0-9]+\.[0-9]+)\.tar/\1/')

      mkdir -p "${PREFIX}/aocc/"
      tar -xf "aocc-compiler-${AOCC_VERSION}.tar" -C "${PREFIX}/aocc/"

      cd "${PREFIX}/aocc/aocc-compiler-${AOCC_VERSION}" || exit 1
      ./install.sh
      source "${PREFIX}/aocc/aocc-compiler-${AOCC_VERSION}/setenv_AOCC.sh"
      cd - > /dev/null

      if clang --version 2>/dev/null | grep -q "AMD"; then
        cecho ${GOOD} "  Successfully installed the AMD AOCC compiler"
        aocc_found=true
        break
      else
        cecho {WARN} "  Automated installation of the AMD AOCC compiler failed."
      fi
    fi
  fi

  # Final fallback if all attempts fail
  if [[ "$aocc_found" == false ]]; then
    cecho ${ERROR} "  AMD AOCC not found!"
    echo
    cecho ${INFO} "  Due to licensing, AMD AOCC cannot be downloaded automatically."
    cecho ${INFO} "  Please visit: https://www.amd.com/de/developer/aocc.html and download the latest version."
    cecho ${INFO} "  Alternatively, place aocc-compiler-${AOCC_VERSION}.tar.gz in the dcs2 root directory."
    cecho ${INFO} "  The tool will attempt to install it automatically from there."
    exit 1
  fi
}

# if the script is called via the python interface of dcs2 the following information is provided as arguments:
if [ "$#" -eq 1 ]; then
  if [ -z "${PREFIX}" ]; then
    PREFIX=$1
  fi

  download_and_install_aocc
else
  exit 1
fi

