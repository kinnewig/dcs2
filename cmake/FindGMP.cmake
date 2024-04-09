# FindGMP.cmake
# -------------------
# Locates the GMP package.
# This will define the following variables:
# GMP_FOUND - System has GMP
# GMP_INCLUDE_DIRS - The GMP include directories
# GMP_LIBRARIES - The libraries needed to use GMP
# GMP_DIR - The directory of the found GMP installation

find_package(PkgConfig)
pkg_check_modules(PC_GMP QUIET GMP)

set(GMP_DIR "" CACHE PATH "The directory of the GMP installation")

find_path(GMP_INCLUDE_DIR NAMES gmp.h
          HINTS ${GMP_DIR}/include ${CMAKE_INSTALL_PREFIX}/gmp/${GMP_VERSION}/include/gmp
          PATHS ${PC_GMP_INCLUDEDIR} ${PC_GMP_INCLUDE_DIRS})

find_library(GMP_LIBRARY NAMES gmp
             HINTS ${GMP_DIR}/lib ${CMAKE_INSTALL_PREFIX}/gmp/${GMP_VERSION}/lib
             PATHS ${PC_GMP_LIBDIR} ${PC_GMP_LIBRARY_DIRS})

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(GMP DEFAULT_MSG GMP_LIBRARY GMP_INCLUDE_DIR)

if(GMP_FOUND)
  set(GMP_LIBRARIES ${GMP_LIBRARY})
  set(GMP_INCLUDE_DIRS ${GMP_INCLUDE_DIR})

  get_filename_component(GMP_DIR "${GMP_LIBRARY}" DIRECTORY)
  get_filename_component(GMP_DIR "${GMP_DIR}" DIRECTORY)
endif()

mark_as_advanced(GMP_INCLUDE_DIR GMP_LIBRARY)
