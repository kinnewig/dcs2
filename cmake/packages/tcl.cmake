include(ExternalProject)

find_package(TCL)
if(TCL_FOUND)


else()
  message(STATUS "Building TCL")
  
  list(APPEND tcl_autotools_args --prefix=${CMAKE_INSTALL_PREFIX}/tcl/${TCL_VERSION})

  build_autotools_subproject_with_custom_configure(${tcl} "./unix/configure")
  
  # Dependencies:
  list(APPEND tk_dependencies "tcl")
  list(APPEND occt_dependencies "tcl")
endif()

# add TCL to TK
list(APPEND tk_autotools_args "--with-tcl=${TCL_DIR}/lib")

# add TCL to OpenCascade
list(APPEND occt_cmake_args "-D 3RDPARTY_TCL_DIR=${TCL_DIR}")
