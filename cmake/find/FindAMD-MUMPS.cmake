# FindAMD-MUMPS.cmake
# -------------------
# Locates the AMD-MUMPS package.
# This will define the following variables:
# AMD-MUMPS_FOUND - System has AMD-MUMPS
# AMD-MUMPS_INCLUDE_DIRS - The AMD-MUMPS include directories
# AMD-MUMPS_LIBRARIES - The libraries needed to use AMD-MUMPS
# AMD-MUMPS_DIR - The directory of the found AMD-MUMPS installation

find_package(PkgConfig)
pkg_check_modules(PC_AMD-MUMPS QUIET AMD-MUMPS)

set(AMD-MUMPS_DIR "" CACHE PATH "The directory of the AMD-MUMPS installation")

find_path(AMD-MUMPS_INCLUDE_DIR NAMES dmumps_c.h
          HINTS ${SEARCH_DEFAULTS} ${AMD-MUMPS_DIR} ${CMAKE_INSTALL_PREFIX}/amd-mumps/${AMD-MUMPS_VERSION}
          PATHS ${PC_AMD-MUMPS_INCLUDEDIR} ${PC_AMD-MUMPS_INCLUDE_DIRS}
          PATH_SUFFIXES include include/mumps
        )

find_library(AMD-MUMPS_LIBRARY NAMES mumps_common
             HINTS ${SEARCH_DEFAULTS} ${AMD-MUMPS_DIR} ${CMAKE_INSTALL_PREFIX}/amd-mumps/${AMD-MUMPS_VERSION}
             PATHS ${PC_AMD-MUMPS_LIBDIR} ${PC_AMD-MUMPS_LIBRARY_DIRS}
             PATH_SUFFIXES lib lib64
           )

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(AMD-MUMPS DEFAULT_MSG AMD-MUMPS_LIBRARY AMD-MUMPS_INCLUDE_DIR)

if(AMD-MUMPS_FOUND)
  set(AMD-MUMPS_LIBRARIES ${AMD-MUMPS_LIBRARY})
  set(AMD-MUMPS_INCLUDE_DIRS ${AMD-MUMPS_INCLUDE_DIR})

  get_filename_component(AMD-MUMPS_DIR "${AMD-MUMPS_LIBRARY}" DIRECTORY)
  get_filename_component(AMD-MUMPS_DIR "${AMD-MUMPS_DIR}" DIRECTORY)
endif()

mark_as_advanced(AMD-MUMPS_INCLUDE_DIR AMD-MUMPS_LIBRARY)
