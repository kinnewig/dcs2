# FindAMD-LIBFLAME.cmake
# -------------------
# Locates the AMD-LIBFLAME package.
# This will define the following variables:
# AMD-LIBFLAME_FOUND - System has AMD-LIBFLAME
# AMD-LIBFLAME_INCLUDE_DIRS - The AMD-LIBFLAME include directories
# AMD-LIBFLAME_LIBRARIES - The libraries needed to use AMD-LIBFLAME
# AMD-LIBFLAME_DIR - The directory of the found AMD-LIBFLAME installation

find_package(PkgConfig)
pkg_check_modules(PC_AMD-LIBFLAME QUIET AMD-LIBFLAME)

set(AMD-LIBFLAME_DIR "" CACHE PATH "The directory of the AMD-LIBFLAME installation")

find_path(AMD-LIBFLAME_INCLUDE_DIR NAMES FLAME.h
          HINTS ${SEARCH_DEFAULTS} ${AMD-LIBFLAME_DIR} ${CMAKE_INSTALL_PREFIX}/amd-libflame/${AMD-LIBFLAME_VERSION}
          PATHS ${PC_AMD-LIBFLAME_INCLUDEDIR} ${PC_AMD-LIBFLAME_INCLUDE_DIRS}
          PATH_SUFFIXES include include/libflame
        )

find_library(AMD-LIBFLAME_LIBRARY NAMES flame
             HINTS ${SEARCH_DEFAULTS} ${AMD-LIBFLAME_DIR} ${CMAKE_INSTALL_PREFIX}/amd-libflame/${AMD-LIBFLAME_VERSION}
             PATHS ${PC_AMD-LIBFLAME_LIBDIR} ${PC_AMD-LIBFLAME_LIBRARY_DIRS}
             PATH_SUFFIXES lib lib64
           )

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(AMD-LIBFLAME DEFAULT_MSG AMD-LIBFLAME_LIBRARY AMD-LIBFLAME_INCLUDE_DIR)

if(AMD-LIBFLAME_FOUND)
  set(AMD-LIBFLAME_LIBRARIES ${AMD-LIBFLAME_LIBRARY})
  set(AMD-LIBFLAME_INCLUDE_DIRS ${AMD-LIBFLAME_INCLUDE_DIR})

  get_filename_component(AMD-LIBFLAME_DIR "${AMD-LIBFLAME_LIBRARY}" DIRECTORY)
  get_filename_component(AMD-LIBFLAME_DIR "${AMD-LIBFLAME_DIR}" DIRECTORY)
endif()

mark_as_advanced(AMD-LIBFLAME_INCLUDE_DIR AMD-LIBFLAME_LIBRARY)
