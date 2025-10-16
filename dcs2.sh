#!/bin/bash

# Set default values
USER_INTERACTION=ON
THREADS=$(($(nproc)-2))

DEFAULT_PATH="${HOME}/dcs"

# List of available BLAS stacks:
BLAS_OPTIONS=(AMD DEFAULT FLAME MKL SYSTEM)
BOOL_OPTIONS=(ON OFF)
BOOL_WITH_DOWNLOAD_OPTIONS=(ON OFF DOWNLOAD)

# Installed packages:
CMAKE_INSTALLED=NO 
NINJA_INSTALLED=NO 
MOLD_INSTALLED=NO
AOCL_INSTALLED=NO

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

OS=$(uname -s)
SYSTEM=$(uname -m)
ARCHITECTURE="${SYSTEM}-${OS,,}"

# Versions:
CMAKE_VERSION=4.1.1
MOLD_VERSION=2.40.4
NINJA_VERSION=1.13.1
AOCC_VERSION=5.0.0



# ++============================================================++
# ||                           CMake                            ||
# ++============================================================++
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
  ln -sf "${PREFIX}/cmake/${CMAKE_VERSION}/bin/cmake" "${BIN_DIR}/cmake"

  CMAKE_INSTALLED=YES
}



check_and_install_cmake() {
  cecho ${INFO} "CMake:"
  if command -v cmake &>/dev/null; then
    cecho ${GOOD} "  already installed"
  else
    cecho ${WARN} "  attempt to install..."
    download_and_install_cmake
    if ! command -v cmake &>/dev/null; then
      echo ${ERROR} "  ERROR: Failed to install CMake automatically."
      exit 1
    else
      cecho ${GOOD} "  CMake ${CMAKE_VERSION} has been installed to ${PREFIX}/cmake/${CMAKE_VERSION}"
    fi
  fi
  echo
}



# ++============================================================++
# ||                           Ninja                            ||
# ++============================================================++
# Check if Ninja is installed and install if not
check_and_install_ninja() {
  cecho ${INFO} "Ninja:"
  if command -v ninja &>/dev/null; then
    cecho ${GOOD} "  already installed"
  else
    cecho ${WARN} "  attempting to install..."
    # Call the CMake script to install Ninja
    cmake -S ninja -B ${BUILD_DIR}/ninja -D CMAKE_INSTALL_PREFIX=${PREFIX} -D BIN_DIR=${BIN_DIR}
    cmake --build ${BUILD_DIR}/ninja -- -j ${THREADS}
    cmake --install ${BUILD_DIR}/ninja

    if ! command -v ninja &>/dev/null; then
      cecho ${ERROR} "  ERROR: Failed to install Ninja automatically."
      exit 1
    else
      cecho ${GOOD} "  Ninja has been installed successfully."
      NINJA_INSTALLED=YES
    fi
  fi
  echo
}



download_and_extract_ninja() {
  cecho ${INFO} "Ninja:"
  if command -v ninja &>/dev/null; then
    cecho ${GOOD} "  already installed"
  else
    # Assemble the download URL
    NINJA_BASE_GIT=$(python3 -c "import json; print(json.load(open('cmake/libraries.json'))['ninja']['git'])")
    NINJA_BASE_URL="${NINJA_BASE_GIT%.git}"
    NINJA_DOWNLOAD_URL=${NINJA_BASE_URL}/releases/download/v${NINJA_VERSION}/ninja-${OS,,}.zip

    mkdir -p ${BUILD_DIR}/source
    mkdir -p ${BIN_DIR}

    # Download Ninja
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

    # Link the Ninja binary to the bin folder
    ln -sf "${PREFIX}/ninja/${NINJA_VERSION}/ninja" "${BIN_DIR}/ninja"

    # Add Ninja to the PATH
    export PATH=${BIN_DIR}:${PATH}

    # Check ninja
    if ! command -v ninja &>/dev/null; then
      cecho ${ERROR} "  ERROR: Failed to download ninja automatically."
      exit 1
    else
      cecho ${GOOD} "  ninja has been downloaded successfully."
    fi
  fi
  echo
}



# ++============================================================++
# ||                           mold                             ||
# ++============================================================++
# Check if mold is installed and install if not
check_and_install_mold() {
  cecho ${INFO} "mold:"
  if command -v mold &>/dev/null; then
    cecho ${GOOD} "  already installed"
  else
    cecho ${WARN} "  attempting to install..."
    # Call the CMake script to install Ninja
    cmake -S mold -B ${BUILD_DIR}/mold -D CMAKE_INSTALL_PREFIX=${PREFIX} -D BIN_DIR=${BIN_DIR}
    cmake --build ${BUILD_DIR}/mold -- -j ${THREADS}
    cmake --install ${BUILD_DIR}/mold

    if ! command -v mold &>/dev/null; then
      cecho ${ERROR} "  ERROR: Failed to install mold automatically."
      exit 1
    else
      cecho ${GOOD} "  mold has been installed successfully."
      MOLD_INSTALLED=YES
    fi
  fi
  echo
}



# Download and extract mold
download_and_extract_mold() {
  cecho ${INFO} "mold:"
  if command -v mold &>/dev/null; then
      cecho ${GOOD} "  already installed"
  else
    cecho ${WARN} "  attempt to install..."

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
    ln -sf "${PREFIX}/mold/mold-${MOLD_VERSION}-${ARCHITECTURE}/bin/mold" "${BIN_DIR}/mold"

    if ! command -v mold &>/dev/null; then
      cecho ${ERROR} "  ERROR: Failed to download mold automatically."
      exit 1
    else
      cecho ${GOOD} "  mold has been installed successfully."
      MOLD_INSTALLED=YES
    fi

  fi
  echo
}



# ++============================================================++
# ||                      AMD AOCC                              ||
# ++============================================================++
check_and_install_aocc() {
  local aocc_found=false
  local aocc_in_path=false

  # Check if clang is associated with AOCC
  cecho ${INFO} "AMD AOCC"
  if clang --version 2>/dev/null | grep -q "AMD"; then
    cecho ${GOOD} "  already installed"
    aocc_found=true
    aocc_in_path=true
  fi

  # Check if AOCC is installed at the default path
  if [[ "$aocc_found" == false ]]; then
    # Test the system path:
    if ls /opt/AMD/aocc-compiler-* &>/dev/null; then
      echo "  AMD AOCC found in /opt/AMD/, trying to activate it..."
      source /opt/AMD/aocc-compiler-*/setenv_AOCC.sh

      if clang --version 2>/dev/null | grep -q "AMD"; then
        cecho ${GOOD} "  Found AMD AOCC Compiler"
        clang --version
        AOCC_VERSION=$(clang --version | grep -oP 'AOCC_\K[\d.]+')
        AOCC_PATH="/opt/AMD/aocc-compiler-${AOCC_VERSION}"
        aocc_found=true
      fi
    fi

    # Test if AOCC is in the PREFIX already installed
    if ls ${PREFIX}/aocc/setenv_AOCC.sh &>/dev/null; then
      echo "  AMD AOCC found in ${PREFIX}, trying to activate it..."
      source ${PREFIX}/aocc/setenv_AOCC.sh

      if clang --version 2>/dev/null | grep -q "AMD"; then
        cecho ${GOOD} "  Found AMD AOCC Compiler"
        clang --version
        AOCC_VERSION=$(clang --version | grep -oP 'AOCC_\K[\d.]+')
        AOCC_PATH="${PREFIX}/aocc"
        aocc_found=true
      fi
    fi
  fi

  # Attempt to install AOCC from local archive
  if [[ "$aocc_found" == false ]]; then
    for archive in aocc-compiler-*.tar; do
      [[ -e "$archive" ]] || continue  # Skip if there is no file: aocc-compiler-*.tar
      cecho ${INFO} "  Found AMD AOCC archive, attempting automatic installation..."

      AOCC_VERSION=$(echo "$archive" | sed -E 's/aocc-compiler-([0-9]+\.[0-9]+\.[0-9]+)\.tar/\1/')

      mkdir -p "${PREFIX}/aocc/"
      tar -xf "$archive" -C "${PREFIX}/aocc/"

      ${PREFIX}/aocc/aocc-compiler-${AOCC_VERSION}/install.sh

      # unfortunally we do not want the first two lines:
      sed -i '0,/^export LD_LIBRARY_PATH/ s/^export LD_LIBRARY_PATH/#&/' "${PREFIX}/aocc/setenv_AOCC.sh"
      sed -i '0,/^export LIBRARY_PATH/ s/^export LIBRARY_PATH/#&/' "${PREFIX}/aocc/setenv_AOCC.sh"

      # Add to the end 
      echo "export CC=clang" >> ${PREFIX}/aocc/setenv_AOCC.sh
      echo "export CXX=clang++" >> ${PREFIX}/aocc/setenv_AOCC.sh
      echo "export FC=flang" >> ${PREFIX}/aocc/setenv_AOCC.sh

      source "${PREFIX}/aocc/setenv_AOCC.sh"

      if clang --version 2>/dev/null | grep -q "AMD"; then
        cecho ${GOOD} "  Successfully installed the AMD AOCC compiler"
        clang --version
        AOCC_PATH="${PREFIX}/aocc/aocc-compiler-${AOCC_VERSION}"
        aocc_found=true
        AOCL_INSTALLED=YES
        break
      else
        cecho ${WARN} "  Automated installation of the AMD AOCC compiler failed."
      fi
    done
  fi

  # Handle PATH update suggestion
  if [[ "$aocc_in_path" == false && "$aocc_found" == true ]]; then
    echo
    if [[ "${ADD_TO_PATH}" == "OFF" ]]; then
      cecho ${INFO} "==================================================="}
      cecho ${INFO} "IMPORTANT:"
      echo
      cecho ${INFO} "In order to use AOCC in future sessions, run:"
      cecho ${INFO} "source ${AOCC_PATH}/setenv_AOCC.sh"
      cecho ${INFO} "Or to automatically load AOCC, add the following to your ~/.bashrc:"
      cecho ${INFO} "if [ -f ${AOCC_PATH}/setenv_AOCC.sh ]; then"
      cecho ${INFO} "  source ${AOCC_PATH}/setenv_AOCC.sh"
      cecho ${INFO} "fi"
      echo
      if [[ "${ADD_TO_PATH}" == "OFF" && "${USER_INTERACTION}" == "ON" ]]; then
        read -p "Press Enter to continue..."
      fi
      cecho ${INFO} "==================================================="}
      echo
    else
      SET_AOCC_PATH=ON
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



# ++============================================================++
# ||                    Add to path                             ||
# ++============================================================++
add_to_path() {
  # Create a backup:
  BACKUP=~/.bashrc.backup.$(date +%s)
  cp ~/.bashrc $BACKUP

  # Remove previous DCS2 block if it exists
  if grep -q "#BEGIN: ADDED BY DCS2" ~/.bashrc; then
    sed -i '/#BEGIN: ADDED BY DCS2/,/#END: ADDED BY DCS2/d' ~/.bashrc
  fi

  # Write the DCS2 block
  {
    echo
    echo "#BEGIN: ADDED BY DCS2"
    echo "# Everything in this block will be overwritten the next time you run dcs2"
    echo
    echo "# --- deal.II ---"
    echo "if [ -d \"${PREFIX}/dealii/${DEALII_VERSION}\" ]; then"
    echo "  export DEAL_II_DIR=\"${PREFIX}/dealii/${DEALII_VERSION}\""
    echo "fi"
    echo
    echo "# --- dcs2: bin, and lib  ---"
    echo "if [ -d \"${BIN_DIR}\" ]; then"
    echo "  export PATH=\"${BIN_DIR}:\$PATH\""
    echo "fi"
    echo
    echo "if [ -d \"${LIB_DIR}\" ]; then"
    echo "  export LD_LIBRARY_PATH=\"${LIB_DIR}:\$LD_LIBRARY_PATH\""
    echo "fi"
    echo
    if [[ "${SET_AOCC_PATH}" == "ON" ]]; then
      echo "# --- dcs2: AOCC Compiler ---"
      echo "if [ -f \"${AOCC_PATH}/setenv_AOCC.sh\" ]; then"
      echo "  source \"${AOCC_PATH}/setenv_AOCC.sh\""
      echo "fi"
      echo
    fi
    echo "#END: ADDED BY DCS2"
  } >> ~/.bashrc

  # Preform at least a very basic sanity check:
  if ! bash -c 'source ~/.bashrc && command -v ls >/dev/null && command -v vi >/dev/null'; then
    cecho ${ERROR} "Auto update of the ~/.bashrc failed. PATH may be broken. Restoring backup..."
    cp $BACKUP ~/.bashrc
    exit 1
  fi

  source ~/.bashrc
}



# ++============================================================++
# ||                    Check compiler                          ||
# ++============================================================++

check_compiler() {
  echo
  echo "==================================================="
  echo "Compiler:"
  echo "==================================================="
  echo 

  # Liker
  if [ "${BLAS_STACK}" = "AMD" ]; then
    cecho ${INFO} "Linker: "

    # try to set the AMD linker (LLD)
    if builtin command -v lld > /dev/null; then
        cecho ${INFO} "  Found the AMD linker."
        CMAKE_FLAGS="${CMAKE_FLAGS} -D BIN_DIR=${BIN_DIR}"
      else
        cecho ${WARN} "  Could not find the AMD linker"
    fi
  fi


  # NON MPI Compiler
  cecho ${INFO} "C Compiler: "
  local found_c_compiler=false

  # If we use the AMD stack, ensure we are using clang
  if [ "${BLAS_STACK}" = "AMD" ]; then

    # check if CC is defined
    if [[ -n "$CC" ]]; then
      if [[ "$CC" == "clang" ]]; then
        cecho ${GOOD} "  Found CC compilier ${CC}"
        found_c_compiler=true
      else
        cecho ${WARN} "  CC is set to ${CC} instead of clang."
      fi
    else
      cecho ${WARN} "  CC Variable not set."
    fi

    # If clang was not found yet, check if it is present in the path
    if [ "$found_c_compiler" = "false" ]; then
      if builtin command -v clang > /dev/null; then
        cecho ${INFO} "  Found default clang."
        export CC=clang
        found_c_compiler=true
      else
        cecho ${ERROR} "  Could not find AMD clang!"
        cecho ${INFO} "  For the AMD BLAS stack the AMD clang compilier is required."
        cecho ${INFO} "  For more details see the README."
        cecho ${INFO} "  Either ensure that clang is included in your PATH"
        cecho ${INFO} "  or set the variable: export CC=</path/to>/clang"
        exit 1
      fi
    fi

    # Check that this is the AMD Clang compiler
    if ! clang --version | grep -qi "amd"; then
      cecho ${ERROR} "  It seems the clang compilier that was provided is not the AMD "
      cecho ${ERROR} "  clang compilier. But for the AMD BLAS stack the AMD clang compilier"
      cecho ${ERROR} "  is required. For more details see the README."
      exit 1
    fi

  # If we use the MKL stack, ensure we are using icx
  elif [ "${BLAS_STACK}" = "MKL" ]; then

    # check if CC is defined
    if [[ -n "$CC" ]]; then
      if [[ "$CC" == "icx" ]]; then
        cecho ${GOOD} "  Found CC compilier ${CC}"
        found_c_compiler=true
      else
        cecho ${WARN} "  CC is set to ${CC} instead of icx."
      fi
    else
      cecho ${WARN} "  CC Variable not set."
    fi

    # If icx was not found yet, check if it is present in the path
    if [ "$found_c_compiler" = "false" ]; then
      if builtin command -v icx > /dev/null; then
        cecho ${INFO} "  Found default icx."
        export CC=icx
        found_c_compiler=true
      # try to source the intel compilier
      elif [ -e "/opt/intel/oneapi/setvars.sh" ]; then
        source /opt/intel/oneapi/setvars.sh
        # try again to find the intel compilier
        if builtin command -v icx > /dev/null; then
          cecho ${INFO} "  Found default icx."
          export CC=icx
          found_c_compiler=true
        fi
      else
        cecho ${ERROR} "  Could not find Intel compilier icx!"
        cecho ${INFO} "  For the Intel OneMKL BLAS stack the Intel icx compilier is required."
        cecho ${INFO} "  For more details see the README."
        cecho ${INFO} "  Either ensure that clang is included in your PATH"
        cecho ${INFO} "  or set the variable: export CC=</path/to>/icx"
        exit 1
      fi
    fi

  # Otherwise, just check that we have a C compilier
  else
    if [[ -n "$CC" ]]; then
      # check that the compiler works:
      if builtin command -v "${CC}" > /dev/null; then
        cecho ${GOOD} "  Found CC compilier ${CC}"
      else
        cecho ${WARN} "  The compilier CC=${CC} does not work, attempt to restore default."
        unset CC
      fi

      # Ensure that CC is not a MPI compiler
      if [[ "$CC" == *mpi* ]]; then
        cecho ${WARN} "  The variable CC should point to the default compilier, not an MPI compiler, attempt to restore default."
        unset CC
      fi
    fi
      
    if [[ -z "$CC" ]]; then
      cecho ${WARN} "  CC Variable not set."
      if builtin command -v gcc > /dev/null; then
        cecho ${INFO} "  Found default gcc."
        export CC=gcc
      else
        cecho ${ERROR} "  No C Compiler was found!"
        cecho ${INFO} "  Either ensure that gcc is included in your PATH"
        cecho ${INFO} "  or set the variable: export CC=</path/to/c-compilier>"
        exit 1
      fi
    fi
  fi

  echo "  Found:   $(which ${CC})"
  echo "  Version: $(${CC} --version)"
  echo


  cecho ${INFO} "CXX Compiler: "
  local found_cxx_compiler=false

  # If we use the AMD stack, ensure we are using clang++
  if [ "${BLAS_STACK}" = "AMD" ]; then

    # check if CXX is defined
    if [[ -n "$CXX" ]]; then
      if [[ "$CXX" == "clang++" || "$CXX" == "clangxx" ]]; then
        cecho ${GOOD} "  Found CXX compilier ${CXX}"
        found_cxx_compiler=true
      else
        cecho ${WARN} "  CXX is set to ${CXX} instead of clang++/clangxx."
      fi
    else
      cecho ${WARN} "  CXX Variable not set."
    fi

    # If clang++ was not found yet, check if it is present in the path
    if [ "$found_cxx_compiler" = "false" ]; then
      if builtin command -v clang++ > /dev/null; then
        cecho ${INFO} "  Found default clang++."
        export CXX=clang++
        found_cxx_compiler=true
      else
        cecho ${ERROR} "  Could not find AMD clang++!"
        cecho ${INFO} "  For the AMD BLAS stack the AMD clang++ compilier is required."
        cecho ${INFO} "  For more details see the README."
        cecho ${INFO} "  Either ensure that clang is included in your PATH"
        cecho ${INFO} "  or set the variable: export CXX=</path/to>/clang++"
        exit 1
      fi
    fi

    # Check that this is the AMD clang++ compiler
    if ! clang++ --version | grep -qi "amd"; then
      cecho ${ERROR} "  It seems the clang++ compilier that was provided is not the AMD "
      cecho ${ERROR} "  clang compilier. But for the AMD BLAS stack the AMD clang compilier"
      cecho ${ERROR} "  is required. For more details see the README."
      exit 1
    fi

  # If we use the MKL stack, ensure we are using icx
  elif [ "${BLAS_STACK}" = "MKL" ]; then

    # check if CXX is defined
    if [[ -n "$CXX" ]]; then
      if [[ "$CXX" == "icpx" ]]; then
        cecho ${GOOD} "  Found CXX compilier ${CXX}"
        found_c_compiler=true
      else
        cecho ${WARN} "  CXX is set to ${CXX} instead of icpx."
      fi
    else
      cecho ${WARN} "  CXX Variable not set."
    fi

    # If icx was not found yet, check if it is present in the path
    if [ "$found_cxx_compiler" = "false" ]; then
      if builtin command -v icpx > /dev/null; then
        cecho ${INFO} "  Found default icx."
        export CXX=icpx
        found_cxx_compiler=true
      # try to source the intel compilier
      elif [ -e "/opt/intel/oneapi/setvars.sh" ]; then
        source /opt/intel/oneapi/setvars.sh
        # try again to find the intel compilier
        if builtin command -v icpx > /dev/null; then
          cecho ${INFO} "  Found default icpx."
          export CXX=icpx
          found_cxx_compiler=true
        fi
      else
        cecho ${ERROR} "  Could not find Intel compilier icx!"
        cecho ${INFO} "  For the Intel OneMKL BLAS stack the Intel icx compilier is required."
        cecho ${INFO} "  For more details see the README."
        cecho ${INFO} "  Either ensure that clang is included in your PATH"
        cecho ${INFO} "  or set the variable: export CXX=</path/to>/icx"
        exit 1
      fi
    fi

  # Otherwise, just check that we have a CXX compilier
  else
    if [[ -n "$CXX" ]]; then
      # check that the compiler works:
      if builtin command -v "${CXX}" > /dev/null; then
        cecho ${GOOD} "  Found CXX compilier ${CXX}"
      else
        cecho ${WARN} "  The compilier CXX=${CXX} does not work, attempt to restore default."
        unset CXX
      fi

      # Ensure that CC is not a MPI compiler
      if [[ "$CXX" == *mpi* ]]; then
        cecho ${WARN} "  The variable CXX should point to the default compilier, not an MPI compiler, attempt to restore default."
        unset CXX
      fi
    fi
    
    if [[ -z "$CXX" ]]; then
      cecho ${WARN}   "  CXX Variable not set."
      if builtin command -v g++ > /dev/null; then
        cecho ${INFO} "  Found default g++."
        export CXX=g++
      else
        cecho ${ERROR} "  No CXX Compiler was found!"
        cecho ${INFO} "  Either ensure that g++ is included in your PATH"
        cecho ${INFO} "  or set the variable: export CXX=</path/to/c++-compilier>"
        exit 1
      fi
    fi
  fi

  echo "  Found:   $(which ${CXX})"
  echo "  Version: $(${CXX} --version)"
  echo 


  cecho ${INFO} "Fortran Compiler: "
  local found_f_compiler=false

  # If we use the AMD stack, ensure we are using flang
  if [ "${BLAS_STACK}" = "AMD" ]; then

    # check if FC is defined
    if [[ -n "$FC" ]]; then
      if [[ "$FC" == "flang" ]]; then
        cecho ${GOOD} "  Found FC compilier ${FC}"
        found_f_compiler=true
      else
        cecho ${WARN} "  FC is set to ${FC} instead of flang."
      fi
    else
      cecho ${WARN} "  FC Variable not set."
    fi

    # If clang++ was not found yet, check if it is present in the path
    if [ "$found_f_compiler" = "false" ]; then
      if builtin command -v flang > /dev/null; then
        cecho ${INFO} "  Found default flang."
        export FC=flang
        found_f_compiler=true
      else
        cecho ${ERROR} "  Could not find AMD flang!"
        cecho ${INFO} "  For the AMD BLAS stack the AMD flang compilier is required."
        cecho ${INFO} "  For more details see the README."
        cecho ${INFO} "  Either ensure that flang is included in your PATH"
        cecho ${INFO} "  or set the variable: export FC=</path/to>/flang"
        exit 1
      fi
    fi

    # Check that this is the AMD clang++ compiler
    if ! flang --version | grep -qi "amd"; then
      cecho ${ERROR} "  It seems the flang compilier that was provided is not the AMD "
      cecho ${ERROR} "  clang compilier. But for the AMD BLAS stack the AMD clang compilier"
      cecho ${ERROR} "  is required. For more details see the README."
      exit 1
    fi

  # Otherwise, just check that we have a CXX compilier
  else
    if [[ -n "$FC" ]]; then
      # check that the compiler works:
      if builtin command -v "${FC}" > /dev/null; then
        cecho ${GOOD} "  Found FC compilier ${FC}"
      else
        cecho ${WARN} "  The compilier FC=${FC} does not work, attempt to restore default."
        unset FC
      fi

      # Ensure that CC is not a MPI compiler
      if [[ "$FC" == *mpi* ]]; then
        cecho ${WARN} "  The variable FC should point to the default compilier, not an MPI compiler, attempt to restore default."
        unset FC
      fi
    fi

    if [[ -z "$FC" ]]; then
      cecho ${WARN} "  FC Variable not set."
      if builtin command -v gfortran > /dev/null; then
        cecho ${INFO} "  Found default gfortran."
        export FC=gfortran
      else
        cecho ${ERROR} "  No FC Compiler was found!"
        cecho ${INFO} "  Either ensure that gfortran is included in your PATH"
        cecho ${INFO} "  or set the variable: export FC=</path/to/fortran-compilier>"
        exit 1
      fi
    fi
  fi

  echo "  Found:   $(which ${FC})"
  echo "  Version: $(${FC} --version)"
  echo


  cecho ${INFO} "MPI C Compiler: "
  if [[ -n "$MPI_CC" ]]; then
    # check that the compiler works:
    if builtin command -v "${MPI_CC}" > /dev/null; then
      cecho ${GOOD} "  Found MPI_CC compilier ${MPI_CC}"
    else
      cecho ${WARN} "  The compilier MPI_CC=${MPI_CC} does not work, attempt to restore default."
      unset MPI_CC
    fi
  fi

  if [[ -z "$MPI_CC" ]]; then
    cecho ${WARN} "  MPI_CC Variable not set."
    if builtin command -v mpicc > /dev/null; then
      cecho ${INFO} "  Found default mpicc."
      export MPI_CC=mpicc
    else
      cecho ${ERROR} "  No MPI C Compiler was found!"
      cecho ${INFO} "  Either ensure that mpicc is included in your PATH"
      cecho ${INFO} "  or set the variable: export MPI_CC=</path/to/mpi-c-compilier>"
      exit 1
    fi
  fi

  echo "  Found:   $(which ${MPI_CC})"
  echo "  Version: $(${MPI_CC} --version)"
  echo


  cecho ${INFO} "MPI CXX Compiler: "
  if [[ -n "$MPI_CXX" ]]; then
    # check that the compiler works:
    if builtin command -v "${MPI_CXX}" > /dev/null; then
      cecho ${GOOD} "  Found MPI_CXX compilier ${MPI_CXX}"
    else
      cecho ${WARN} "  The compilier MPI_CXX=${MPI_CXX} does not work, attempt to restore default."
      unset MPI_CXX
    fi
  fi

  if [[ -z "$MPI_CXX" ]]; then
    cecho ${WARN} "  MPI_CXX Variable not set."
    if builtin command -v mpicxx > /dev/null; then
      cecho ${INFO} "  Found default mpicxx."
      export MPI_CXX=mpicxx
    else
      cecho ${ERROR} "  No MPI CXX Compiler was found!"
      cecho ${INFO} "  Either ensure that mpicc is included in your PATH"
      cecho ${INFO} "  or set the variable: export MPI_CXX=</path/to/mpi-c++-compilier>"
      exit 1
    fi
  fi

  echo "  Found:   $(which ${MPI_CXX})"
  echo "  Version: $(${MPI_CXX} --version)"
  echo


  cecho ${INFO} "MPI Fortran Compiler: "
  if [[ -n "$MPI_FC" ]]; then
    # check that the compiler works:
    if builtin command -v "${MPI_FC}" > /dev/null; then
      cecho ${GOOD} "  Found MPI_FC compilier ${MPI_FC}"
    else
      cecho ${WARN} "  The compilier MPI_FC=${MPI_FC} does not work, attempt to restore default."
      unset MPI_FC
    fi
  fi

  if [[ -z "$MPI_FC" ]]; then
    cecho ${WARN} "  MPI_FC Variable not set."
    if builtin command -v mpifort > /dev/null; then
      cecho ${INFO} "  Found default mpifort."
      export MPI_FC=mpifort
    else
      cecho ${ERROR} "  No MPI Fortran Compiler was found!"
      cecho ${INFO} "  Either ensure that mpifort is included in your PATH"
      cecho ${INFO} "  or set the variable: export MPI_FC=</path/to/mpi-fortran-compilier>"
      exit 1
    fi
  fi

  echo "  Found:   $(which ${MPI_FC})"
  echo "  Version: $(${MPI_FC} --version)"
  echo

  # -- ASK THE USER TO CONTINUE --
  echo "==================================================="
  echo "IMPORTANT: Please check the configuration above."
  if [[ "${USER_INTERACTION}" == "ON" ]]; then
    read -p "Press Enter to continue... otherwise press STR+C"
  fi
  echo "==================================================="
  echo

}



# ++============================================================++
# ||                        Print Summary                       ||
# ++============================================================++
print_summary() {
  echo 
  echo "==================================================="
  echo "Summary:"
  echo "==================================================="
  if [ "${ADD_TO_PATH}" = "ON" ]; then
    add_to_path
  else
    if [ "${CMAKE_INSTALLED}" = "NO" ] && [ "${NINJA_INSTALLED}" = "NO" ] && [ "${MOLD_INSTALLED}" = "NO" ]; then
      echo "No additional packages where installed."
    else
      echo "The following additional packages where installed"
      if [ "${CMAKE_INSTALLED}" = "YES" ]; then
        echo "  - CMake"
      fi
      if [ "${NINJA_INSTALLED}" = "YES" ]; then
        echo "  - Ninja"
      fi
      if [ "${MOLD_INSTALLED}" = "YES" ]; then
        echo "  - Mold"
      fi
      echo
      echo "To make use of these run: " 
        echo "In order to use these in future sessions, run:"
        echo "export PATH=${BIN_DIR}:\$PATH"
        if [ "${MOLD_INSTALLED}" = "YES" ]; then
          echo "export LD_LIBRARY_PATH=${LIB_DIR}:\$LD_LIBRARY_PATH"
        fi
        echo
        echo "Or to automatically load these, add the following to your ~/.bashrc:"
        echo "if [ -f ${BIN_DIR} ]; then"
        echo "  export PATH=${BIN_DIR}:\$PATH"
        echo "fi"
        echo "if [ -f ${LIB_DIR} ]; then"
        echo "  export PATH=${BIN_DIR}:\$PATH"
        echo "  export LD_LIBRARY_PATH=${LIB_DIR}:\$LD_LIBRARY_PATH"
        echo "fi"
        echo
    fi
  
    if [ "${AOCL_INSTALLED}" = "YES" ]; then
        echo "AOCC Installed:"
        echo "In order to use AOCC in future sessions, run:"
        echo "source ${AOCC_PATH}/setenv_AOCC.sh"
        echo "Or to automatically load AOCC, add the following to your ~/.bashrc:"
        echo "if [ -f ${AOCC_PATH}/setenv_AOCC.sh ]; then"
        echo "  source ${AOCC_PATH}/setenv_AOCC.sh"
        echo "fi"
        echo
    fi
  
  
    echo "deal.II installed to: "
    echo "${PREFIX}/dealii/$(ls ${PREFIX}/dealii| tail -n 1)"
  fi
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
        echo "Usage: $0 [options] [--blas-stack=<BLAS option>] [--cmake-flags=\"<CMake Options>\"]"
        echo "  -h,           --help                         Print this message"
        echo "  -p <path>,    --prefix <path>                Set a different prefix path (default ${DEFAULT_PATH})"
        echo "  -b <path>,    --build <path>                 Set a different build path (default ${DEFAULT_PATH}/tmp)$"
        echo "  -d <path>,    --bin-dir <path>               Set a different binary path (default ${DEFAULT_PATH}/bin)$"
        echo "  -l <path>,    --lib-dir <path>               Set a different library path (default ${DEFAULT_PATH}/lib)$"
        echo "  -j <threads>, --parallel <threads>           Set number of threads to use (default ${THREADS})"
        echo "  -A <ON|OFF>   --add_to_path <ON|OFF>         Enable or disable adding deal.II permanently to the path"  
        echo "  -N <ON|OFF>,  --ninja <DOWNLOAD|ON|OFF>      Enable or disable the use of Ninja"
        echo "  -M <ON|OFF>,  --mold <DOWNLOAD|ON|OFF>       Enable or disable the use of mold"
        echo "  -U <ON|OFF>,  --user-interaction <ON|OFF>    Do not interupt"
        echo "  -v,           --version                      Print the version number"
        echo "                --blas-stack <blas option>     Select which BLAS to use (FLAME|SYSTEM|AMD|MKL)"
        echo "                --cmake-flags <CMake Options>  Specify additional CMake Options, see the README for details" 
        exit 1
      ;;

      # prefix path
      -p|--prefix)
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

      # binary directory
      -l|--lib-dir)
        LIB_DIR="$2"
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
        THREADS="${2}"
        shift
        shift
        ;;

      # Add to PATH
      -A|--add_to_path)
        ADD_TO_PATH=$(echo "${2^^}")
        shift
        shift
        ;;

      # BLAS stack
      --blas-stack)
        BLAS_STACK=$(echo "${2^^}")
        shift
        shift
        ;;

      # Ninja
      -N|--ninja)
        USE_NINJA=$(echo "${2^^}")
        shift
        shift
        ;;

      # Mold
      -M|--mold)
        USE_MOLD=$(echo "${2^^}")
        shift
        shift
        ;;

      -U|--user-interaction)
        USER_INTERACTION=$(echo "${2^^}")
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


  # -- PREFIX PATH --
  # If user provided path is not set, use default path
  cecho ${INFO} "Installation folder:"
  if [ -z "${PREFIX}" ]; then
    PREFIX="${DEFAULT_PATH}"
    echo "  No path was provided. Use the default installation folder:"
    echo "  ${PREFIX}"
    echo "  If you want to install deal.II to an other path, provide the path you want to use"
    echo "  via the -p <DIR> or --path <DIR> option."
  else 
    # Check the input argument of the install path and (if used) replace the tilde
    # character '~' by the users home directory ${HOME}. 
    PREFIX=${PREFIX/#~\//$HOME\/}
    echo "  ${PREFIX}"
  fi

  # Check if the provided path is writable
  mkdir -p "${PREFIX}" || { cecho ${ERROR} "  Failed to create: ${PREFIX}"; exit 1; }
  echo


  # -- BINARY DIRECTORY --
  # If user provided binary directory is not set, use default binary directory
  cecho ${INFO} "Binary folder:"
  if [ -z "${BIN_DIR}" ]; then
    BIN_DIR="${PREFIX}/bin"
    echo "  No binary directory was provided. Use the default binary folder:"
    echo "  ${BIN_DIR}"
    echo "  If you want to specify an other path, provide a binary directory" 
    echo "  using the -d <DIR> or --bin-dir <DIR> option."
  else 
    # Check the input argument of the install path and (if used) replace the tilde
    # character '~' by the users home directory ${HOME}. 
    BIN_DIR=${BIN_DIR/#~\//$HOME\/}
    echo "  ${BIN_DIR}"
  fi

  # Check if the provided binary directory is writable
  mkdir -p "${BIN_DIR}" || { cecho ${ERROR} "  Failed to create: ${BIN_DIR}"; exit 1; }
  echo

  # Add the BIN_DIR to as flag to CMake
  CMAKE_FLAGS="${CMAKE_FLAGS} -D BIN_DIR=${BIN_DIR}"

  # -- LIBRARY DIRECTORY --
  # If user provided binary directory is not set, use default binary directory
  cecho ${INFO} "Library folder:"
  if [ -z "${LIB_DIR}" ]; then
    LIB_DIR="${PREFIX}/lib"
    echo "  No library directory was provided. Use the default binary folder:"
    echo "  ${LIB_DIR}"
    echo "  If you want to specify an other path, provide a library directory" 
    echo "  using the -l <DIR> or --lib-dir <DIR> option."
  else 
    # Check the input argument of the install path and (if used) replace the tilde
    # character '~' by the users home directory ${HOME}. 
    LIB_DIR=${LIB_DIR/#~\//$HOME\/}
    echo "  ${LIB_DIR}"
  fi

  # Check if the provided library directory is writable
  mkdir -p "${LIB_DIR}" || { cecho ${ERROR} "  Failed to create: ${LIB_DIR}"; exit 1; }
  echo

  # Add the LIB_DIR to as flag to CMake
  CMAKE_FLAGS="${CMAKE_FLAGS} -D LIB_DIR=${LIB_DIR}"


  # -- LIBRARY64 DIRECTORY --
  # If user provided binary directory is not set, use default binary directory
  cecho ${INFO} "Library 64 folder:"
  if [ -z "${LIB64_DIR}" ]; then
    LIB64_DIR="${LIB_DIR}/../lib64"
    echo "  The Library 64 folder will be created next to the Library folder"
  fi

  # Check if the provided library directory is writable
  mkdir -p "${LIB64_DIR}" || { cecho ${ERROR} "  Failed to create: ${LIB64_DIR}"; exit 1; }
  echo

  # Add the LIB_DIR to as flag to CMake
  CMAKE_FLAGS="${CMAKE_FLAGS} -D LIB64_DIR=${LIB64_DIR}"


  # -- BUILD DIRECTORY --
  # If user provided build_dir is not set, use default build_dir
  cecho ${INFO} "Build folder:"
  if [ -z "${BUILD_DIR}" ]; then
    BUILD_DIR="${PREFIX}/tmp"
    echo "  No build directory was provided. Use the default build folder:"
    echo "  ${BUILD_DIR}"
    echo "  If you want to specify an other path, provide a build directory"
    echo "  using the -b <DIR> or --build <DIR> option."
  else 
    # Check the input argument of the install path and (if used) replace the tilde
    # character '~' by the users home directory ${HOME}. 
    BUILD_DIR=${BUILD_DIR/#~\//$HOME\/}
    echo "  ${BUILD_DIR}"
  fi
  echo

  # Check if the provided build directory is writable
  mkdir -p "${BUILD_DIR}"           || { cecho ${ERROR} "Failed to create: ${BUILD_DIR}"; exit 1; }
  mkdir -p "${BUILD_DIR}/source"    || { cecho ${ERROR} "Failed to create: ${BUILD_DIR}/source"; exit 1; }
  mkdir -p "${BUILD_DIR}/extracted" || { cecho ${ERROR} "Failed to create: ${BUILD_DIR}/extracted"; exit 1; }
  mkdir -p "${BUILD_DIR}/build"     || { cecho ${ERROR} "Failed to create: ${BUILD_DIR}/build"; exit 1; }


  # -- ADD TO PATH --
  cecho ${INFO} "DCS2 offers to add the installed components to the default path"
  cecho ${INFO} "by automaically modifing the ~/.bashrc"

  if [ -z "${ADD_TO_PATH}" ]; then
    ADD_TO_PATH=OFF
    echo "  The default is not to modify the bashrc."
    echo "  However, if you want to automatically add the installed components"
    echo "  to the bashrc enable this feature via -A ON or --add_to_path ON."
  fi

  # Check if the variable is valid
  if [[ ! " ${BOOL_OPTIONS[@]} " =~ " ${ADD_TO_PATH} " ]]; then
    cecho ${WARN} "  Unkown --add_to_path option: ${ADD_TO_PATH} (available option: ON|OFF)"
    cecho ${WARN} "  Default to --add_to_path OFF"
    echo "  However, if you want to automatically add the installed components"
    echo "  to the bashrc enable this feature via -A ON or --add_to_path ON."
    ADD_TO_PATH=OFF
  fi

  # Print the corresponding information
  if [ "${ADD_TO_PATH}" = "ON" ]; then
    echo "  The installed components will be added to the path, by modifing"
    echo "  the ~/.bashrc"
  else
    echo "  No modifications to the bashrc will be done!"
  fi
  echo


  # -- BLAS stack --
  if [ -z "${BLAS_STACK}" ]; then
    BLAS_STACK=DEFAULT
  fi

  # check if the user selcted a valid blas option:
  cecho ${INFO} "BLAS stack: "
  if [[ " ${BLAS_OPTIONS[@]} " =~ " ${BLAS_STACK} " ]]; then
    echo "  ${BLAS_STACK}"
  else
    cecho ${WARN} "  Unkown BLAS stack: ${BLAS_STACK}"
    cecho ${WARN} "  Default to use the default BLAS stack."
    BLAS_STACK=DEFAULT
  fi

  # Add the BLAS Stack to the CMake Options:
  CMAKE_FLAGS="${CMAKE_FLAGS} -D BLAS_STACK=${BLAS_STACK}"

  # Print the information about the BLAS stack
  echo "  To select a different BLAS stack use: --blas-stack=<OPTION>"
  echo "  The currently available options are: AMD, DEFAULT, FLAME, MKL, SYSTEM"
  echo


  # -- CMAKE --
  cecho ${INFO} "CMake:"
  if command -v cmake &>/dev/null; then
    cecho ${GOOD} "  Found CMake"
    echo "  Found:   $(which cmake)"
    echo "  Version: $(cmake --version)"
  else
    cecho ${WARN} "  CMake not found. But this is (maybe) not a problem!"
    cecho ${INFO} "  DCS2 will attempt to install CMake."
    echo
    echo "  CMake is a hard requirement for DCS2, if the automated installation"
    echo "  of CMake fails, please try to install manually (e.g. via the package"
    echo "  manager of your system)."
    echo
    echo "  If you want CMake to be available after the install of deal.II and all of its"
    echo "  dependencies, add ${BIN_DIR} to your enviroment."
    echo "  Alternatively DCS2 can automatically add the corresponding directory to your"
    echo "  enviroment variables; therefore, add the flag: --add_to_path ON"
  fi


  # -- NINJA --
  cecho ${INFO} "Build tool:"

  if [ -z "${USE_NINJA}" ]; then
    USE_NINJA=DOWNLOAD
    echo "  Ninja is used by default (and replaces GNU make)."
    echo "  If you don't want to use ninja, it can be disabled via -N OFF or --ninja OFF."
  fi

  # Check if the variable is valid
  if [[ ! " ${BOOL_WITH_DOWNLOAD_OPTIONS[@]} " =~ " ${USE_NINJA} " ]]; then
    cecho ${WARN} "  Unkown --ninja option: ${ADD_TO_PATH} (available option: ON|OFF|DOWNLOAD)"
    cecho ${WARN} "  Default to --ninja DOWNLOAD"
    USE_NINJA=DOWNLOAD
  fi

  # Print the corresponding information about Ninja
  if [[ "${USE_NINJA}" = "ON" || "${USE_NINJA}" = "DOWNLOAD" ]]; then
    if command -v ninja &>/dev/null; then
      cecho ${GOOD} "  Found Ninja"
      echo "  Found:   $(which ninja)"
      echo "  Version: $(ninja --version)"
    else
      cecho ${WARN} "  Ninja not found. But this is not a problem!"
      if [ "${USE_NINJA}" = "ON" ]; then
        cecho ${INFO} "  DCS2 will attempt to install Ninja."
      fi
      if [ "${USE_NINJA}" = "DOWNLOAD" ]; then
        cecho ${INFO} "  DCS2 will attempt to download Ninja."
      fi
      echo "  If you want Ninja to be available after the install of deal.II and all of its"
      echo "  dependencies, add ${BIN_DIR} to your enviroment."
      echo "  Alternatively DCS2 can automatically add the corresponding directory to your"
      echo "  enviroment variables; therefore, add the flag: --add_to_path ON"
    fi
  else
    echo "  Using GNU make as build tool."
  fi
  echo


  # -- MOLD --
  cecho ${INFO} "Linker:"

  if [ "${BLAS_STACK}" = "AMD" ]; then
    if [[ "${USE_MOLD}" = "ON" || "${USE_MOLD}" = "DOWNLOAD" ]]; then
      cecho ${WARN} "  Disabling mold!"
    fi 
    echo "  Using lld."
  else
    if [ -z "${USE_MOLD}" ]; then
      echo "  mold is used by default (and replaces ld)."
      echo "  If you don't want to use mold, it can be disabled via -M OFF or --mold OFF."
      USE_MOLD=DOWNLOAD
    fi

    # check if the user specified a valid mold option
    if [[ ! " ${BOOL_WITH_DOWNLOAD_OPTIONS[@]} " =~ " ${USE_MOLD} " ]]; then
      cecho ${WARN} "  Unkown mold option: ${USE_MOLD} (available option: ON|OFF|DOWNLOAD)"
      cecho ${WARN} "  Default to download mold!"
      echo "  mold is used by default (and replaces ld)."
      echo "  If you don't want to use mold, it can be disabled via -M OFF or --mold OFF."
      USE_MOLD=DOWNLOAD
    fi

    if [[ "${USE_MOLD}" = "ON" || "${USE_MOLD}" = "DOWNLOAD" ]]; then
      if command -v mold &>/dev/null; then
        cecho ${GOOD} "  Found mold!"
        echo "  Found:   $(which mold)"
        echo "  Version: $(mold --version)"
      else
        cecho ${WARN} "  Mold not found. But this is not a problem!"
        if [ "${USE_MOLD}" = "ON" ]; then
          cecho ${INFO} "  DCS2 will attempt to install Mold."
        fi
        if [ "${USE_MOLD}" = "DOWNLOAD" ]; then
          cecho ${INFO} "  DCS2 will attempt to download Mold."
        fi
        echo "  If you want mold to be available after the install of deal.II and all of its"
        echo "  dependencies, add ${BIN_DIR} to your enviroment."
        echo "  Alternatively DCS2 can automatically add the corresponding directory to your"
        echo "  enviroment variables; therefore, add the flag: --add_to_path ON"
      fi
    else
      echo "  Use ld as linker."
    fi
  fi
  echo

  # Set mold as linker
  #if [[ "${USE_MOLD}" = "ON" ]]; then
  #  export LD=mold
  #  export LDFLAGS="-fuse-ld=mold"
  #fi

  # -- SET_AOCC_PATH --
  if [ -z "${SET_AOCC_PATH}" ]; then
      SET_AOCC_PATH=OFF
  fi


  # -- USER INTERACTION --
  cecho ${INFO} "Userinteraction mode:"
  if [ -z "${USER_INTERACTION}" ]; then
      USER_INTERACTION=ON 
  fi

  # Check if the variable is valid
  if [[ ! " ${BOOL_OPTIONS[@]} " =~ " ${USER_INTERACTION} " ]]; then
    cecho ${WARN} "  Unkown -U option: ${ADD_TO_PATH} (available option: ON|OFF)"
    cecho ${WARN} "  Default to -U ON"
  fi

  if [ "${USER_INTERACTION}" = "ON" ]; then
    echo "  Manual, requires the user to verify the installation."
    echo "  To supress the user interaction use: -U OFF"
  else
    echo "  Automatic."
  fi
  echo


  # -- ASK THE USER TO CONTINUE --
  echo "==================================================="
  echo "IMPORTANT: Please check the configuration above."
  if [[ "${USER_INTERACTION}" == "ON" ]]; then
    read -p "Press Enter to continue... otherwise press STR+C"
  fi
  echo "==================================================="
  echo
}



# ++============================================================++
# ||                    The actual program                      ||
# ++============================================================++
echo
echo "==================================================="
echo "                     _  __ ____ "
echo "                    | \/  (_  _)"
echo "                    |_/\____)/__"
echo 
echo "==================================================="
echo 
echo "Welcome to the deal.II CMake Superbuild Script 2"
echo

# Verify that dcs.sh is called from the directory where the script is located.
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
if [ "$(pwd)" != "${SCRIPT_DIR}" ]; then
  cecho ${ERROR} "ERROR: dcs2 has to be called from the directory where it is located."
  exit 1
fi

# Parse arguments
if ! parse_arguments "$@"; then
  exit 0
fi

echo
echo "==================================================="
echo "Automated install of pre-CMake dependencies:"
echo "==================================================="
echo

# Check that ${BIN_DIR} is already in the path.
if [[ ":$PATH:" != *":${BIN_DIR}:"* ]]; then
  export PATH=${BIN_DIR}:${PATH}
fi

# The build folder should not exist at this point:
if [[ -d "${BUILD_DIR}" ]]; then
  echo
  cecho ${WARN} "The build folder ${BUILD_DIR} already exists."
  echo "This can mean, that you simply aborted the last run and want to continue"
  echo "where you stopped. In this case you can ignore this message. Similar, if you want" 
  echo "to install an updated version of deal.II you can ignore this message aswell."
  echo "However, if you last build failed it could be a good idea to delete the build"
  echo "folder."
  echo "Note: Deleting the build folder only effects the packages that are not build yet."
  echo "DCS2 will attempt to find already installed packages in ${PREFIX}."
  echo
  if [[ "${USER_INTERACTION}" == "ON" ]]; then
    read -p "Press Enter to continue... otherwise press STR+C"
  fi
fi

# Check wether CMake is available.
# If it not available install it.
if ! check_and_install_cmake "$@"; then
  exit 1
fi

if [ "${BLAS_STACK}" = "AMD" ]; then
  if ! check_and_install_aocc "&@"; then
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

if [ "${USE_NINJA}" = "ON" ]; then
  if ! check_and_install_ninja "$@"; then
    exit 1
  fi
elif [ "${USE_NINJA}" = "DOWNLOAD" ]; then
  if ! download_and_extract_ninja "$@"; then
    exit 1
  fi
fi


# Check the compiler
if ! check_compiler "$@"; then
  exit 1
fi

echo

echo "==================================================="
echo "Summary of packages, that will be build:"
echo "==================================================="

cmake -S . -B ${BUILD_DIR} -D CMAKE_INSTALL_PREFIX=${PREFIX} -D THREADS=${THREADS} ${CMAKE_FLAGS}
if [[ $? -eq 0 ]]; then
  cecho ${GOOD} "Preperation succeeded"
else
  cecho ${ERROR} "Preperation failed"
  exit 1
fi

echo 
echo "==================================================="
echo "Please check the packages that will be installed"
if [[ "${USER_INTERACTION}" == "ON" ]]; then
  read -p "Press Enter to continue... otherwise press STR+C"
fi
echo "==================================================="
echo 

cmake --build ${BUILD_DIR} #-- -j ${THREADS}
if [[ $? -eq 0 ]]; then
  echo 
  cecho ${GOOD} "Installation succeeded"
  echo 
else
  echo 
  cecho ${ERROR} "Installation failed"
  exit 1
fi

if ! print_summary "$@"; then
  exit 1
fi

