# FindZLIB-NG.cmake
# -------------------
# Locates the ZLIB-NG package.
# This will define the following variables:
# ZLIB-NG_FOUND - System has ZLIB-NG
# ZLIB-NG_INCLUDE_DIRS - The ZLIB-NG include directories
# ZLIB-NG_LIBRARIES - The libraries needed to use ZLIB-NG
# ZLIB-NG_DIR - The directory of the found ZLIB-NG installation

find_package(PkgConfig)
pkg_check_modules(PC_ZLIB-NG QUIET ZLIB-NG)

set(ZLIB-NG_DIR "" CACHE PATH "The directory of the ZLIB-NG installation")

find_path(ZLIB-NG_INCLUDE_DIR NAMES zlib.h
          HINTS ${SEARCH_DEFAULTS} ${ZLIB-NG_DIR} ${CMAKE_INSTALL_PREFIX}/zlib-ng/${ZLIB-NG_VERSION}
          PATHS ${PC_ZLIB-NG_INCLUDEDIR} ${PC_ZLIB-NG_INCLUDE_DIRS}
          PATH_SUFFIXES include/zlib include
        )

find_library(ZLIB-NG_LIBRARY NAMES z
             HINTS ${SEARCH_DEFAULTS} ${ZLIB-NG_DIR} ${CMAKE_INSTALL_PREFIX}/zlib-ng/${ZLIB-NG_VERSION}
             PATHS ${PC_ZLIB-NG_LIBDIR} ${PC_ZLIB-NG_LIBRARY_DIRS}
             PATH_SUFFIXES lib lib64
           )

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(ZLIB-NG DEFAULT_MSG ZLIB-NG_LIBRARY ZLIB-NG_INCLUDE_DIR)

if(ZLIB-NG_FOUND)
  set(ZLIB-NG_LIBRARIES ${ZLIB-NG_LIBRARY})
  set(ZLIB-NG_INCLUDE_DIRS ${ZLIB-NG_INCLUDE_DIR})

  get_filename_component(ZLIB-NG_DIR "${ZLIB-NG_LIBRARY}" DIRECTORY)
  get_filename_component(ZLIB-NG_DIR "${ZLIB-NG_DIR}" DIRECTORY)
endif()

mark_as_advanced(ZLIB-NG_INCLUDE_DIR ZLIB-NG_LIBRARY)
