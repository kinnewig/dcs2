# FindSYMENGINE.cmake
# -------------------
# Locates the SYMENGINE package.
# This will define the following variables:
# SYMENGINE_FOUND - System has SYMENGINE
# SYMENGINE_INCLUDE_DIRS - The SYMENGINE include directories
# SYMENGINE_LIBRARIES - The libraries needed to use SYMENGINE
# SYMENGINE_DIR - The directory of the found SYMENGINE installation

find_package(PkgConfig)
pkg_check_modules(PC_SYMENGINE QUIET SYMENGINE)

set(SYMENGINE_DIR "" CACHE PATH "The directory of the SYMENGINE installation")

find_path(SYMENGINE_INCLUDE_DIR NAMES symengine_config.h
          HINTS ${SYMENGINE_DIR}/include ${CMAKE_INSTALL_PREFIX}/symengine/${SYMENGINE_VERSION}/include
          PATHS ${PC_SYMENGINE_INCLUDEDIR} ${PC_SYMENGINE_INCLUDE_DIRS}
          PATH_SUFFIXES symengine
        )

find_library(SYMENGINE_LIBRARY NAMES libsymengine.so
             HINTS ${SYMENGINE_DIR} ${CMAKE_INSTALL_PREFIX}/symengine/${SYMENGINE_VERSION}
             PATHS ${PC_SYMENGINE_LIBDIR} ${PC_SYMENGINE_LIBRARY_DIRS}
             PATH_SUFFIXES lib lib64
           )

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(SYMENGINE DEFAULT_MSG SYMENGINE_LIBRARY SYMENGINE_INCLUDE_DIR)

if(SYMENGINE_FOUND)
  set(SYMENGINE_LIBRARIES ${SYMENGINE_LIBRARY})
  set(SYMENGINE_INCLUDE_DIRS ${SYMENGINE_INCLUDE_DIR})

  get_filename_component(SYMENGINE_DIR "${SYMENGINE_LIBRARY}" DIRECTORY)
  get_filename_component(SYMENGINE_DIR "${SYMENGINE_DIR}" DIRECTORY)
endif()

mark_as_advanced(SYMENGINE_INCLUDE_DIR SYMENGINE_LIBRARY)
