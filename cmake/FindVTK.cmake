# FindVTK.cmake
# -------------------
# Locates VTK.
# This will define the following variables:
# VTK_FOUND - System has VTK 
# VTK_INCLUDE_DIRS - The VTK include directories
# VTK_LIBRARIES - The libraries needed to use GMSH
# VTK_DIR - The directory of the found GMSH installation

find_package(PkgConfig)
pkg_check_modules(PC_VTK QUIET VTK)

set(VTK_DIR "" CACHE PATH "The directory of the VTK installation")

string(REGEX REPLACE "\\.[0-9]+$" "" VTK_VERSION_SHORT "${VTK_VERSION}")

find_path(VTK_INCLUDE_DIR NAMES NAMES vtkVersion.h 
          HINTS ${VTK_DIR}/include/vtk-${VTK_VERSION_SHORT} ${CMAKE_INSTALL_PREFIX}/vtk/${VTK_VERSION}/include/vtk-${VTK_VERSION_SHORT}
          PATHS ${PC_VTK_INCLUDEDIR} ${PC_VTK_INCLUDE_DIRS}
         )

find_library(VTK_LIBRARY NAMES vtkCommonCore 
             HINTS ${VTK_DIR} ${CMAKE_INSTALL_PREFIX}/vtk/${VTK_VERSION}
             PATHS ${PC_VTK_LIBDIR} ${PC_VTK_LIBRARY_DIRS}
             PATH_SUFFIXES lib lib64
            )

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(VTK DEFAULT_MSG VTK_LIBRARY VTK_INCLUDE_DIR)

if(VTK_FOUND)
  set(VTK_LIBRARIES ${VTK_LIBRARY})
  set(VTK_INCLUDE_DIRS ${VTK_INCLUDE_DIR})

  get_filename_component(VTK_DIR "${VTK_LIBRARY}" DIRECTORY)
  get_filename_component(VTK_DIR "${VTK_DIR}" DIRECTORY)
endif()

mark_as_advanced(VTK_INCLUDE_DIR VTK_LIBRARY)
