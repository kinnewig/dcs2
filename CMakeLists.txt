cmake_minimum_required(VERSION 3.10)
project(dcs)

# Set versions for each package
set(SCALAPACK_VERSION "your_scalapack_version_here")
set(MUMPS_VERSION "your_mumps_version_here")
set(TRILINOS_VERSION "your_trilinos_version_here")

# Set paths for installation
set(INSTALL_PREFIX "${CMAKE_BINARY_DIR}/install")

include(scalapack.cmake)
include(mumps.cmake)
include(trilinos.cmake)
include(p4est.cmake)
include(dealii.cmake)
