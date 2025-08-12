# FindSUPERLU_DIST.cmake
# -------------------
# Locates the SUPERLU_DIST package.
# This will define the following variables:
# SUPERLU_DIST_FOUND - System has SUPERLU_DIST
# SUPERLU_DIST_INCLUDE_DIRS - The SUPERLU_DIST include directories
# SUPERLU_DIST_LIBRARIES - The libraries needed to use SUPERLU_DIST
# SUPERLU_DIST_DIR - The directory of the found SUPERLU_DIST installation

find_package(PkgConfig)
pkg_check_modules(PC_SUPERLU_DIST QUIET SUPERLU_DIST)

set(SUPERLU_DIST_DIR "" CACHE PATH "The directory of the SUPERLU_DIST installation")

find_path(SUPERLU_DIST_INCLUDE_DIR NAMES superlu_defs.h
          HINTS ${SUPERLU_DIST_DIR}/include ${CMAKE_INSTALL_PREFIX}/superlu_dist/${SUPERLU_DIST_VERSION}/include
          PATHS ${PC_SUPERLU_DIST_INCLUDEDIR} ${PC_SUPERLU_DIST_INCLUDE_DIRS}
          PATH_SUFFIXES superlu_dist
         )

find_library(SUPERLU_DIST_LIBRARY NAMES dsuperlu_dist.so
             HINTS ${SUPERLU_DIST_DIR} ${CMAKE_INSTALL_PREFIX}/superlu_dist/${SUPERLU_DIST_VERSION}
             PATHS ${PC_SUPERLU_DIST_LIBDIR} ${PC_SUPERLU_DIST_LIBRARY_DIRS}
             PATH_SUFFIXES lib lib64
           )

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(SUPERLU_DIST DEFAULT_MSG SUPERLU_DIST_LIBRARY SUPERLU_DIST_INCLUDE_DIR)

if(SUPERLU_DIST_FOUND)
  set(SUPERLU_DIST_LIBRARIES ${SUPERLU_DIST_LIBRARY})
  set(SUPERLU_DIST_INCLUDE_DIRS ${SUPERLU_DIST_INCLUDE_DIR})

  get_filename_component(SUPERLU_DIST_DIR "${SUPERLU_DIST_LIBRARY}" DIRECTORY)
  get_filename_component(SUPERLU_DIST_DIR "${SUPERLU_DIST_DIR}" DIRECTORY)
endif()

mark_as_advanced(SUPERLU_DIST_INCLUDE_DIR SUPERLU_DIST_LIBRARY)
