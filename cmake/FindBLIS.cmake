# FindBLIS.cmake
# -------------------
# Locates the BLIS package.
# This will define the following variables:
# BLIS_FOUND - System has BLIS
# BLIS_INCLUDE_DIRS - The BLIS include directories
# BLIS_LIBRARIES - The libraries needed to use BLIS
# BLIS_DIR - The directory of the found BLIS installation

find_package(PkgConfig)
pkg_check_modules(PC_BLIS QUIET BLIS)

set(BLIS_DIR "" CACHE PATH "The directory of the BLIS installation")

find_path(BLIS_INCLUDE_DIR NAMES blis.h
          HINTS ${BLIS_DIR}/include ${CMAKE_INSTALL_PREFIX}/blis/${BLIS_VERSION}/include/blis
          PATHS ${PC_BLIS_INCLUDEDIR} ${PC_BLIS_INCLUDE_DIRS})

find_library(BLIS_LIBRARY NAMES blis
             HINTS ${BLIS_DIR}/lib ${CMAKE_INSTALL_PREFIX}/blis/${BLIS_VERSION}/lib
             PATHS ${PC_BLIS_LIBDIR} ${PC_BLIS_LIBRARY_DIRS})

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(BLIS DEFAULT_MSG BLIS_LIBRARY BLIS_INCLUDE_DIR)

if(BLIS_FOUND)
  set(BLIS_LIBRARIES ${BLIS_LIBRARY})
  set(BLIS_INCLUDE_DIRS ${BLIS_INCLUDE_DIR})

  get_filename_component(BLIS_DIR "${BLIS_LIBRARY}" DIRECTORY)
  get_filename_component(BLIS_DIR "${BLIS_DIR}" DIRECTORY)
endif()

mark_as_advanced(BLIS_INCLUDE_DIR BLIS_LIBRARY)
