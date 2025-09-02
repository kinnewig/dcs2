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
CMAKE_VERSION=4.1.0

OS=$(uname -s)
SYSTEM=$(uname -m)
ARCHITECTURE="${SYSTEM}-${OS,,}"


# Download and install CMake
download_and_install_cmake() {
  # Save the current directory
  local root_dir=$(pwd)

  # Download CMake
  # Assemble the download URL
  CMAKE_BASE_GIT=$(python3 -c "import json; print(json.load(open('cmake/libraries.json'))['cmake']['git'])")
  CMAKE_BASE_URL="${CMAKE_BASE_GIT%.git}"
  CMAKE_DOWNLOAD_URL=${CMAKE_BASE_URL}/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-${ARCHITECTURE}.tar.gz
  
  if command -v curl &>/dev/null; then
    curl -L ${CMAKE_DOWNLOAD_URL}  -o "${BUILD_DIR}/source/cmake-${CMAKE_VERSION}.tar.gz"
  elif command -v wget &>/dev/null; then
    wget ${CMAKE_DOWNLOAD_URL} -O "${BUILD_DIR}/source/cmake-${CMAKE_VERSION}.tar.gz"
  else
    cecho ${ERROR} "Error: Neither 'curl' nor 'wget' is available on this system."
    cecho ${INFO} "Please install one of these tools to proceed:"
    cecho ${INFO} "- Debian/Ubuntu: sudo apt install curl  # or wget"
    cecho ${INFO} "- Red Hat/Fedora: sudo dnf install curl  # or wget"
    exit 1
  fi

  # Extract CMake
  tar -xf "${BUILD_DIR}/source/cmake-${CMAKE_VERSION}.tar.gz" -C "${BUILD_DIR}/extracted"

  # Build CMake
  cd "${BUILD_DIR}/extracted/cmake-${CMAKE_VERSION}"
  ./bootstrap --prefix="${PREFIX}/cmake/${CMAKE_VERSION}" 
  make -C "${BUILD_DIR}/extracted/cmake-${CMAKE_VERSION}" -j ${THREADS}
  make install

  # Link cmake binary to the bin folder
  ln -s "${PREFIX}/cmake/${CMAKE_VERSION}/bin/cmake" "${BIN_DIR}/cmake"

  cd root_dir
}


# if the script is called via the python interface of dcs2 the following information is provided as arguments:
if [ "$#" -eq 3 ]; then
  if [ -z "${PREFIX}" ]; then
    PREFIX=$1
  fi
  if [ -z "${BUILD_DIR}" ]; then
    PREFIX=$2
  fi
  if [ -z "${BIN_DIR}" ]; then
    BIN_DIR=$3
  fi

  download_and_install_cmake
fi

