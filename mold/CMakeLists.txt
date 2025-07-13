cmake_minimum_required(VERSION 3.10)
project(Mold)

# Build Tool: Ninja
# Check if Ninja is installed
find_program(MOLD mold)

if (NOT DEFINED BIN_DIR)
  set(BIN_DIR ${CMAKE_INSTALL_PREFIX}/bin)
endif()

set(MOLD_VERSION "2.40.2" CACHE STRING "Specify the version of MOLD to be used")

include(${CMAKE_SOURCE_DIR}/mold.cmake)
