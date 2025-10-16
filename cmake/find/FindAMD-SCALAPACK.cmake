# FindAMD-SCALAPACK.cmake
# -------------------
# Locates the AMD-SCALAPACK package.
# This will define the following variables:
# AMD-SCALAPACK_FOUND - System has AMD-SCALAPACK
# AMD-SCALAPACK_INCLUDE_DIRS - The AMD-SCALAPACK include directories
# AMD-SCALAPACK_LIBRARIES - The libraries needed to use AMD-SCALAPACK
# AMD-SCALAPACK_DIR - The directory of the found AMD-SCALAPACK installation

find_package(PkgConfig)
pkg_check_modules(PC_AMD-SCALAPACK QUIET AMD-SCALAPACK)

set(AMD-SCALAPACK_DIR "" CACHE PATH "The directory of the AMD-SCALAPACK installation")

find_library(AMD-SCALAPACK_LIBRARY NAMES scalapack
             HINTS ${SEARCH_DEFAULTS} ${AMD-SCALAPACK_DIR} ${CMAKE_INSTALL_PREFIX}/amd-scalapack/${AMD-SCALAPACK_VERSION}
             PATHS ${PC_AMD-SCALAPACK_LIBDIR} ${PC_AMD-SCALAPACK_LIBRARY_DIRS}
             PATH_SUFFIXES lib lib64
           )

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(AMD-SCALAPACK DEFAULT_MSG AMD-SCALAPACK_LIBRARY)

if(AMD-SCALAPACK_FOUND)
  set(AMD-SCALAPACK_LIBRARIES ${AMD-SCALAPACK_LIBRARY})
  #set(AMD-SCALAPACK_INCLUDE_DIRS ${AMD-SCALAPACK_INCLUDE_DIR})

  get_filename_component(AMD-SCALAPACK_DIR "${AMD-SCALAPACK_LIBRARY}" DIRECTORY)
  get_filename_component(AMD-SCALAPACK_DIR "${AMD-SCALAPACK_DIR}" DIRECTORY)
endif()

mark_as_advanced(AMD-SCALAPACK_LIBRARY)
