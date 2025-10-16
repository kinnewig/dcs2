# FindAMD-BLIS.cmake
# -------------------
# Locates the AMD-BLIS package.
# This will define the following variables:
# AMD-BLIS_FOUND - System has AMD-BLIS
# AMD-BLIS_INCLUDE_DIRS - The AMD-BLIS include directories
# AMD-BLIS_LIBRARIES - The libraries needed to use AMD-BLIS
# AMD-BLIS_DIR - The directory of the found AMD-BLIS installation

find_package(PkgConfig)
pkg_check_modules(PC_AMD-BLIS QUIET AMD-BLIS)

set(AMD-BLIS_DIR "" CACHE PATH "The directory of the AMD-BLIS installation")

find_path(AMD-BLIS_INCLUDE_DIR NAMES blis.h
          HINTS ${SEARCH_DEFAULTS} ${AMD-BLIS_DIR} ${CMAKE_INSTALL_PREFIX}/amd-blis/${AMD-BLIS_VERSION}
          PATH_SUFFIXES include/blis include
          PATHS ${PC_AMD-BLIS_INCLUDEDIR} ${PC_AMD-BLIS_INCLUDE_DIRS})

find_library(AMD-BLIS_LIBRARY NAMES blis
             HINTS ${SEARCH_DEFAULTS} ${AMD-BLIS_DIR} ${CMAKE_INSTALL_PREFIX}/amd-blis/${AMD-BLIS_VERSION}
             PATH_SUFFIXES lib lib64
             PATHS ${PC_AMD-BLIS_LIBDIR} ${PC_AMD-BLIS_LIBRARY_DIRS})

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(AMD-BLIS DEFAULT_MSG AMD-BLIS_LIBRARY AMD-BLIS_INCLUDE_DIR)

if(AMD-BLIS_FOUND)
  set(AMD-BLIS_LIBRARIES ${AMD-BLIS_LIBRARY})
  set(AMD-BLIS_INCLUDE_DIRS ${AMD-BLIS_INCLUDE_DIR})

  get_filename_component(AMD-BLIS_DIR "${AMD-BLIS_LIBRARY}" DIRECTORY)
  get_filename_component(AMD-BLIS_DIR "${AMD-BLIS_DIR}" DIRECTORY)
endif()

mark_as_advanced(AMD-BLIS_INCLUDE_DIR AMD-BLIS_LIBRARY)
