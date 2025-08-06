# FindGSL.cmake
# -------------------
# Locates the GSL package.
# This will define the following variables:
# GSL_FOUND - System has GSL
# GSL_INCLUDE_DIRS - The GSL include directories
# GSL_LIBRARIES - The libraries needed to use GSL
# GSL_DIR - The directory of the found GSL installation

find_package(PkgConfig)
pkg_check_modules(PC_GSL QUIET GSL)

set(GSL_DIR "" CACHE PATH "The directory of the GSL installation")

find_path(GSL_INCLUDE_DIR NAMES gsl_version.h
          HINTS ${GSL_DIR}/include ${CMAKE_INSTALL_PREFIX}/gsl/${GSL_VERSION}/include/
          PATHS ${PC_GSL_INCLUDEDIR} ${PC_GSL_INCLUDE_DIRS}
          PATH_SUFFIXES gsl
        )

find_library(GSL_LIBRARY NAMES libgsl.so
             HINTS ${GSL_DIR} ${CMAKE_INSTALL_PREFIX}/gsl/${GSL_VERSION}
             PATHS ${PC_GSL_LIBDIR} ${PC_GSL_LIBRARY_DIRS}
             PATH_SUFFIXES lib lib64
           )

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(GSL DEFAULT_MSG GSL_LIBRARY GSL_INCLUDE_DIR)

if(GSL_FOUND)
  set(GSL_LIBRARIES ${GSL_LIBRARY})
  set(GSL_INCLUDE_DIRS ${GSL_INCLUDE_DIR})

  get_filename_component(GSL_DIR "${GSL_LIBRARY}" DIRECTORY)
  get_filename_component(GSL_DIR "${GSL_DIR}" DIRECTORY)

  # Version check
  # First, read the version from the header file
  file(STRINGS ${GSL_INCLUDE_DIR}/gsl.h _gsl_version_line
       REGEX "^#define GSL_VERSION_(MAJOR|MINOR|PATCHLEVEL) ")
  
  # Parse the version information
  string(REGEX REPLACE "^.*GSL_VERSION_MAJOR ([0-9]+).*$" "\\1" GSL_VERSION_MAJOR "${_gsl_version_line}")
  string(REGEX REPLACE "^.*GSL_VERSION_MINOR ([0-9]+).*$" "\\1" GSL_VERSION_MINOR "${_gsl_version_line}")
  string(REGEX REPLACE "^.*GSL_VERSION_PATCHLEVEL ([0-9]+).*$" "\\1" GSL_VERSION_PATCHLEVEL "${_gsl_version_line}")
  
  # Combine the version information
  set(FOUND_GSL_VERSION "${GSL_VERSION_MAJOR}.${GSL_VERSION_MINOR}.${GSL_VERSION_PATCHLEVEL}")

  # Check the version
  if(${FOUND_GSL_VERSION} VERSION_LESS ${GSL_FIND_VERSION})
    set(GSL_FOUND FALSE)
    message("    Found GSL version ${FOUND_GSL_VERSION}, mark GSL as not FOUND")
  endif()
endif()

mark_as_advanced(GSL_INCLUDE_DIR GSL_LIBRARY)
