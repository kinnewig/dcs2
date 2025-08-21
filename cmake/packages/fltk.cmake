include(ExternalProject)

find_package(FLTK)
if(NOT FLTK_FOUND)
  message(STATUS "Building FLTK")
  
  set(fltk_cmake_args
    -D FLTK_BUILD_SHARED_LIBS:BOOL=ON
    -D FLTK_BUILD_TEST:BOOL=OFF
    ${fltk_cmake_args}
  )

  build_cmake_subproject("fltk")

  # Dependencies:
  list(APPEND gmsh_dependencies "fltk")
endif()

# Add FLTK to GMSH
list(APPEND gmsh_cmake_args "FLTK_ROOT:PATH=${FLTK_DIR}")
