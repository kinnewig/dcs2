include(ExternalProject)

find_package(GSL)
if(NOT GSL_FOUND)
  message(STATUS "Building GSL")
  
  list(APPEND gsl_autotool_args "--prefix=${CMAKE_INSTALL_PREFIX}/gsl/${GSL_VERSION}")
  
  build_autotools_subproject_with_custom_configure_and_update("gsl" "./configure" "./autogen.sh")

  set(GSL_LIBRARY "${GSL_DIR}/lib")
  set(GSL_INCLUDE_DIR "${GSL_DIR}/include")

  # Dependencies:
  list(APPEND dealii_dependencies "gsl")
endif()

# add GSL to deal.II
list(APPEND dealii_cmake_args "-D GSL_DIR:PATH=${GSL_DIR}")

