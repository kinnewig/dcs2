# FindTK.cmake
# -------------------
# Locates the TK package.
# This will define the following variables:
# TK_FOUND - System has TK
# TK_INCLUDE_DIRS - The TK include directories
# TK_LIBRARIES - The libraries needed to use TK
# TK_DIR - The directory of the found TK installation

find_package(PkgConfig)
pkg_check_modules(PC_TK QUIET TK)

set(TK_DIR "" CACHE PATH "The directory of the TK installation")

string(REGEX REPLACE "\\.[0-9]+$" "" TK_VERSION_SHORT "${TK_VERSION}")

find_path(TK_INCLUDE_DIR NAMES tk.h
          HINTS ${TK_DIR}/include ${CMAKE_INSTALL_PREFIX}/tk/${TK_VERSION}/include
          PATHS ${PC_TK_INCLUDEDIR} ${PC_TK_INCLUDE_DIRS})

        find_library(TK_LIBRARY NAMES tk${TK_VERSION_SHORT} tk
             HINTS ${TK_DIR}/lib ${CMAKE_INSTALL_PREFIX}/tk/${TK_VERSION}/lib
             PATHS ${PC_TK_LIBDIR} ${PC_TK_LIBRARY_DIRS})

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(TK DEFAULT_MSG TK_LIBRARY TK_INCLUDE_DIR)

if(TK_FOUND)
  set(TK_LIBRARIES ${TK_LIBRARY})
  set(TK_INCLUDE_DIRS ${TK_INCLUDE_DIR})

  get_filename_component(TK_DIR "${TK_LIBRARY}" DIRECTORY)
  get_filename_component(TK_DIR "${TK_DIR}" DIRECTORY)
endif()

mark_as_advanced(TK_INCLUDE_DIR TK_LIBRARY)
