# FindMUPARSER.cmake
# -------------------
# Locates the MUPARSER package.
# This will define the following variables:
# MUPARSER_FOUND - System has MUPARSER
# MUPARSER_INCLUDE_DIRS - The MUPARSER include directories
# MUPARSER_LIBRARIES - The libraries needed to use MUPARSER
# MUPARSER_DIR - The directory of the found MUPARSER installation

find_package(PkgConfig)
pkg_check_modules(PC_MUPARSER QUIET MUPARSER)

set(MUPARSER_DIR "" CACHE PATH "The directory of the MUPARSER installation")

find_path(MUPARSER_INCLUDE_DIR NAMES muParser.h
          HINTS ${MUPARSER_DIR}/include ${CMAKE_INSTALL_PREFIX}/muparser/${MUPARSER_VERSION}/include
          PATHS ${PC_MUPARSER_INCLUDEDIR} ${PC_MUPARSER_INCLUDE_DIRS}
          PATH_SUFFIXES muParser
        )

find_library(MUPARSER_LIBRARY NAMES libmuparser.so
             HINTS ${MUPARSER_DIR} ${CMAKE_INSTALL_PREFIX}/muparser/${MUPARSER_VERSION}
             PATHS ${PC_MUPARSER_LIBDIR} ${PC_MUPARSER_LIBRARY_DIRS}
             PATH_SUFFIXES lib lib64
           )

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(MUPARSER DEFAULT_MSG MUPARSER_LIBRARY MUPARSER_INCLUDE_DIR)

if(MUPARSER_FOUND)
  set(MUPARSER_LIBRARIES ${MUPARSER_LIBRARY})
  set(MUPARSER_INCLUDE_DIRS ${MUPARSER_INCLUDE_DIR})

  get_filename_component(MUPARSER_DIR "${MUPARSER_LIBRARY}" DIRECTORY)
  get_filename_component(MUPARSER_DIR "${MUPARSER_DIR}" DIRECTORY)
endif()

mark_as_advanced(MUPARSER_INCLUDE_DIR MUPARSER_LIBRARY)
