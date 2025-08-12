# FindPARMETIS.cmake
# -------------------
# Locates the PARMETIS package.
# This will define the following variables:
# PARMETIS_FOUND - System has PETSc
# PARMETIS_INCLUDE_DIRS - The PETSc include directories
# PARMETIS_LIBRARIES - The libraries needed to use PETSc
# PARMETIS_DIR - The directory of the found PETSc installation

find_package(PkgConfig)
pkg_check_modules(PC_PARMETIS QUIET PARMETIS)

set(PARMETIS_DIR "" CACHE PATH "The directory of the Trilinos installation")

# TODO: Look for a specific version file:
find_path(PARMETIS_INCLUDE_DIR NAMES parmetis.h
  HINTS ${PARMETIS_DIR}/include ${CMAKE_INSTALL_PREFIX}/parmetis/${PARMETIS_VERSION}/include
  PATHS ${PC_PARMETIS_INCLUDEDIR} ${PC_PARMETIS_INCLUDE_DIRS}
  PATH_SUFFIXES finclude parmetis parmetis/finclude
)

find_library(PARMETIS_LIBRARY NAMES libparmetis.so
  HINTS ${PARMETIS_DIR} ${CMAKE_INSTALL_PREFIX}/parmetis/${PARMETIS_VERSION}
  PATHS ${PC_PARMETIS_LIBDIR} ${PC_PARMETIS_LIBRARY_DIRS}
  PATH_SUFFIXES lib lib64
)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(PARMETIS DEFAULT_MSG PARMETIS_LIBRARY PARMETIS_INCLUDE_DIR)

if(PARMETIS_FOUND)
  set(PARMETIS_LIBRARIES ${PARMETIS_LIBRARY})
  set(PARMETIS_INCLUDE_DIRS ${PARMETIS_INCLUDE_DIR})

  get_filename_component(PARMETIS_DIR "${PARMETIS_LIBRARY}" DIRECTORY)
  get_filename_component(PARMETIS_DIR ${PARMETIS_DIR} DIRECTORY)
endif()

mark_as_advanced(PARMETIS_INCLUDE_DIR PARMETIS_LIBRARY)
