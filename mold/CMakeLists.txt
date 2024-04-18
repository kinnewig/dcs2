cmake_minimum_required(VERSION 3.10)
project(Mold)

# Build Tool: Ninja
# Check if Ninja is installed
find_program(NINJA ninja)
if(NINJA)
  set(DEFAULT_GENERATOR "Ninja")
endif()

if (NOT DEFINED BIN_DIR)
  set(BIN_DIR ${CMAKE_INSTALL_PREFIX}/bin)
endif()

set(NINJA_VERSION "2.30.0" CACHE STRING "Specify the version of Ninja to be used")

include(${CMAKE_SOURCE_DIR}/mold.cmake)
