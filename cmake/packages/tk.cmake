include(ExternalProject)

find_package(TK)
if(TK_FOUND)


else()
  message(STATUS "Building TK")

  list(APPEND tk_autotools_args "--prefix=${CMAKE_INSTALL_PREFIX}/tk/${TK_VERSION}")
 
  build_autotools_subproject_with_custom_configure(${tcl} "./unix/configure")

  # Dependencies:
  list(APPEND occt_dependencies "tk")
endif()

# add TK to OpenCascade
list(APPEND occt_cmake_args "-D 3RDPARTY_TK_DIR=${TK_DIR}")
