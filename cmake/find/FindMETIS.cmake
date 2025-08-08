# FindMETIS.cmake
# -------------------
# Locates the METIS package.
# This will define the following variables:
# METIS_FOUND - System has PETSc
# METIS_INCLUDE_DIRS - The PETSc include directories
# METIS_LIBRARIES - The libraries needed to use PETSc
# METIS_DIR - The directory of the found PETSc installation

find_package(PkgConfig)
pkg_check_modules(PC_METIS QUIET METIS)

set(METIS_DIR "" CACHE PATH "The directory of the Trilinos installation")

# TODO: Look for a specific version file:
find_path(METIS_INCLUDE_DIR NAMES metis.h
  HINTS ${METIS_DIR}/include ${CMAKE_INSTALL_PREFIX}/metis/${METIS_VERSION}/include
  PATHS ${PC_METIS_INCLUDEDIR} ${PC_METIS_INCLUDE_DIRS}
  PATH_SUFFIXES finclude metis metis/finclude
)

find_library(METIS_LIBRARY NAMES libmetis.so
  HINTS ${METIS_DIR} ${CMAKE_INSTALL_PREFIX}/metis/${METIS_VERSION}
  PATHS ${PC_METIS_LIBDIR} ${PC_METIS_LIBRARY_DIRS}
  PATH_SUFFIXES lib lib64
)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(METIS DEFAULT_MSG METIS_LIBRARY METIS_INCLUDE_DIR)

if(METIS_FOUND)
  set(METIS_LIBRARIES ${METIS_LIBRARY})
  set(METIS_INCLUDE_DIRS ${METIS_INCLUDE_DIR})

  get_filename_component(METIS_DIR "${METIS_LIBRARY}" DIRECTORY)
  get_filename_component(METIS_DIR ${METIS_DIR} DIRECTORY)
endif()

mark_as_advanced(METIS_INCLUDE_DIR METIS_LIBRARY)
