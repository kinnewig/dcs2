include(ExternalProject)

find_package(CGAL)
if(NOT CGAL_FOUND)
  message(STATUS "Building CGAL")
  
  set(cgal_cmake_args
    -D CMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}/cgal/${CGAL_VERSION}
    -D CMAKE_C_COMPILER:PATH=${MPI_C_COMPILER}
    -D CMAKE_CXX_COMPILER:PATH=${MPI_CXX_COMPILER}
    -D CMAKE_Fortran_COMPILER:PATH=${MPI_Fortran_COMPILER}
    -D CMAKE_BUILD_TYPE:STRING=Release
    -D BUILD_SHARED_LIBS:BOOL=ON
    ${cgal_cmake_args}
  )

  build_cmake_subproject("cgal")

  # Dependencies:
  list(APPEND dealii_dependencies "cgal")
endif()


# Add CGAL to deal.II
list(APPEND dealii_cmake_args "DEAL_II_WITH_CGAL:BOOL=ON")
list(APPEND dealii_cmake_args "-D CGAL_DIR:PATH=${CGAL_DIR}")
