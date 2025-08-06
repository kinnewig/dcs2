# FindGSL.cmake
# -------------------
# Locates the GSL package.
# This will define the following variables:
# GSL_FOUND - System has GSL
# GSL_INCLUDE_DIRS - The GSL include directories
# GSL_LIBRARIES - The libraries needed to use GSL
# GSL_DIR - The directory of the found GSL installation

find_package(PkgConfig)
pkg_check_modules(PC_GSL QUIET GSL)

set(GSL_DIR "" CACHE PATH "The directory of the GSL installation")

find_path(GSL_INCLUDE_DIR NAMES gsl_version.h
          HINTS ${GSL_DIR}/include ${CMAKE_INSTALL_PREFIX}/gsl/${GSL_VERSION}/include/
          PATHS ${PC_GSL_INCLUDEDIR} ${PC_GSL_INCLUDE_DIRS}
          PATH_SUFFIXES gsl
        )

find_library(GSL_LIBRARY NAMES libgsl.so
             HINTS ${GSL_DIR} ${CMAKE_INSTALL_PREFIX}/gsl/${GSL_VERSION}
             PATHS ${PC_GSL_LIBDIR} ${PC_GSL_LIBRARY_DIRS}
             PATH_SUFFIXES lib lib64
           )

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(GSL DEFAULT_MSG GSL_LIBRARY GSL_INCLUDE_DIR)

if(GSL_FOUND)
  set(GSL_LIBRARIES ${GSL_LIBRARY})
  set(GSL_INCLUDE_DIRS ${GSL_INCLUDE_DIR})

  get_filename_component(GSL_DIR "${GSL_LIBRARY}" DIRECTORY)
  get_filename_component(GSL_DIR "${GSL_DIR}" DIRECTORY)
endif()

mark_as_advanced(GSL_INCLUDE_DIR GSL_LIBRARY)
