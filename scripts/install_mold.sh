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


# Read the mold version
MOLD_VERSION=2.40.3

OS=$(uname -s)
SYSTEM=$(uname -m)
ARCHITECTURE="${SYSTEM}-${OS,,}"


download_and_install_mold() {
  # Call the CMake script to install Ninja
  cmake -S mold -B ${BUILD_DIR}/mold -D CMAKE_INSTALL_PREFIX=${PREFIX} -D BIN_DIR=${BIN_DIR}
  cmake --build ${BUILD_DIR}/mold -- -j ${THREADS}
  cmake --install ${BUILD_DIR}/mold
}


download_and_extract_mold() {
  # Assemble the download URL
  MOLD_BASE_GIT=$(python3 -c "import json; print(json.load(open('cmake/libraries.json'))['mold']['git'])")
  MOLD_BASE_URL="${MOLD_BASE_GIT%.git}"
  MOLD_DOWNLOAD_URL=${MOLD_BASE_URL}/releases/download/v${MOLD_VERSION}/mold-${MOLD_VERSION}-${ARCHITECTURE}.tar.gz

  # Download Mold
  if command -v curl &>/dev/null; then
    curl -L ${MOLD_DOWNLOAD_URL} -o "${BUILD_DIR}/source/mold-${MOLD_VERSION}.tar.gz"
  elif command -v wget &>/dev/null; then
    wget ${MOLD_DOWNLOAD_URL} -O "${BUILD_DIR}/source/mold-${MOLD_VERSION}.tar.gz"
  else
    cecho ${ERROR} "Error: Neither 'curl' nor 'wget' is available on this system."
    cecho ${INFO} "Please install one of these tools to proceed:"
    cecho ${INFO} "- Debian/Ubuntu: sudo apt install curl  # or wget"
    cecho ${INFO} "- Red Hat/Fedora: sudo dnf install curl  # or wget"
    exit 1
  fi

  # Extract Mold
  mkdir -p ${PREFIX}/mold/
  tar -xf "${BUILD_DIR}/source/mold-${MOLD_VERSION}.tar.gz" -C "${PREFIX}/mold/"

  # Link the Mold binary to the bin folder
  ln -s "${PREFIX}/mold/mold-${MOLD_VERSION}-${ARCHITECTURE}/bin/mold" "${BIN_DIR}/mold"
}


if [ "$#" -eq 4 ]; then
  if [ -z "${PREFIX}" ]; then
    PREFIX=$1
  fi
  if [ -z "${BUILD_DIR}" ]; then
    PREFIX=$2
  fi
  if [ -z "${BIN_DIR}" ]; then
    BIN_DIR=$3
  fi
  if [ -z "${METHOD}" ]; then
    METHOD="{$4^^}"
  fi

  if [ "${METHOD}" = "ON" ]; then
    download_and_install_mold
  elif [ "${METHOD}" = "DOWNLOAD" ]; then
    download_and_extract_mold
  fi
else
  exit 1
fi

