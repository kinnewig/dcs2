cmake_minimum_required(VERSION 3.10)
project(Ninja)

if (NOT DEFINED BIN_DIR)
  set(BIN_DIR ${CMAKE_INSTALL_PREFIX}/bin)
endif()

set(NINJA_VERSION "1.11.1" CACHE STRING "Specify the version of Ninja to be used")

include(${CMAKE_SOURCE_DIR}/ninja.cmake)
