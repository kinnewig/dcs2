# FindTBB.cmake
# -------------------
# Locates the TBB package.
# This will define the following variables:
# TBB_FOUND - System has TBB
# TBB_INCLUDE_DIRS - The TBB include directories
# TBB_LIBRARIES - The libraries needed to use TBB
# TBB_DIR - The directory of the found TBB installation

find_package(PkgConfig)
pkg_check_modules(PC_TBB QUIET TBB)

set(TBB_DIR "" CACHE PATH "The directory of the TBB installation")

find_path(TBB_INCLUDE_DIR NAMES tbb.h
          HINTS ${TBB_DIR}/include/tbb ${CMAKE_INSTALL_PREFIX}/tbb/${TBB_VERSION}/include/tbb
          PATHS ${PC_TBB_INCLUDEDIR} ${PC_TBB_INCLUDE_DIRS})

find_library(TBB_LIBRARY NAMES libtbb${CMAKE_SHARED_LIBRARY_SUFFIX}
             HINTS ${TBB_DIR}/lib64 ${CMAKE_INSTALL_PREFIX}/tbb/${TBB_VERSION}/lib64
             PATHS ${PC_TBB_LIBDIR} ${PC_TBB_LIBRARY_DIRS})

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(TBB DEFAULT_MSG TBB_LIBRARY TBB_INCLUDE_DIR)

if(TBB_FOUND)
  set(TBB_LIBRARIES ${TBB_LIBRARY})
  set(TBB_INCLUDE_DIRS ${TBB_INCLUDE_DIR})

  get_filename_component(TBB_DIR "${TBB_LIBRARY}" DIRECTORY)
  get_filename_component(TBB_DIR "${TBB_DIR}" DIRECTORY)
endif()

mark_as_advanced(TBB_INCLUDE_DIR TBB_LIBRARY)
