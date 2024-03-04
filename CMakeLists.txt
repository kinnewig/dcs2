cmake_minimum_required(VERSION 3.10)
project(dcs)

# We do not allow in place builds:
if(CMAKE_SOURCE_DIR STREQUAL CMAKE_BINARY_DIR)
  message(FATAL_ERROR "Please use out of source build like:
  cmake -B build")
endif()

# Add the Find<PACKAGE>.cmake files from dcs to CMAKE_MODULE_PATH
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

# Options
option(DEALII_WITH_COMPLEX "Build deal.II with support for complex numbers" OFF)

# Set versions for each package
set(BLIS_VERSION "0.9.0")
set(SCALAPACK_VERSION "2.2.1")
set(MUMPS_VERSION "5.6.2")
set(P4EST_VERSION "2.8.5")
set(TRILINOS_VERSION "15.1.0")
set(DEALII_VERSION "master")

# Build Tool
set(DEFAULT_GENERATOR "Ninja")

#Compiler
set(CMAKE_Fortran_COMPILER "mpifort")
set(CMAKE_C_COMPILER "mpicc")
set(CMAKE_CXX_COMPILER "mpicxx")

#include(cmake/blis.cmake)
include(cmake/scalapack.cmake)
include(cmake/mumps.cmake)
include(cmake/trilinos.cmake)
include(cmake/p4est.cmake)
include(cmake/dealii.cmake)
