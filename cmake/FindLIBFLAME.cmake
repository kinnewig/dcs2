# FindLIBFLAME.cmake
# -------------------
# Locates the LIBFLAME package.
# This will define the following variables:
# LIBFLAME_FOUND - System has LIBFLAME
# LIBFLAME_INCLUDE_DIRS - The LIBFLAME include directories
# LIBFLAME_LIBRARIES - The libraries needed to use LIBFLAME
# LIBFLAME_DIR - The directory of the found LIBFLAME installation

find_package(PkgConfig)
pkg_check_modules(PC_LIBFLAME QUIET LIBFLAME)

set(LIBFLAME_DIR "" CACHE PATH "The directory of the LIBFLAME installation")

find_path(LIBFLAME_INCLUDE_DIR NAMES libflame.h
          HINTS ${LIBFLAME_DIR}/include ${CMAKE_INSTALL_PREFIX}/libflame/${LIBFLAME_VERSION}/include/libflame
          PATHS ${PC_LIBFLAME_INCLUDEDIR} ${PC_LIBFLAME_INCLUDE_DIRS})

find_library(LIBFLAME_LIBRARY NAMES libflame
             HINTS ${LIBFLAME_DIR}/lib ${CMAKE_INSTALL_PREFIX}/libflame/${LIBFLAME_VERSION}/lib
             PATHS ${PC_LIBFLAME_LIBDIR} ${PC_LIBFLAME_LIBRARY_DIRS})

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(LIBFLAME DEFAULT_MSG LIBFLAME_LIBRARY LIBFLAME_INCLUDE_DIR)

if(LIBFLAME_FOUND)
  set(LIBFLAME_LIBRARIES ${LIBFLAME_LIBRARY})
  set(LIBFLAME_INCLUDE_DIRS ${LIBFLAME_INCLUDE_DIR})

  get_filename_component(LIBFLAME_DIR "${LIBFLAME_LIBRARY}" DIRECTORY)
  get_filename_component(LIBFLAME_DIR "${LIBFLAME_DIR}" DIRECTORY)
endif()

mark_as_advanced(LIBFLAME_INCLUDE_DIR LIBFLAME_LIBRARY)
