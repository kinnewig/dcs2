# FindGMSH.cmake
# -------------------
# Locates GMSH.
# This will define the following variables:
# GRMSH_FOUND - System has GMSH 
# GRMSH_INCLUDE_DIRS - The GMSH include directories
# GRMSH_LIBRARIES - The libraries needed to use GMSH
# GRMSH_DIR - The directory of the found GMSH installation

find_package(PkgConfig)
pkg_check_modules(PC_GMSH QUIET GMSH)

set(GMSH_DIR "" CACHE PATH "The directory of the GMSH installation")

find_path(GMSH_INCLUDE_DIR NAMES gmsh.h
          HINTS ${GMSH_DIR}/include ${CMAKE_INSTALL_PREFIX}/gmsh/${GMSH_VERSION}/include
          PATHS ${PC_GMSH_INCLUDEDIR} ${PC_GMSH_INCLUDE_DIRS}
        )

find_library(GMSH_LIBRARY NAMES libgmsh${CMAKE_SHARED_LIBRARY_SUFFIX}
             HINTS ${GMSH_DIR} ${CMAKE_INSTALL_PREFIX}/gmsh/${GMSH_VERSION}
             PATHS ${PC_GMSH_LIBDIR} ${PC_GMSH_LIBRARY_DIRS}
             PATH_SUFFIXES lib lib64
           )

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(GMSH DEFAULT_MSG GMSH_LIBRARY GMSH_INCLUDE_DIR)

if(GMSH_FOUND)
  set(GMSH_LIBRARIES ${GMSH_LIBRARY})
  set(GMSH_INCLUDE_DIRS ${GMSH_INCLUDE_DIR})

  get_filename_component(GMSH_DIR "${GMSH_LIBRARY}" DIRECTORY)
  get_filename_component(GMSH_DIR "${GMSH_DIR}" DIRECTORY)
endif()

mark_as_advanced(GMSH_INCLUDE_DIR GMSH_LIBRARY)
