include(ExternalProject)

if(NOT VTK_FOUND)
  message(STATUS "Building VTK")
  
  set(vtk_cmake_args
    -D CMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}/vtk/${VTK_VERSION}
    -D CMAKE_C_COMPILER:PATH=${CMAKE_C_COMPILER}
    -D CMAKE_CXX_COMPILER:PATH=${CMAKE_CXX_COMPILER}
    -D CMAKE_Fortran_COMPILER:PATH=${CMAKE_Fortran_COMPILER}
    -D CMAKE_BUILD_TYPE:STRING=Release
    ${vtk_cmake_args}
  )
 
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
