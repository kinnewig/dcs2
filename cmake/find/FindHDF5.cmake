# FindHDF5.cmake
# -------------------
# Locates the HDF5 package.
# This will define the following variables:
# HDF5_FOUND - System has HDF5
# HDF5_INCLUDE_DIRS - The HDF5 include directories
# HDF5_LIBRARIES - The libraries needed to use HDF5
# HDF5_DIR - The directory of the found HDF5 installation

find_package(PkgConfig)
pkg_check_modules(PC_HDF5 QUIET HDF5)

set(HDF5_DIR "" CACHE PATH "The directory of the HDF5 installation")

find_path(HDF5_INCLUDE_DIR NAMES H5version.h
          HINTS ${HDF5_DIR}/include ${CMAKE_INSTALL_PREFIX}/hdf5/${HDF5_VERSION}/include
          PATHS ${PC_HDF5_INCLUDEDIR} ${PC_HDF5_INCLUDE_DIRS})

find_library(HDF5_LIBRARY NAMES libhdf5.so
             HINTS ${HDF5_DIR} ${CMAKE_INSTALL_PREFIX}/hdf5/${HDF5_VERSION}
             PATHS ${PC_HDF5_LIBDIR} ${PC_HDF5_LIBRARY_DIRS}
             PATH_SUFFIXES lib lib64
           )

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(HDF5 DEFAULT_MSG HDF5_LIBRARY HDF5_INCLUDE_DIR)

if(HDF5_FOUND)
  set(HDF5_LIBRARIES ${HDF5_LIBRARY})
  set(HDF5_INCLUDE_DIRS ${HDF5_INCLUDE_DIR})

  get_filename_component(HDF5_DIR "${HDF5_LIBRARY}" DIRECTORY)
  get_filename_component(HDF5_DIR "${HDF5_DIR}" DIRECTORY)
endif()

mark_as_advanced(HDF5_INCLUDE_DIR HDF5_LIBRARY)
