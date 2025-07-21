# FindSLEPC.cmake
# -------------------
# Locates the SLEPC package.
# This will define the following variables:
# SLEPC_FOUND - System has PETSc
# SLEPC_INCLUDE_DIRS - The PETSc include directories
# SLEPC_LIBRARIES - The libraries needed to use PETSc
# SLEPC_DIR - The directory of the found PETSc installation

find_package(PkgConfig)
pkg_check_modules(PC_SLEPC QUIET SLEPC)

set(SLEPC_DIR "" CACHE PATH "The directory of the Trilinos installation")

# TODO: Look for a specific version file:
find_path(SLEPC_INCLUDE_DIR NAMES slepc.h
  HINTS ${SLEPC_DIR}/include ${CMAKE_INSTALL_PREFIX}/slepc/${SLEPC_VERSION}/include 
  PATHS ${PC_SLEPC_INCLUDEDIR} ${PC_SLEPC_INCLUDE_DIRS})

find_library(SLEPC_LIBRARY NAMES libslepc.so
  HINTS ${SLEPC_DIR} ${CMAKE_INSTALL_PREFIX}/slepc/${SLEPC_VERSION}
  PATHS ${PC_SLEPC_LIBDIR} ${PC_SLEPC_LIBRARY_DIRS}
  PATH_SUFFIXES lib lib64
)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(SLEPC DEFAULT_MSG SLEPC_LIBRARY SLEPC_INCLUDE_DIR)

if(SLEPC_FOUND)
  set(SLEPC_LIBRARIES ${SLEPC_LIBRARY})
  set(SLEPC_INCLUDE_DIRS ${SLEPC_INCLUDE_DIR})

  get_filename_component(SLEPC_DIR "${SLEPC_LIBRARY}" DIRECTORY)
  get_filename_component(SLEPC_DIR ${SLEPC_DIR} DIRECTORY)
endif()

mark_as_advanced(SLEPC_INCLUDE_DIR SLEPC_LIBRARY)
