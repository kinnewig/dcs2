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
    CMAKE_VERSION=$(grep "CMAKE_VERSION" VERSIONS.cmake | cut -d "\"" -f 2)

    # Download CMake
    curl -L https://cmake.org/files/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}.tar.gz -o "${BUILD_DIR}/source/cmake-${CMAKE_VERSION}.tar.gz"

    # Extract CMake
    tar -xzf "${BUILD_DIR}/source/cmake-${CMAKE_VERSION}.tar.gz" -C "${BUILD_DIR}/extracted"

    # Build CMake
    cd "${BUILD_DIR}/extracted/cmake-${CMAKE_VERSION}"
    ./bootstrap --prefix="${PREFIX}/cmake/${CMAKE_VERSION}" 
    make -C "${BUILD_DIR}/extracted/cmake-${CMAKE_VERSION}" -j ${THREADS}
    make install

    # Link cmake binary to the bin folder
    ln -s "${PREFIX}/cmake/${CMAKE_VERSION}/bin/cmake" "${BIN_DIR}/cmake"

    cd $(dirname $0)
}

make_cmake_available() {
    echo "Check if CMake is installed"
    if command -v cmake &>/dev/null; then
        cecho ${GOOD} "Found CMake $(cmake --version)"
    else
        install_cmake
        if ! check_cmake_installed; then
            echo ${ERROR} "ERROR: Failed to install CMake autmatically."
            exit 1
        else
            cecho ${GOOD} "CMake ${CMAKE_VERSION} has been installed to ${PREFIX}/cmake/${CMAKE_VERSION}"
        fi
    fi
}



# ++============================================================++
# ||                       Parse arguments                      ||
# ++============================================================++
parse_arguments() {
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        KEY="$1"
        case $key in
            # Help
            -h|--help)
              echo "deal.II CMake SuberBuild, Version $(cat VERSION)"
              echo "Usage: $0 [options]"
              echo "  -h, --help                   Print this message"
              echo "  -p <path>, --prefix=<path>   Set a different prefix path (default ${DEFAULT_PATH})"
              echo "  -b <path>, --build=<path>    Set a different build path (default ${DEFAULT_PATH}/tmp)$"
              echo "  -d <path>, --build=<path>    Set a different binary path (default ${DEFAULT_PATH}/bin)$"
              echo "  -j <path>, --parallel=<path> Set number of threads to use (default ${THREADS})"
              echo "  -U                           Do not interupt"
              echo "  -v, --version                Print the version number"
              exit 0
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

            # Threads
            -j)
                THREADS="${1}"
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
                exit 0
                ;;

            # unknwon flag
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
        echo "No path was provided default to: ${PREFIX}"
        echo "Otherwise, provide a path using the -p or --path option."
    else 
        # Check the input argument of the install path and (if used) replace the tilde
        # character '~' by the users home directory ${HOME}. 
        PREFIX=${PREFIX/#~\//$HOME\/}
    fi

    # Check if the provided path is writable
    mkdir -p "${PREFIX}" || { echo "Failed to create: ${PREFIX}"; exit 1; }

    # BINARY DIRECTORY
    # If user provided binary directory is not set, use default binary directory
    if [ -z "${BIN_DIR}" ]; then
        BIN_DIR="${PREFIX}/bin"
        echo "No binary directory was provided default to: ${BIN_DIR}"
        echo "Otherwise, provide a binary directory using the -d or --bin-dir option."
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
        echo "No build directory was provided default to: ${BUILD_DIR}"
        echo "Otherwise, provide a build directory using the -b or --build option."
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
}



package_selection() {
    # Read user selection from dcs.cfg
    PACKAGES=""
    source dcs.cfg

    # List of all available packages
    ALL_PACKAGES=""

    # First disable all packages
    #for PACKAGE in ${ALL_PACKAGES[@]}; do
    #  sed -i "s/^list(APPEND INSTALL_TPLS \"${PACKAGE}\")/#list(APPEND INSTALL_TPLS \"${PACKAGE}\")/g" CMakeLists.txt
    #done
    
    # Next reenable the selected packages
    #for PACKAGE in ${PACKAGES[@]}; do
    #  sed -i "s/#list(APPEND INSTALL_TPLS \"${PACKAGE}\")/list(APPEND INSTALL_TPLS \"${PACKAGE}\")/g" CMakeLists.txt
    #done
}



if [ "$(pwd)" != "$(dirname $0)" ]; then
    cecho ${ERROR} "ERROR: DCS has to be called from the directory where it is located."
    exit 1
fi
