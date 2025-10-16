# FindNETCDF.cmake
# -------------------
# Locates the NETCDF package.
# This will define the following variables:
# NETCDF_FOUND - System has NETCDF
# NETCDF_INCLUDE_DIRS - The NETCDF include directories
# NETCDF_LIBRARIES - The libraries needed to use NETCDF
# NETCDF_DIR - The directory of the found NETCDF installation

find_package(PkgConfig)
pkg_check_modules(PC_NETCDF QUIET NETCDF)

set(NETCDF_DIR "" CACHE PATH "The directory of the NETCDF installation")

find_path(NETCDF_INCLUDE_DIR NAMES netcdf_dispatch.h
          HINTS ${SEARCH_DEFAULTS} ${NETCDF_DIR} ${CMAKE_INSTALL_PREFIX}/netcdf/${NETCDF_VERSION}
          PATHS ${PC_NETCDF_INCLUDEDIR} ${PC_NETCDF_INCLUDE_DIRS}
          PATH_SUFFIXES include/netcdf include
        )

find_library(NETCDF_LIBRARY NAMES netcdf
             HINTS ${SEARCH_DEFAULTS} ${NETCDF_DIR} ${CMAKE_INSTALL_PREFIX}/netcdf/${NETCDF_VERSION}
             PATHS ${PC_NETCDF_LIBDIR} ${PC_NETCDF_LIBRARY_DIRS}
             PATH_SUFFIXES lib lib64
           )

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(NETCDF DEFAULT_MSG NETCDF_LIBRARY NETCDF_INCLUDE_DIR)

if(NETCDF_FOUND)
  set(NETCDF_LIBRARIES ${NETCDF_LIBRARY})
  set(NETCDF_INCLUDE_DIRS ${NETCDF_INCLUDE_DIR})

  get_filename_component(NETCDF_DIR "${NETCDF_LIBRARY}" DIRECTORY)
  get_filename_component(NETCDF_DIR "${NETCDF_DIR}" DIRECTORY)
endif()

mark_as_advanced(NETCDF_INCLUDE_DIR NETCDF_LIBRARY)
