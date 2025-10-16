# FindSUNDIALS.cmake
# -------------------
# Locates the SUNDIALS package.
# This will define the following variables:
# SUNDIALS_FOUND - System has SUNDIALS
# SUNDIALS_INCLUDE_DIRS - The SUNDIALS include directories
# SUNDIALS_LIBRARIES - The libraries needed to use SUNDIALS
# SUNDIALS_DIR - The directory of the found SUNDIALS installation

find_package(PkgConfig)
pkg_check_modules(PC_SUNDIALS QUIET SUNDIALS)

set(SUNDIALS_DIR "" CACHE PATH "The directory of the SUNDIALS installation")

find_path(SUNDIALS_INCLUDE_DIR NAMES sundials_version.h
          HINTS ${SEARCH_DEFAULTS} ${SUNDIALS_DIR} ${CMAKE_INSTALL_PREFIX}/sundials/${SUNDIALS_VERSION}
          PATHS ${PC_SUNDIALS_INCLUDEDIR} ${PC_SUNDIALS_INCLUDE_DIRS}
          PATH_SUFFIXES include/sundials include
        )

find_library(SUNDIALS_LIBRARY NAMES sundials_core
             HINTS ${SEARCH_DEFAULTS} ${SUNDIALS_DIR} ${CMAKE_INSTALL_PREFIX}/sundials/${SUNDIALS_VERSION}
             PATHS ${PC_SUNDIALS_LIBDIR} ${PC_SUNDIALS_LIBRARY_DIRS}
             PATH_SUFFIXES lib lib64
           )

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(SUNDIALS DEFAULT_MSG SUNDIALS_LIBRARY SUNDIALS_INCLUDE_DIR)

if(SUNDIALS_FOUND)
  set(SUNDIALS_LIBRARIES ${SUNDIALS_LIBRARY})
  set(SUNDIALS_INCLUDE_DIRS ${SUNDIALS_INCLUDE_DIR})

  get_filename_component(SUNDIALS_DIR "${SUNDIALS_LIBRARY}" DIRECTORY)
  get_filename_component(SUNDIALS_DIR "${SUNDIALS_DIR}" DIRECTORY)
endif()

mark_as_advanced(SUNDIALS_INCLUDE_DIR SUNDIALS_LIBRARY)
