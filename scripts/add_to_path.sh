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


if [ "$#" -eq 5 ]; then
  if [ -z "${PREFIX}" ]; then
    PREFIX=$1
  fi
  if [ -z "${BUILD_DIR}" ]; then
    PREFIX=$2
  fi
  if [ -z "${BIN_DIR}" ]; then
    BIN_DIR=$3
  fi
  if [ -z "${DEALII_VERSION}" ]; then
    DEALII_VERSION=$4
  fi
  if [ -z "${SET_AOCC_PATH}" ]; then
    SET_AOCC_PATH=$5
  fi

  add_to_path
else 
  exit 1
fi

