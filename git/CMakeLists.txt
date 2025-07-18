cmake_minimum_required(VERSION 3.10)
project(Git)

if (NOT DEFINED BIN_DIR)
  set(BIN_DIR ${CMAKE_INSTALL_PREFIX}/bin)
endif()

set(GIT_VERSION "2.50.1" CACHE STRING "Specify the version of GIT to be used")

include(${CMAKE_SOURCE_DIR}/curl.cmake)
include(${CMAKE_SOURCE_DIR}/git.cmake)
