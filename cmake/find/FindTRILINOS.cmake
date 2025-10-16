# FindTRILINOS.cmake
# -------------------
# Locates the Trilinos package.
# This will define the following variables:
# TRILINOS_FOUND - System has Trilinos
# TRILINOS_INCLUDE_DIRS - The Trilinos include directories
# TRILINOS_LIBRARIES - The libraries needed to use Trilinos
# TRILINOS_DIR - The directory of the found Trilinos installation

find_package(PkgConfig)
pkg_check_modules(PC_TRILINOS QUIET TRILINOS)

set(TRILINOS_DIR "" CACHE PATH "The directory of the Trilinos installation")

find_path(TRILINOS_INCLUDE_DIR NAMES Trilinos_version.h
          HINTS ${SEARCH_DEFAULTS} ${TRILINOS_DIR} ${CMAKE_INSTALL_PREFIX}/trilinos/${TRILINOS_VERSION}
          PATHS ${PC_TRILINOS_INCLUDEDIR} ${PC_TRILINOS_INCLUDE_DIRS}
          PATH_SUFFIXES include/trilinos include 
         )

find_library(TRILINOS_LIBRARY NAMES trilinosss
             HINTS ${SEARCH_DEFAULTS} ${TRILINOS_DIR} ${CMAKE_INSTALL_PREFIX}/trilinos/${TRILINOS_VERSION}
             PATHS ${PC_TRILINOS_LIBDIR} ${PC_TRILINOS_LIBRARY_DIRS}
             PATH_SUFFIXES lib lib64
            )

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(TRILINOS DEFAULT_MSG TRILINOS_LIBRARY TRILINOS_INCLUDE_DIR)

if(TRILINOS_FOUND)
  set(TRILINOS_LIBRARIES ${TRILINOS_LIBRARY})
  set(TRILINOS_INCLUDE_DIRS ${TRILINOS_INCLUDE_DIR})

  get_filename_component(TRILINOS_DIR "${TRILINOS_LIBRARY}" DIRECTORY)
  get_filename_component(TRILINOS_DIR ${TRILINOS_DIR} DIRECTORY)
endif()

mark_as_advanced(TRILINOS_INCLUDE_DIR TRILINOS_LIBRARY)
