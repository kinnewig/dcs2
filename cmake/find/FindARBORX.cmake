# FindARBORX.cmake
# -------------------
# Locates the ARBORX package.
# This will define the following variables:
# ARBORX_FOUND - System has ARBORX
# ARBORX_INCLUDE_DIRS - The ARBORX include directories
# ARBORX_DIR - The directory of the found ARBORX installation

find_package(PkgConfig)
pkg_check_modules(PC_ARBORX QUIET ARBORX)

set(ARBORX_DIR "" CACHE PATH "The directory of the ARBORX installation")

find_path(ARBORX_INCLUDE_DIR NAMES ArborX_Version.hpp
          HINTS ${ARBORX_DIR}/include ${CMAKE_INSTALL_PREFIX}/arborx/${ARBORX_VERSION}/include
          PATHS ${PC_ARBORX_INCLUDEDIR} ${PC_ARBORX_INCLUDE_DIRS}
          PATH_SUFFIXES ArborX
        )

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(ARBORX DEFAULT_MSG ARBORX_INCLUDE_DIR)

if(ARBORX_FOUND)
  set(ARBORX_INCLUDE_DIRS ${ARBORX_INCLUDE_DIR})

  get_filename_component(ARBORX_DIR "${ARBORX_INCLUDE_DIR}" DIRECTORY)
  get_filename_component(ARBORX_DIR "${ARBORX_DIR}" DIRECTORY)
endif()

mark_as_advanced(ARBORX_INCLUDE_DIR)
