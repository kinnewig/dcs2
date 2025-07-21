# FindSLEPSC.cmake
# -------------------
# Locates the SLEPSC package.
# This will define the following variables:
# SLEPSC_FOUND - System has PETSc
# SLEPSC_INCLUDE_DIRS - The PETSc include directories
# SLEPSC_LIBRARIES - The libraries needed to use PETSc
# SLEPSC_DIR - The directory of the found PETSc installation

find_package(PkgConfig)
pkg_check_modules(PC_SLEPSC QUIET SLEPSC)

set(SLEPSC_DIR "" CACHE PATH "The directory of the Trilinos installation")

# TODO: Look for a specific version file:
find_path(SLEPSC_INCLUDE_DIR NAMES slepscversion.h
  HINTS ${SLEPSC_DIR}/include ${CMAKE_INSTALL_PREFIX}/slepsc/${SLEPSC_VERSION}/include 
  PATHS ${PC_SLEPSC_INCLUDEDIR} ${PC_SLEPSC_INCLUDE_DIRS})

find_library(SLEPSC_LIBRARY NAMES libslepsc
  HINTS ${SLEPSC_DIR} ${CMAKE_INSTALL_PREFIX}/slepsc/${SLEPSC_VERSION}
  PATHS ${PC_SLEPSC_LIBDIR} ${PC_SLEPSC_LIBRARY_DIRS}
  PATH_SUFFIXES lib lib64
)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(SLEPSC DEFAULT_MSG SLEPSC_LIBRARY SLEPSC_INCLUDE_DIR)

if(SLEPSC_FOUND)
  set(SLEPSC_LIBRARIES ${SLEPSC_LIBRARY})
  set(SLEPSC_INCLUDE_DIRS ${SLEPSC_INCLUDE_DIR})

  get_filename_component(SLEPSC_DIR "${SLEPSC_LIBRARY}" DIRECTORY)
  get_filename_component(SLEPSC_DIR ${SLEPSC_DIR} DIRECTORY)
endif()

message("${SLEPSC_DIR}")

mark_as_advanced(SLEPSC_INCLUDE_DIR SLEPSC_LIBRARY)
