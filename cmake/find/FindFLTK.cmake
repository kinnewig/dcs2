# FindFLTK.cmake
# -------------------
# Locates the FLTK package.
# This will define the following variables:
# FLTK_FOUND - System has FLTK
# FLTK_INCLUDE_DIRS - The FLTK include directories
# FLTK_LIBRARIES - The libraries needed to use FLTK
# FLTK_DIR - The directory of the found FLTK installation

find_package(PkgConfig)
pkg_check_modules(PC_FLTK QUIET FLTK)

set(FLTK_DIR "" CACHE PATH "The directory of the FLTK installation")

find_path(FLTK_INCLUDE_DIR NAMES Fl.H
          HINTS ${SEARCH_DEFAULTS} ${FLTK_DIR} ${CMAKE_INSTALL_PREFIX}/fltk/${FLTK_VERSION}
          PATHS ${PC_FLTK_INCLUDEDIR} ${PC_FLTK_INCLUDE_DIRS}
          PATH_SUFFIXES include/FL include/fltk include
        )

find_library(FLTK_LIBRARY NAMES fltk
             HINTS ${SEARCH_DEFAULTS} ${FLTK_DIR} ${CMAKE_INSTALL_PREFIX}/fltk/${FLTK_VERSION}
             PATHS ${PC_FLTK_LIBDIR} ${PC_FLTK_LIBRARY_DIRS}
             PATH_SUFFIXES lib lib64
           )

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(FLTK DEFAULT_MSG FLTK_LIBRARY FLTK_INCLUDE_DIR)

if(FLTK_FOUND)
  set(FLTK_LIBRARIES ${FLTK_LIBRARY})
  set(FLTK_INCLUDE_DIRS ${FLTK_INCLUDE_DIR})

  get_filename_component(FLTK_DIR "${FLTK_LIBRARY}" DIRECTORY)
  get_filename_component(FLTK_DIR "${FLTK_DIR}" DIRECTORY)
endif()

mark_as_advanced(FLTK_INCLUDE_DIR FLTK_LIBRARY)
