# FindP4EST.cmake
# -------------------
# Locates the P4EST package.
# This will define the following variables:
# P4EST_FOUND - System has P4EST
# P4EST_INCLUDE_DIRS - The P4EST include directories
# P4EST_LIBRARIES - The libraries needed to use P4EST
# P4EST_DIR - The directory of the found P4EST installation

find_package(PkgConfig)
pkg_check_modules(PC_P4EST QUIET P4EST)

set(P4EST_DIR "" CACHE PATH "The directory of the P4EST installation")

find_path(P4EST_INCLUDE_DIR NAMES p4est.h
          HINTS ${P4EST_DIR}/include ${CMAKE_INSTALL_PREFIX}/p4est/${P4EST_VERSION}/include
          PATHS ${PC_P4EST_INCLUDEDIR} ${PC_P4EST_INCLUDE_DIRS})

find_library(P4EST_LIBRARY NAMES p4est
             HINTS ${P4EST_DIR} ${CMAKE_INSTALL_PREFIX}/p4est/${P4EST_VERSION}
             PATHS ${PC_P4EST_LIBDIR} ${PC_P4EST_LIBRARY_DIRS}
             PATH_SUFFIXES lib lib64
           )

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(P4EST DEFAULT_MSG P4EST_LIBRARY P4EST_INCLUDE_DIR)

if(P4EST_FOUND)
  set(P4EST_LIBRARIES ${P4EST_LIBRARY})
  set(P4EST_INCLUDE_DIRS ${P4EST_INCLUDE_DIR})

  get_filename_component(P4EST_DIR "${P4EST_LIBRARY}" DIRECTORY)
  get_filename_component(P4EST_DIR "${P4EST_DIR}" DIRECTORY)
endif()

mark_as_advanced(P4EST_INCLUDE_DIR P4EST_LIBRARY)
