# FindHYPRE.cmake
# -------------------
# Locates the HYPRE package.
# This will define the following variables:
# HYPRE_FOUND - System has HYPRE
# HYPRE_INCLUDE_DIRS - The HYPRE include directories
# HYPRE_LIBRARIES - The libraries needed to use HYPRE
# HYPRE_DIR - The directory of the found HYPRE installation

find_package(PkgConfig)
pkg_check_modules(PC_HYPRE QUIET HYPRE)

set(HYPRE_DIR "" CACHE PATH "The directory of the HYPRE installation")

find_path(HYPRE_INCLUDE_DIR NAMES HYPRE.h
          HINTS ${SEARCH_DEFAULTS} ${HYPRE_DIR} ${CMAKE_INSTALL_PREFIX}/hypre/${HYPRE_VERSION}
          PATHS ${PC_HYPRE_INCLUDEDIR} ${PC_HYPRE_INCLUDE_DIRS}
          PATH_SUFFIXES include/hypre include
        )

find_library(HYPRE_LIBRARY NAMES HYPRE
             HINTS ${SEARCH_DEFAULTS} ${HYPRE_DIR} ${CMAKE_INSTALL_PREFIX}/hypre/${HYPRE_VERSION}
             PATHS ${PC_HYPRE_LIBDIR} ${PC_HYPRE_LIBRARY_DIRS}
             PATH_SUFFIXES lib lib64
           )

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(HYPRE DEFAULT_MSG HYPRE_LIBRARY HYPRE_INCLUDE_DIR)

if(HYPRE_FOUND)
  set(HYPRE_LIBRARIES ${HYPRE_LIBRARY})
  set(HYPRE_INCLUDE_DIRS ${HYPRE_INCLUDE_DIR})

  get_filename_component(HYPRE_DIR "${HYPRE_LIBRARY}" DIRECTORY)
  get_filename_component(HYPRE_DIR "${HYPRE_DIR}" DIRECTORY)
endif()

mark_as_advanced(HYPRE_INCLUDE_DIR HYPRE_LIBRARY)
