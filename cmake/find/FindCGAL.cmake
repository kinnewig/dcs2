# FindCGAL.cmake
# -------------------
# Locates the CGAL package.
# This will define the following variables:
# CGAL_FOUND - System has CGAL
# CGAL_INCLUDE_DIRS - The CGAL include directories
# CGAL_DIR - The directory of the found CGAL installation

find_package(PkgConfig)
pkg_check_modules(PC_CGAL QUIET CGAL)

set(CGAL_DIR "" CACHE PATH "The directory of the CGAL installation")

find_path(CGAL_INCLUDE_DIR NAMES version.h
          HINTS ${CGAL_DIR}/include ${CMAKE_INSTALL_PREFIX}/cgal/${CGAL_VERSION}/include
          PATHS ${PC_CGAL_INCLUDEDIR} ${PC_CGAL_INCLUDE_DIRS}
          PATH_SUFFIXES CGAL
        )

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(CGAL DEFAULT_MSG CGAL_INCLUDE_DIR)

if(CGAL_FOUND)
  set(CGAL_INCLUDE_DIRS ${CGAL_INCLUDE_DIR})

  get_filename_component(CGAL_DIR "${CGAL_INCLUDE_DIR}" DIRECTORY)
  get_filename_component(CGAL_DIR "${CGAL_DIR}" DIRECTORY)
endif()

mark_as_advanced(CGAL_INCLUDE_DIR)
