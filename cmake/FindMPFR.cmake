# FindMPFR.cmake
# -------------------
# Locates the MPFR package.
# This will define the following variables:
# MPFR_FOUND - System has MPFR
# MPFR_INCLUDE_DIRS - The MPFR include directories
# MPFR_LIBRARIES - The libraries needed to use MPFR
# MPFR_DIR - The directory of the found MPFR installation

find_package(PkgConfig)
pkg_check_modules(PC_MPFR QUIET MPFR)

set(MPFR_DIR "" CACHE PATH "The directory of the MPFR installation")

find_path(MPFR_INCLUDE_DIR NAMES mpfr.h
          HINTS ${MPFR_DIR}/include ${CMAKE_INSTALL_PREFIX}/mpfr/${MPFR_VERSION}/include/mpfr
          PATHS ${PC_MPFR_INCLUDEDIR} ${PC_MPFR_INCLUDE_DIRS})

find_library(MPFR_LIBRARY NAMES mpfr
             HINTS ${MPFR_DIR}/lib ${CMAKE_INSTALL_PREFIX}/mpfr/${MPFR_VERSION}/lib
             PATHS ${PC_MPFR_LIBDIR} ${PC_MPFR_LIBRARY_DIRS})

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(MPFR DEFAULT_MSG MPFR_LIBRARY MPFR_INCLUDE_DIR)

if(MPFR_FOUND)
  set(MPFR_LIBRARIES ${MPFR_LIBRARY})
  set(MPFR_INCLUDE_DIRS ${MPFR_INCLUDE_DIR})

  get_filename_component(MPFR_DIR "${MPFR_LIBRARY}" DIRECTORY)
  get_filename_component(MPFR_DIR "${MPFR_DIR}" DIRECTORY)
endif()

mark_as_advanced(MPFR_INCLUDE_DIR MPFR_LIBRARY)
