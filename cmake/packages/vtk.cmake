include(ExternalProject)

if(NOT VTK_FOUND)
  message(STATUS "Building VTK")
  
  build_cmake_subproject("vtk")
  
  set(VTK_LIBRARY "${VTK_DIR}/lib64")
  set(VTK_INCLUDE_DIRS "${VTK_DIR}/include")

  # Dependencies:
  list(APPEND occt_dependencies "vtk")
  list(APPEND dealii_dependencies "vtk")
endif()

# add VTK to OpenCascade
list(APPEND occt_cmake_args "-D 3RDPARTY_VTK_LIBRARY_DIR=${VTK_DIR}/lib;${VTK_DIR}/lib64")

# add VTK to deal.II
list(APPEND dealii_cmake_args "-D VTK_DIR=${VTK_DIR}")
