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
          HINTS ${GMP_DIR}/include ${CMAKE_INSTALL_PREFIX}/gmp/${GMP_VERSION}/include
          PATHS ${PC_GMP_INCLUDEDIR} ${PC_GMP_INCLUDE_DIRS}
          PATHS /usr/include /usr/local/include
          PATH_SUFFIXES gmp
        )

find_library(GMP_LIBRARY NAMES gmp
             HINTS ${GMP_DIR} ${CMAKE_INSTALL_PREFIX}/gmp/${GMP_VERSION}
             PATHS ${PC_GMP_LIBDIR} ${PC_GMP_LIBRARY_DIRS}
             PATHS /usr/lib /usr/local/lib
             PATH_SUFFIXES lib lib64
           )

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(GMP DEFAULT_MSG GMP_LIBRARY GMP_INCLUDE_DIR)

#if(GMP_FOUND)
#  set(GMP_LIBRARIES ${GMP_LIBRARY})
#  set(GMP_INCLUDE_DIRS ${GMP_INCLUDE_DIR})
#
#  get_filename_component(GMP_DIR "${GMP_LIBRARY}" DIRECTORY)
#  get_filename_component(GMP_DIR "${GMP_DIR}" DIRECTORY)
#
#  # Version check
#  # First, read the version from the header file
#  if(EXISTS "${GMP_INCLUDE_DIR}/gmp.h")
#    set(gmp_version_file "${GMP_INCLUDE_DIR}/gmp.h")
#  else()
#    set(gmp_version_file "${GMP_INCLUDE_DIR}/gmp-x86_64.h")
#  endif()
#  file(STRINGS ${GMP_INCLUDE_DIR}/gmp.h _gmp_version_line
#       REGEX "^#define __GNU_MP_VERSION.*|^#define __GNU_MP_VERSION_MINOR.*|^#define __GNU_MP_VERSION_PATCHLEVEL.*")
#  
#  # Parse the version information
#  string(REGEX REPLACE "^.*__GNU_MP_VERSION *([0-9]+).*$" "\\1" GMP_VERSION_MAJOR "${_gmp_version_line}")
#  string(REGEX REPLACE "^.*__GNU_MP_VERSION_MINOR *([0-9]+).*$" "\\1" GMP_VERSION_MINOR "${_gmp_version_line}")
#  string(REGEX REPLACE "^.*__GNU_MP_VERSION_PATCHLEVEL *([0-9]+).*$" "\\1" GMP_VERSION_PATCHLEVEL "${_gmp_version_line}")
#  
#  # Combine the version information
#  set(FOUND_GMP_VERSION "${GMP_VERSION_MAJOR}.${GMP_VERSION_MINOR}.${GMP_VERSION_PATCHLEVEL}")
#
#  # Check the version
#  if(${FOUND_GMP_VERSION} VERSION_LESS ${GMP_FIND_VERSION})
#    set(GMP_FOUND FALSE)
#    message("    Found GMP version ${FOUND_GMP_VERSION}, mark GMP as not FOUND")
#  endif()
#
#endif()

mark_as_advanced(GMP_INCLUDE_DIR GMP_LIBRARY)
