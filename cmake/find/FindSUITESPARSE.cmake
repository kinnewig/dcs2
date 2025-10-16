# FindSUITESPARSE.cmake
# -------------------
# Locates the SUITESPARSE package.
# This will define the following variables:
# SUITESPARSE_FOUND - System has SUITESPARSE
# SUITESPARSE_INCLUDE_DIRS - The SUITESPARSE include directories
# SUITESPARSE_LIBRARIES - The libraries needed to use SUITESPARSE
# SUITESPARSE_DIR - The directory of the found SUITESPARSE installation

find_package(PkgConfig)
pkg_check_modules(PC_SUITESPARSE QUIET SUITESPARSE)

set(SUITESPARSE_DIR "" CACHE PATH "The directory of the SUITESPARSE installation")

find_path(SUITESPARSE_INCLUDE_DIR NAMES umfpack.h
          HINTS ${SEARCH_DEFAULTS} ${SUITESPARSE_DIR} ${CMAKE_INSTALL_PREFIX}/suitesparse/${SUITESPARSE_VERSION}
          PATHS ${PC_SUITESPARSE_INCLUDEDIR} ${PC_SUITESPARSE_INCLUDE_DIRS}
          PATH_SUFFIXES include/suitesparse include
        )

find_library(SUITESPARSE_LIBRARY NAMES umfpack
             HINTS ${SEARCH_DEFAULTS} ${SUITESPARSE_DIR} ${CMAKE_INSTALL_PREFIX}/suitesparse/${SUITESPARSE_VERSION}
             PATHS ${PC_SUITESPARSE_LIBDIR} ${PC_SUITESPARSE_LIBRARY_DIRS}
             PATH_SUFFIXES lib lib64
           )

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(SUITESPARSE DEFAULT_MSG SUITESPARSE_LIBRARY SUITESPARSE_INCLUDE_DIR)

if(SUITESPARSE_FOUND)
  set(SUITESPARSE_LIBRARIES ${SUITESPARSE_LIBRARY})
  set(SUITESPARSE_INCLUDE_DIRS ${SUITESPARSE_INCLUDE_DIR})

  get_filename_component(SUITESPARSE_DIR "${SUITESPARSE_LIBRARY}" DIRECTORY)
  get_filename_component(SUITESPARSE_DIR "${SUITESPARSE_DIR}" DIRECTORY)
endif()

mark_as_advanced(SUITESPARSE_INCLUDE_DIR SUITESPARSE_LIBRARY)
