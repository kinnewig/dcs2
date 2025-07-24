# FindARPACK-NG.cmake
# -------------------
# Locates the ARPACK-NG package.
# This will define the following variables:
# ARPACK-NG_FOUND - System has ARPACK-NG
# ARPACK-NG_INCLUDE_DIRS - The ARPACK-NG include directories
# ARPACK-NG_LIBRARIES - The libraries needed to use ARPACK-NG
# ARPACK-NG_DIR - The directory of the found ARPACK-NG installation

find_package(PkgConfig)
pkg_check_modules(PC_ARPACK-NG QUIET ARPACK-NG)

set(ARPACK-NG_DIR "" CACHE PATH "The directory of the ARPACK-NG installation")

find_path(ARPACK-NG_INCLUDE_DIR NAMES arpackdef.h
          HINTS ${ARPACK-NG_DIR}/include ${CMAKE_INSTALL_PREFIX}/arpack-ng/${ARPACK-NG_VERSION}/include
          PATHS ${PC_ARPACK-NG_INCLUDEDIR} ${PC_ARPACK-NG_INCLUDE_DIRS}
          PATH_SUFFIXES arpack
        )

find_library(ARPACK-NG_LIBRARY NAMES libarpack.so
             HINTS ${ARPACK-NG_DIR} ${CMAKE_INSTALL_PREFIX}/arpack-ng/${ARPACK-NG_VERSION}
             PATHS ${PC_ARPACK-NG_LIBDIR} ${PC_ARPACK-NG_LIBRARY_DIRS}
             PATH_SUFFIXES lib lib64
           )

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(ARPACK-NG DEFAULT_MSG ARPACK-NG_LIBRARY ARPACK-NG_INCLUDE_DIR)

if(ARPACK-NG_FOUND)
  set(ARPACK-NG_LIBRARIES ${ARPACK-NG_LIBRARY})
  set(ARPACK-NG_INCLUDE_DIRS ${ARPACK-NG_INCLUDE_DIR})

  get_filename_component(ARPACK-NG_DIR "${ARPACK-NG_LIBRARY}" DIRECTORY)
  get_filename_component(ARPACK-NG_DIR "${ARPACK-NG_DIR}" DIRECTORY)
endif()

mark_as_advanced(ARPACK-NG_INCLUDE_DIR ARPACK-NG_LIBRARY)
