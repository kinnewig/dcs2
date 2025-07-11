# FindMUMPS.cmake
# -------------------
# Locates the MUMPS package.
# This will define the following variables:
# MUMPS_FOUND - System has MUMPS
# MUMPS_INCLUDE_DIRS - The MUMPS include directories
# MUMPS_LIBRARIES - The libraries needed to use MUMPS
# MUMPS_DIR - The directory of the found MUMPS installation

find_package(PkgConfig)
pkg_check_modules(PC_MUMPS QUIET MUMPS)

set(MUMPS_DIR "" CACHE PATH "The directory of the MUMPS installation")

find_path(MUMPS_INCLUDE_DIR NAMES dmumps_c.h
          HINTS ${MUMPS_DIR}/include ${CMAKE_INSTALL_PREFIX}/mumps/${MUMPS_VERSION}/include
          PATHS ${PC_MUMPS_INCLUDEDIR} ${PC_MUMPS_INCLUDE_DIRS})

find_library(MUMPS_LIBRARY NAMES dmumps
             HINTS ${MUMPS_DIR} ${CMAKE_INSTALL_PREFIX}/mumps/${MUMPS_VERSION}
             PATHS ${PC_MUMPS_LIBDIR} ${PC_MUMPS_LIBRARY_DIRS}
             PATH_SUFFIXES lib lib64
           )

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(MUMPS DEFAULT_MSG MUMPS_LIBRARY MUMPS_INCLUDE_DIR)

if(MUMPS_FOUND)
  set(MUMPS_LIBRARIES ${MUMPS_LIBRARY})
  set(MUMPS_INCLUDE_DIRS ${MUMPS_INCLUDE_DIR})

  get_filename_component(MUMPS_DIR "${MUMPS_LIBRARY}" DIRECTORY)
  get_filename_component(MUMPS_DIR "${MUMPS_DIR}" DIRECTORY)
endif()

mark_as_advanced(MUMPS_INCLUDE_DIR MUMPS_LIBRARY)
