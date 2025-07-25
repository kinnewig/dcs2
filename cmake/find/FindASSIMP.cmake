# FindASSIMP.cmake
# -------------------
# Locates the ASSIMP package.
# This will define the following variables:
# ASSIMP_FOUND - System has ASSIMP
# ASSIMP_INCLUDE_DIRS - The ASSIMP include directories
# ASSIMP_LIBRARIES - The libraries needed to use ASSIMP
# ASSIMP_DIR - The directory of the found ASSIMP installation

find_package(PkgConfig)
pkg_check_modules(PC_ASSIMP QUIET ASSIMP)

set(ASSIMP_DIR "" CACHE PATH "The directory of the ASSIMP installation")

find_path(ASSIMP_INCLUDE_DIR NAMES version.h
          HINTS ${ASSIMP_DIR}/include ${CMAKE_INSTALL_PREFIX}/assimp/${ASSIMP_VERSION}/include
          PATHS ${PC_ASSIMP_INCLUDEDIR} ${PC_ASSIMP_INCLUDE_DIRS}
          PATH_SUFFIXES assimp
         )

find_library(ASSIMP_LIBRARY NAMES libassimp.so
             HINTS ${ASSIMP_DIR} ${CMAKE_INSTALL_PREFIX}/assimp/${ASSIMP_VERSION}
             PATHS ${PC_ASSIMP_LIBDIR} ${PC_ASSIMP_LIBRARY_DIRS}
             PATH_SUFFIXES lib lib64
           )

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(ASSIMP DEFAULT_MSG ASSIMP_LIBRARY ASSIMP_INCLUDE_DIR)

if(ASSIMP_FOUND)
  set(ASSIMP_LIBRARIES ${ASSIMP_LIBRARY})
  set(ASSIMP_INCLUDE_DIRS ${ASSIMP_INCLUDE_DIR})

  get_filename_component(ASSIMP_DIR "${ASSIMP_LIBRARY}" DIRECTORY)
  get_filename_component(ASSIMP_DIR "${ASSIMP_DIR}" DIRECTORY)
endif()

mark_as_advanced(ASSIMP_INCLUDE_DIR ASSIMP_LIBRARY)
