# FindSCALAPACK.cmake
# -------------------
# Locates the SCALAPACK package.
# This will define the following variables:
# SCALAPACK_FOUND - System has SCALAPACK
# SCALAPACK_INCLUDE_DIRS - The SCALAPACK include directories
# SCALAPACK_LIBRARIES - The libraries needed to use SCALAPACK
# SCALAPACK_DIR - The directory of the found SCALAPACK installation

find_package(PkgConfig)
pkg_check_modules(PC_SCALAPACK QUIET SCALAPACK)

set(SCALAPACK_DIR "" CACHE PATH "The directory of the SCALAPACK installation")

#find_path(SCALAPACK_INCLUDE_DIR NAMES scalapack.h
#          HINTS ${SCALAPACK_DIR}/include ${CMAKE_INSTALL_PREFIX}/scalapack/${SCALAPACK_VERSION}/include
#          PATHS ${PC_SCALAPACK_INCLUDEDIR} ${PC_SCALAPACK_INCLUDE_DIRS})

find_library(SCALAPACK_LIBRARY NAMES scalapack
             HINTS ${SCALAPACK_DIR} ${CMAKE_INSTALL_PREFIX}/scalapack/${SCALAPACK_VERSION}
             PATHS ${PC_SCALAPACK_LIBDIR} ${PC_SCALAPACK_LIBRARY_DIRS}
             PATH_SUFFIXES lib lib64
           )

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(SCALAPACK DEFAULT_MSG SCALAPACK_LIBRARY)

if(SCALAPACK_FOUND)
  set(SCALAPACK_LIBRARIES ${SCALAPACK_LIBRARY})
  #set(SCALAPACK_INCLUDE_DIRS ${SCALAPACK_INCLUDE_DIR})

  get_filename_component(SCALAPACK_DIR "${SCALAPACK_LIBRARY}" DIRECTORY)
  get_filename_component(SCALAPACK_DIR "${SCALAPACK_DIR}" DIRECTORY)
endif()

mark_as_advanced(SCALAPACK_LIBRARY)
