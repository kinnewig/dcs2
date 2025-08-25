# FindMPFR.cmake
# -------------------
# Locates the MPFR package.
# This will define the following variables:
# MPFR_FOUND - System has MPFR
# MPFR_INCLUDE_DIRS - The MPFR include directories
# MPFR_LIBRARIES - The libraries needed to use MPFR
# MPFR_DIR - The directory of the found MPFR installation

find_package(PkgConfig)
pkg_check_modules(PC_MPFR QUIET MPFR)

set(MPFR_DIR "" CACHE PATH "The directory of the MPFR installation")

find_path(MPFR_INCLUDE_DIR NAMES mpfr.h
          HINTS ${MPFR_DIR}/include ${CMAKE_INSTALL_PREFIX}/mpfr/${MPFR_VERSION}/include/
          PATHS ${PC_MPFR_INCLUDEDIR} ${PC_MPFR_INCLUDE_DIRS})

find_library(MPFR_LIBRARY NAMES mpfr
             HINTS ${MPFR_DIR} ${CMAKE_INSTALL_PREFIX}/mpfr/${MPFR_VERSION}
             PATHS ${PC_MPFR_LIBDIR} ${PC_MPFR_LIBRARY_DIRS}
             PATH_SUFFIXES lib lib64
           )

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(MPFR DEFAULT_MSG MPFR_LIBRARY MPFR_INCLUDE_DIR)

if(MPFR_FOUND)
  set(MPFR_LIBRARIES ${MPFR_LIBRARY})
  set(MPFR_INCLUDE_DIRS ${MPFR_INCLUDE_DIR})

  get_filename_component(MPFR_DIR "${MPFR_LIBRARY}" DIRECTORY)
  get_filename_component(MPFR_DIR "${MPFR_DIR}" DIRECTORY)

# Skip version check
#  # Version check
#  # First, read the version from the header file
#  file(STRINGS ${MPFR_INCLUDE_DIR}/mpfr.h _mpfr_version_line
#       REGEX "^#define MPFR_VERSION_(MAJOR|MINOR|PATCHLEVEL) ")
#  
#  # Parse the version information
#  string(REGEX REPLACE "^.*MPFR_VERSION_MAJOR ([0-9]+).*$" "\\1" MPFR_VERSION_MAJOR "${_mpfr_version_line}")
#  string(REGEX REPLACE "^.*MPFR_VERSION_MINOR ([0-9]+).*$" "\\1" MPFR_VERSION_MINOR "${_mpfr_version_line}")
#  string(REGEX REPLACE "^.*MPFR_VERSION_PATCHLEVEL ([0-9]+).*$" "\\1" MPFR_VERSION_PATCHLEVEL "${_mpfr_version_line}")
#  
#  # Combine the version information
#  set(FOUND_MPFR_VERSION "${MPFR_VERSION_MAJOR}.${MPFR_VERSION_MINOR}.${MPFR_VERSION_PATCHLEVEL}")
#
#  # Check the version
#  if(${FOUND_MPFR_VERSION} VERSION_LESS ${MPFR_FIND_VERSION})
#    set(MPFR_FOUND FALSE)
#    message("    Found MPFR version ${FOUND_MPFR_VERSION}, mark MPFR as not FOUND")
#  endif()
endif()

mark_as_advanced(MPFR_INCLUDE_DIR MPFR_LIBRARY)
