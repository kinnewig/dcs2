# FindADOLC.cmake
# -------------------
# Locates the ADOLC package.
# This will define the following variables:
# ADOLC_FOUND - System has ADOLC
# ADOLC_INCLUDE_DIRS - The ADOLC include directories
# ADOLC_LIBRARIES - The libraries needed to use ADOLC
# ADOLC_DIR - The directory of the found ADOLC installation

find_package(PkgConfig)
pkg_check_modules(PC_ADOLC QUIET ADOLC)

set(ADOLC_DIR "" CACHE PATH "The directory of the ADOLC installation")

find_path(ADOLC_INCLUDE_DIR NAMES adolc.h
          HINTS ${ADOLC_DIR}/include ${CMAKE_INSTALL_PREFIX}/adolc/${ADOLC_VERSION}/include
          PATHS ${PC_ADOLC_INCLUDEDIR} ${PC_ADOLC_INCLUDE_DIRS}
          PATH_SUFFIXES adolc
         )

find_library(ADOLC_LIBRARY NAMES libadolc.so
             HINTS ${ADOLC_DIR} ${CMAKE_INSTALL_PREFIX}/adolc/${ADOLC_VERSION}
             PATHS ${PC_ADOLC_LIBDIR} ${PC_ADOLC_LIBRARY_DIRS}
             PATH_SUFFIXES lib lib64
           )

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(ADOLC DEFAULT_MSG ADOLC_LIBRARY ADOLC_INCLUDE_DIR)

if(ADOLC_FOUND)
  set(ADOLC_LIBRARIES ${ADOLC_LIBRARY})
  set(ADOLC_INCLUDE_DIRS ${ADOLC_INCLUDE_DIR})

  get_filename_component(ADOLC_DIR "${ADOLC_LIBRARY}" DIRECTORY)
  get_filename_component(ADOLC_DIR "${ADOLC_DIR}" DIRECTORY)
endif()

mark_as_advanced(ADOLC_INCLUDE_DIR ADOLC_LIBRARY)
