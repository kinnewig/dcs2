#!/bin/bash

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

# Read the ninja version
NINJA_VERSION=1.13.1

OS=$(uname -s)
SYSTEM=$(uname -m)
ARCHITECTURE="${SYSTEM}-${OS,,}"

# Add this at the top of your script
export PYTHONUNBUFFERED=1
export STDOUT_LINE_BUFFERED=1

download_and_install_ninja() {
  # Call the CMake script to install Ninja
  cmake -S ninja -B ${BUILD_DIR}/ninja -D CMAKE_INSTALL_PREFIX=${PREFIX} -D BIN_DIR=${BIN_DIR}
  cmake --build ${BUILD_DIR}/ninja -- -j ${THREADS}
  cmake --install ${BUILD_DIR}/ninja
}


download_and_extract_ninja() {
  # Assemble the download URL
  NINJA_BASE_GIT=$(python3 -c "import json; print(json.load(open('cmake/libraries.json'))['ninja']['git'])")
  NINJA_BASE_URL="${NINJA_BASE_GIT%.git}"
  NINJA_DOWNLOAD_URL=${NINJA_BASE_URL}/releases/download/v${NINJA_VERSION}/ninja-${OS,,}.zip

  echo ${NINJA_DOWNLOAD_URL}

  mkdir -p ${BUILD_DIR}/source
  mkdir -p ${BIN_DIR}

  # Download Mold
  if command -v curl &>/dev/null; then
    curl -L ${NINJA_DOWNLOAD_URL} -o "${BUILD_DIR}/source/ninja-${NINJA_VERSION}.zip"
  elif command -v wget &>/dev/null; then
    wget ${NINJA_DOWNLOAD_URL} -O "${BUILD_DIR}/source/ninja-${NINJA_VERSION}.zip"
  else
    cecho ${ERROR} "Error: Neither 'curl' nor 'wget' is available on this system."
    cecho ${INFO} "Please install one of these tools to proceed:"
    cecho ${INFO} "- Debian/Ubuntu: sudo apt install curl  # or wget"
    cecho ${INFO} "- Red Hat/Fedora: sudo dnf install curl  # or wget"
    exit 1
  fi

  # Extract Ninja
  mkdir -p ${PREFIX}/ninja/${NINJA_VERSION}
  unzip "${BUILD_DIR}/source/ninja-${NINJA_VERSION}.zip" -d "${PREFIX}/ninja/{$NINJA_VERSION}"

  # Link the Mold binary to the bin folder
  ln -s "${PREFIX}/ninja/${NINJA_VERSION}/ninja" "${BIN_DIR}/ninja"
}


# if the script is called via the python interface of dcs2 the following information is provided as arguments:
if [ "$#" -eq 4 ]; then
  PREFIX=$1
  BUILD_DIR=$2
  BIN_DIR=$3
  METHOD=$(echo "${4^^}")

  if [ "${METHOD}" = "ON" ]; then
    download_and_install_ninja
  elif [ "${METHOD}" = "DOWNLOAD" ]; then
    download_and_extract_ninja
  fi
else 
  exit 1
fi


