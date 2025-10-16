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

# source folder
PREFIX=$HOME/dcs2

# Greetings
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

# Check if $PREFIX does not exist yet
if [ -d "${PREFIX}" ]; then
  cecho ${ERROR} "There already exists an installation of dcs2."
  cecho ${INFO} "To avoid data loss, the installation is aborted."
  echo
  cecho ${INFO} "If you want to continue delete ${PREFIX} and"
  cecho ${INFO} "rerun the install command."
  echo
  cecho ${INFO} "For different installation method visit:"
  cecho ${INFO} "https://github.com/kinnewig/dcs2"
  exit 1;
fi

# Create $PREFIX
mkdir -p "${PREFIX}" || { cecho ${ERROR} "  Failed to create: ${PREFIX}"; exit 1; }

# Download DCS2
if command -v git &>/dev/null; then
  git clone https://github.com/kinnewig/dcs2.git ${PREFIX}/dcs2
  if [[ $? -eq 0 ]]; then
    cecho ${GOOD} "Download successful."
  else
    cecho ${ERROR} "Download failed. Please check you internect connection."
    exit 1
  fi
else
  cecho ${ERROR} "Error:'git' is not available on this system."
  cecho ${INFO} "Please install git to proceed:"
  cecho ${INFO} "- Debian/Ubuntu: sudo apt install git"
  cecho ${INFO} "- Red Hat/Fedora: sudo dnf install git"
  exit 1
fi

# Let's clean up /tmp 
rm -rf /tmp/dcs2

# Run DCS2
cd ${PREFIX}/dcs2
scripts/tui.sh
