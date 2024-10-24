# FindOCCT.cmake
# -------------------
# Locates the OCCT package.
# This will define the following variables:
# OCCT_FOUND - System has OCCT
# OCCT_INCLUDE_DIRS - The OCCT include directories
# OCCT_LIBRARIES - The libraries needed to use OCCT
# OCCT_DIR - The directory of the found OCCT installation

find_package(PkgConfig)
pkg_check_modules(PC_OCCT QUIET OCCT)

set(OCCT_DIR "" CACHE PATH "The directory of the OCCT installation")

find_path(OCCT_INCLUDE_DIR NAMES Vrml.hxx
          HINTS ${OCCT_DIR}/include/opencascade ${CMAKE_INSTALL_PREFIX}/occt/${OCCT_VERSION}/include/opencascade
          PATHS ${PC_OCCT_INCLUDEDIR} ${PC_OCCT_INCLUDE_DIRS})

find_library(OCCT_LIBRARY NAMES libTKernel${CMAKE_SHARED_LIBRARY_SUFFIX}
             HINTS ${OCCT_DIR}/lib ${CMAKE_INSTALL_PREFIX}/occt/${OCCT_VERSION}/lib
             PATHS ${PC_OCCT_LIBDIR} ${PC_OCCT_LIBRARY_DIRS})

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(OCCT DEFAULT_MSG OCCT_LIBRARY OCCT_INCLUDE_DIR)

if(OCCT_FOUND)
  set(OCCT_LIBRARIES ${OCCT_LIBRARY})
  set(OCCT_INCLUDE_DIRS ${OCCT_INCLUDE_DIR})

  get_filename_component(OCCT_DIR "${OCCT_LIBRARY}" DIRECTORY)
  get_filename_component(OCCT_DIR "${OCCT_DIR}" DIRECTORY)
endif()

mark_as_advanced(OCCT_INCLUDE_DIR OCCT_LIBRARY)
