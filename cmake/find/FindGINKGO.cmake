# FindGINKGO.cmake
# -------------------
# Locates the ginkgo package.
# This will define the following variables:
# GINKGO_FOUND - System has ginkgo
# GINKGO_INCLUDE_DIRS - The ginkgo include directories
# GINKGO_LIBRARIES - The libraries needed to use ginkgo
# GINKGO_DIR - The directory of the found ginkgo installation

find_package(PkgConfig)
pkg_check_modules(PC_GINKGO QUIET GINKGO)

set(GINKGO_DIR "" CACHE PATH "The directory of the ginkgo installation")

find_path(GINKGO_INCLUDE_DIR NAMES ginkgo.hpp
          HINTS ${SEARCH_DEFAULTS} ${GINKGO_DIR} ${CMAKE_INSTALL_PREFIX}/ginkgo/${GINKGO_VERSION}
          PATHS ${PC_GINKGO_INCLUDEDIR} ${PC_GINKGO_INCLUDE_DIRS}
          PATH_SUFFIXES include/ginkgo include
         )

find_library(GINKGO_LIBRARY NAMES ginkgo
             HINTS ${SEARCH_DEFAULTS} ${GINKGO_DIR} ${CMAKE_INSTALL_PREFIX}/ginkgo/${GINKGO_VERSION}
             PATHS ${PC_GINKGO_LIBDIR} ${PC_GINKGO_LIBRARY_DIRS}
             PATH_SUFFIXES lib lib64
           )

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(GINKGO DEFAULT_MSG GINKGO_LIBRARY GINKGO_INCLUDE_DIR)

if(GINKGO_FOUND)
  set(GINKGO_LIBRARIES ${GINKGO_LIBRARY})
  set(GINKGO_INCLUDE_DIRS ${GINKGO_INCLUDE_DIR})

  get_filename_component(GINKGO_DIR "${GINKGO_LIBRARY}" DIRECTORY)
  get_filename_component(GINKGO_DIR "${GINKGO_DIR}" DIRECTORY)
endif()

mark_as_advanced(GINKGO_INCLUDE_DIR GINKGO_LIBRARY)
