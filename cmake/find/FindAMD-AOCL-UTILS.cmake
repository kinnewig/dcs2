# FindAMD-AOCL-UTILS.cmake
# -------------------
# Locates the AMD-AOCL-UTILS package.
# This will define the following variables:
# AMD-AOCL-UTILS_FOUND - System has AMD-AOCL-UTILS
# AMD-AOCL-UTILS_INCLUDE_DIRS - The AMD-AOCL-UTILS include directories
# AMD-AOCL-UTILS_LIBRARIES - The libraries needed to use AMD-AOCL-UTILS
# AMD-AOCL-UTILS_DIR - The directory of the found AMD-AOCL-UTILS installation

find_package(PkgConfig)
pkg_check_modules(PC_AMD-AOCL-UTILS QUIET AMD-AOCL-UTILS)

set(AMD-AOCL-UTILS_DIR "" CACHE PATH "The directory of the AMD-AOCL-UTILS installation")

find_path(AMD-AOCL-UTILS_INCLUDE_DIR NAMES Au.hh
          HINTS ${SEARCH_DEFAULTS} ${AMD-AOCL-UTILS_DIR} ${CMAKE_INSTALL_PREFIX}/amd-aocl-utils/${AMD-AOCL-UTILS_VERSION}
          PATHS ${PC_AMD-AOCL-UTILS_INCLUDEDIR} ${PC_AMD-AOCL-UTILS_INCLUDE_DIRS}
          PATH_SUFFIXES include include/Au 
        )

find_library(AMD-AOCL-UTILS_LIBRARY NAMES aoclutils
             HINTS ${SEARCH_DEFAULTS} ${AMD-AOCL-UTILS_DIR} ${CMAKE_INSTALL_PREFIX}/amd-aocl-utils/${AMD-AOCL-UTILS_VERSION}
             PATHS ${PC_AMD-AOCL-UTILS_LIBDIR} ${PC_AMD-AOCL-UTILS_LIBRARY_DIRS}
             PATH_SUFFIXES lib lib64
           )

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(AMD-AOCL-UTILS DEFAULT_MSG AMD-AOCL-UTILS_LIBRARY AMD-AOCL-UTILS_INCLUDE_DIR)

if(AMD-AOCL-UTILS_FOUND)
  set(AMD-AOCL-UTILS_LIBRARIES ${AMD-AOCL-UTILS_LIBRARY})
  set(AMD-AOCL-UTILS_INCLUDE_DIRS ${AMD-AOCL-UTILS_INCLUDE_DIR})

  get_filename_component(AMD-AOCL-UTILS_DIR "${AMD-AOCL-UTILS_LIBRARY}" DIRECTORY)
  get_filename_component(AMD-AOCL-UTILS_DIR "${AMD-AOCL-UTILS_DIR}" DIRECTORY)
endif()

mark_as_advanced(AMD-AOCL-UTILS_INCLUDE_DIR AMD-AOCL-UTILS_LIBRARY)
