# FindTCL.cmake
# -------------------
# Locates the TCL package.
# This will define the following variables:
# TCL_FOUND - System has TCL
# TCL_INCLUDE_DIRS - The TCL include directories
# TCL_LIBRARIES - The libraries needed to use TCL
# TCL_DIR - The directory of the found TCL installation

find_package(PkgConfig)
pkg_check_modules(PC_TCL QUIET TCL)

set(TCL_DIR "" CACHE PATH "The directory of the TCL installation")

string(REGEX REPLACE "\\.[0-9]+$" "" TCL_VERSION_SHORT "${TCL_VERSION}")

find_path(TCL_INCLUDE_DIR NAMES tcl.h
          HINTS ${TCL_DIR}/include ${CMAKE_INSTALL_PREFIX}/tcl/${TCL_VERSION}/include
          PATHS ${PC_TCL_INCLUDEDIR} ${PC_TCL_INCLUDE_DIRS})

        find_library(TCL_LIBRARY NAMES tcl${TCL_VERSION_SHORT} tcl
     HINTS ${TCL_DIR}/lib ${CMAKE_INSTALL_PREFIX}/tcl/${TCL_VERSION}/lib
     PATHS ${PC_TCL_LIBDIR} ${PC_TCL_LIBRARY_DIRS})

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(TCL DEFAULT_MSG TCL_LIBRARY TCL_INCLUDE_DIR)

if(TCL_FOUND)
  set(TCL_LIBRARIES ${TCL_LIBRARY})
  set(TCL_INCLUDE_DIRS ${TCL_INCLUDE_DIR})

  get_filename_component(TCL_DIR "${TCL_LIBRARY}" DIRECTORY)
  get_filename_component(TCL_DIR "${TCL_DIR}" DIRECTORY)
endif()

mark_as_advanced(TCL_INCLUDE_DIR TCL_LIBRARY)
