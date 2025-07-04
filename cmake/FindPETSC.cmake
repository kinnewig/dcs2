# FindPETSC.cmake
# -------------------
# Locates the PETSC package.
# This will define the following variables:
# PETSC_FOUND - System has PETSc
# PETSC_INCLUDE_DIRS - The PETSc include directories
# PETSC_LIBRARIES - The libraries needed to use PETSc
# PETSC_DIR - The directory of the found PETSc installation

find_package(PkgConfig)
pkg_check_modules(PC_PETSC QUIET PETSC)

set(PETSC_DIR "" CACHE PATH "The directory of the Trilinos installation")

# TODO: Look for a specific version file:
find_path(PETSC_INCLUDE_DIR NAMES petsc_version.h
  HINTS ${PETSC_DIR}/include ${CMAKE_INSTALL_PREFIX}/petsc/${PETSC_VERSION}/include 
  PATHS ${PC_PETSC_INCLUDEDIR} ${PC_PETSC_INCLUDE_DIRS})

find_library(PETSC_LIBRARY NAMES petsc 
  HINTS ${PETSC_DIR}/lib64 ${CMAKE_INSTALL_PREFIX}/petsc/${PETSC_VERSION}/lib64
  PATHS ${PC_PETSC_LIBDIR} ${PC_PETSC_LIBRARY_DIRS})

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(PETSC DEFAULT_MSG PETSC_LIBRARY PETSC_INCLUDE_DIR)

if(PETSC_FOUND)
  set(PETSC_LIBRARIES ${PETSC_LIBRARY})
  set(PETSC_INCLUDE_DIRS ${PETSC_INCLUDE_DIR})

  get_filename_component(PETSC_DIR "${PETSC_LIBRARY}" DIRECTORY)
  get_filename_component(PETSC_DIR ${PETSC_DIR} DIRECTORY)
endif()

message("${PETSC_DIR}")

mark_as_advanced(PETSC_INCLUDE_DIR PETSC_LIBRARY)
