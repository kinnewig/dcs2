#!/bin/bash

# Set default values
USER_INTERACTION=ON
THREADS=$(($(nproc)-2))

DEFAULT_PATH="${HOME}/dcs"



# ++============================================================++
# ||                         Premilaris                         ||
# ++============================================================++
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



# ++============================================================++
# ||                           CMake                            ||
# ++============================================================++
# Download and install CMake
download_and_install_cmake() {
    # Read the CMake version from VERSIONS.cmake
    CMAKE_VERSION=3.28.3

    # Download CMake
    curl -L https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}.tar.gz  -o "${BUILD_DIR}/source/cmake-${CMAKE_VERSION}.tar.gz"

    # Extract CMake
    tar -xf "${BUILD_DIR}/source/cmake-${CMAKE_VERSION}.tar.gz" -C "${BUILD_DIR}/extracted"

    # Build CMake
    cd "${BUILD_DIR}/extracted/cmake-${CMAKE_VERSION}"
    ./bootstrap --prefix="${PREFIX}/cmake/${CMAKE_VERSION}" 
    make -C "${BUILD_DIR}/extracted/cmake-${CMAKE_VERSION}" -j ${THREADS}
    make install

    # Link cmake binary to the bin folder
    ln -s "${PREFIX}/cmake/${CMAKE_VERSION}/bin/cmake" "${BIN_DIR}/cmake"

    cd $(dirname $0)

    # Add CMake to the PATH
    export PATH=${BIN_DIR}:${PATH}
}

check_and_install_cmake() {
    echo "Check if CMake is installed"
    if command -v cmake &>/dev/null; then
        cecho ${GOOD} "Found CMake $(cmake --version)"
    else
        download_and_install_cmake
        if ! command -v cmake &>/dev/null; then
            echo ${ERROR} "ERROR: Failed to install CMake automatically."
            exit 1
        else
            cecho ${GOOD} "CMake ${CMAKE_VERSION} has been installed to ${PREFIX}/cmake/${CMAKE_VERSION}"
        fi
    fi
}



# ++============================================================++
# ||                           Ninja                            ||
# ++============================================================++
# Check if Ninja is installed and install if not
check_and_install_ninja() {
    echo "Check if Ninja is installed"
    if command -v ninja &>/dev/null; then
        cecho ${GOOD} "Found Ninja $(ninja --version)"
    else
        cecho ${WARN} "Ninja not found. Attempting to install..."
        # Call the CMake script to install Ninja
        NINJA_VERSION=1.11.1
        cmake -S ninja -B ${BUILD_DIR}/ninja -D CMAKE_INSTALL_PREFIX=${PREFIX} -D NINJA_VERSION=${NINJA_VERSION} -D BIN_DIR=${BIN_DIR}
        cmake --build ${BUILD_DIR}/ninja -- -j ${THREADS}
        cmake --install ${BUILD_DIR}/ninja

        # Check that ${BIN_DIR} is already in the path.
        if [[ ":$PATH:" == *":${BIN_DIR}:"* ]]; then
            cecho ${INFO} "${BIN_DIR} is already in the path."
        else
            # Add Ninja to the PATH
            export PATH=${BIN_DIR}:${PATH}
        fi

        if ! command -v ninja &>/dev/null; then
            cecho ${ERROR} "ERROR: Failed to install Ninja automatically."
            exit 1
        else
            cecho ${GOOD} "Ninja has been installed successfully."
        fi
    fi
}



# ++============================================================++
# ||                           mold                             ||
# ++============================================================++
# Check if mold is installed and install if not
check_and_install_mold() {
    echo "Check if mold is installed"
    if command -v mold &>/dev/null; then
        cecho ${GOOD} "Found mold $(mold --version)"
    else
        cecho ${WARN} "Ninja not found. Attempting to install..."
        # Call the CMake script to install Ninja
        MOLD_VERSION=2.30.0
        cmake -S mold -B ${BUILD_DIR}/mold -D CMAKE_INSTALL_PREFIX=${PREFIX} -D MOLD_VERSION=${MOLD_VERSION} -D BIN_DIR=${BIN_DIR}
        cmake --build ${BUILD_DIR}/mold -- -j ${THREADS}
        cmake --install ${BUILD_DIR}/mold

        # Check that ${BIN_DIR} is already in the path.
        if [[ ":$PATH:" == *":${BIN_DIR}:"* ]]; then
            cecho ${INFO} "${BIN_DIR} is already in the path."
        else
            # Add mold to the PATH
            export PATH=${BIN_DIR}:${PATH}
        fi

        if ! command -v mold &>/dev/null; then
            cecho ${ERROR} "ERROR: Failed to install mold automatically."
            exit 1
        else
            cecho ${GOOD} "mold has been installed successfully."
        fi
    fi
}

# Download and extract mold
download_and_extract_mold() {
  echo "Check if mold is installed"
    if command -v mold &>/dev/null; then
        cecho ${GOOD} "Found mold $(mold --version)"
    else
      # Read the mold version
      MOLD_VERSION=2.30.0
      ARCHITECTURE=x86_64-linux

      # Download Mold
      curl -L https://github.com/rui314/mold/releases/download/v${MOLD_VERSION}/mold-${MOLD_VERSION}-${ARCHITECTURE}.tar.gz -o "${BUILD_DIR}/source/mold-${MOLD_VERSION}.tar.gz"

      # Extract Mold
      mkdir -p ${PREFIX}/mold/
      tar -xf "${BUILD_DIR}/source/mold-${MOLD_VERSION}.tar.gz" -C "${PREFIX}/mold/"

      # Link the Mold binary to the bin folder
      ln -s "${PREFIX}/mold/mold-${MOLD_VERSION}-${ARCHITECTURE}/bin/mold" "${BIN_DIR}/mold"

      cd $(dirname $0)

      # Add Mold to the PATH
      export PATH=${BIN_DIR}:${PATH}

      # Check mold
      if ! command -v mold &>/dev/null; then
          cecho ${ERROR} "ERROR: Failed to install mold automatically."
          exit 1
      else
          cecho ${GOOD} "mold has been downloaded successfully."
      fi
    fi
}



# ++============================================================++
# ||                    Add to path                             ||
# ++============================================================++
add_to_path() {
    # Check if ~/.bashrc already contains BIN_DIR in the PATH
    if grep -q "#BEGIN: ADDED BY DCS" ~/.bashrc; then
        # If it does, remove the old lines
        sed -i '/#BEGIN: ADDED BY DCS/,/#END: ADDED BY DCS/d' ~/.bashrc
    fi

    # Add BIN_DIR to the PATH in ~/.bashrc
    echo -e "\n#BEGIN: ADDED BY DCS\nexport PATH=${BIN_DIR}:\$PATH\n#END: ADDED BY DCS" >> ~/.bashrc
}




# ++============================================================++
# ||                       Parse arguments                      ||
# ++============================================================++
parse_arguments() {
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        KEY="$1"
        case $KEY in
            # Help
            -h|--help)
              echo "deal.II CMake SuberBuild, Version $(cat VERSION)"
              echo "Usage: $0 [options]"
              echo "  -h, --help                   Print this message"
              echo "  -p <path>,    --prefix=<path>        Set a different prefix path (default ${DEFAULT_PATH})"
              echo "  -b <path>,    --build=<path>         Set a different build path (default ${DEFAULT_PATH}/tmp)$"
              echo "  -d <path>,    --bin-dir=<path>       Set a different binary path (default ${DEFAULT_PATH}/bin)$"
              echo "  -j <threads>, --parallel=<threads>   Set number of threads to use (default ${THREADS})"
              echo "  -A <ON|OFF>,  --add_to_path=<ON|OFF> Enable or disable to add deal.II permanently to the path"
              echo "  -N <ON|OFF>,  --ninja=<ON|OFF>       Enable or disable the use of Ninja"
              echo "  -M <ON|OFF>,  --mold=<ON|OFF>        Enable or disable the use of mold"
              echo "  -U                                   Do not interupt"
              echo "  -v,           --version              Print the version number"
              exit 1
            ;;

            # prefix path
            -p|--path)
                PREFIX="$2"
                shift
                shift
                ;;

            # build directory
            -b|--build)
                BUILD_DIR="$2"
                shift
                shift
                ;;
            
            # binary directory
            -d|--bin-dir)
                BIN_DIR="$2"
                shift
                shift
                ;;

            # Additional CMake flags    
            -c|--cmake-flags)
                CMAKE_FLAGS="$2"
                shift
                shift
                ;;

            # Threads
            -j)
                THREADS="${1}"
                shift
                shift
                ;;

            # Add to PATH
            -A|--add_to_path)
                ADD_TO_PATH="$2"
                shift
                shift
                ;;

            # Ninja
            -N|--ninja)
                USE_NINJA="$2"
                shift
                shift
                ;;

           # Mold
            -M|--mold)
                USE_MOLD="$2"
                shift
                shift
                ;;

            -U)
                USER_INTERACTION=OFF
                shift
                shift
                ;;

            # Version
            -v|--version)
                echo "$(cat VERSION)"
                shift
                shift
                exit 1
                ;;

            # unknown flag
            *)
                cecho ${ERROR} "ERROR: Invalid command line option <$KEY>. See -h for more information."
                exit 1
                ;;
        esac
    done

    # PREFIX PATH
    # If user provided path is not set, use default path
    if [ -z "${PREFIX}" ]; then
        PREFIX="${DEFAULT_PATH}"
        cecho {INFO} "No path was provided default to: ${PREFIX}"
        cecho {INFO} "Otherwise, provide a path using the -p or --path option."
    else 
        # Check the input argument of the install path and (if used) replace the tilde
        # character '~' by the users home directory ${HOME}. 
        PREFIX=${PREFIX/#~\//$HOME\/}
    fi

    # Check if the provided path is writable
    mkdir -p "${PREFIX}" || { cecho ${ERROR} "Failed to create: ${PREFIX}"; exit 1; }

    # BINARY DIRECTORY
    # If user provided binary directory is not set, use default binary directory
    if [ -z "${BIN_DIR}" ]; then
        BIN_DIR="${PREFIX}/bin"
        cecho ${INFO} "No binary directory was provided default to: ${BIN_DIR}"
        cecho ${INFO} "Otherwise, provide a binary directory using the -d or --bin-dir option."
    else 
        # Check the input argument of the install path and (if used) replace the tilde
        # character '~' by the users home directory ${HOME}. 
        BIN_DIR=${BIN_DIR/#~\//$HOME\/}
    fi

    # Check if the provided binary directory is writable
    mkdir -p "${BIN_DIR}" || { echo "Failed to create: ${BIN_DIR}"; exit 1; }

    # BUILD DIRECTORY
    # If user provided build_dir is not set, use default build_dir
    if [ -z "${BUILD_DIR}" ]; then
        BUILD_DIR="${PREFIX}/tmp"
        cecho ${INFO} "No build directory was provided default to: ${BUILD_DIR}"
        cecho ${INFO} "Otherwise, provide a build directory using the -b or --build option."
    else 
        # Check the input argument of the install path and (if used) replace the tilde
        # character '~' by the users home directory ${HOME}. 
        BUILD_DIR=${BUILD_DIR/#~\//$HOME\/}
    fi

    # Check if the provided build directory is writable
    mkdir -p "${BUILD_DIR}"           || { echo "Failed to create: ${BUILD_DIR}"; exit 1; }
    mkdir -p "${BUILD_DIR}/source"    || { echo "Failed to create: ${BUILD_DIR}/source"; exit 1; }
    mkdir -p "${BUILD_DIR}/extracted" || { echo "Failed to create: ${BUILD_DIR}/extracted"; exit 1; }
    mkdir -p "${BUILD_DIR}/build"     || { echo "Failed to create: ${BUILD_DIR}/build"; exit 1; }

    # ADD TO PATH
    if [ -z "${ADD_TO_PATH}" ]; then
        ADD_TO_PATH=OFF
        cecho ${INFO} "Default is not to add DEAL_II_DIR permanently to the path."
        cecho ${INFO} "Otherwise, enable add to path via -A=OFF or --add_to_path=ON."
    fi

    # NINJA
    if [ -z "${USE_NINJA}" ]; then
        USE_NINJA=ON
        cecho ${INFO} "Default to use ninja."
        cecho ${INFO} "Otherwise, disable Ninja via -N OFF or --ninja=OFF."
    fi

    # MOLD
    if [ -z "${USE_MOLD}" ]; then
        USE_MOLD=ON
        cecho ${INFO} "Default to use mold."
        cecho ${INFO} "Otherwise, disable mold via -M OFF or --mold=OFF."
    fi

}



# ++============================================================++
# ||                    The actual program                      ||
# ++============================================================++
# Verify that dcs.sh is called from the directory where the script is located.
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
if [ "$(pwd)" != "${SCRIPT_DIR}" ]; then
  cecho ${ERROR} "ERROR: DCS has to be called from the directory where it is located."
  exit 1
fi

# Parse arguments
if ! parse_arguments "$@"; then
  exit 0
fi

# Check wether CMake is available.
# If it not available install it.
if ! check_and_install_cmake "$@"; then
  exit 1
fi

if [ "${USE_NINJA}" = "ON" ]; then
  if ! check_and_install_ninja "$@"; then
    exit 1
  fi
fi

if [ "${USE_MOLD}" = "ON" ]; then
  if ! check_and_install_mold "$@"; then
    exit 1
  fi
elif [ "${USE_MOLD}" = "DOWNLOAD" ]; then
  if ! download_and_extract_mold "$@"; then
    exit 1
  fi
fi


cmake -S . -B ${BUILD_DIR} -D CMAKE_INSTALL_PREFIX=${PREFIX} -D THREADS=${THREADS} ${CMAKE_FLAGS}
cmake --build ${BUILD_DIR} #-- -j ${THREADS}

if [ "${ADD_TO_PATH}" = "YES" ]; then
  add_to_path
fi
