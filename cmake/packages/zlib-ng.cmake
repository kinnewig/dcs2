include(ExternalProject)

find_package(ZLIB-NG)
if(NOT ZLIB-NG_FOUND)
  message(STATUS "Building ZLIB-NG")
  
  set(zlib-ng_cmake_args
    -D CMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}/zlib-ng/${ZLIB-NG_VERSION}
    -D CMAKE_C_COMPILER:PATH=${MPI_C_COMPILER}
    -D CMAKE_CXX_COMPILER:PATH=${MPI_CXX_COMPILER}
    -D CMAKE_Fortran_COMPILER:PATH=${MPI_Fortran_COMPILER}
    -D CMAKE_BUILD_TYPE:STRING=Release
    -D BUILD_SHARED_LIBS:BOOL=ON
    -D ZLIB_COMPAT:BOOL=ON
    -D WITH_GTEST:BOOL=OFF
    ${zlib-ng_cmake_args}
  )

  build_cmake_subproject("zlib-ng")

  # Dependencies:
  list(APPEND fltk_dependencies "zlib-ng")
  list(APPEND petsc_dependencies "zlib-ng")
  list(APPEND trilinos_dependencies "zlib-ng")
  list(APPEND dealii_dependencies "zlib-ng")
endif()


list(APPEND fltk_cmake_args "-D ZLIB_ROOT:PATH=${ZLIB-NG_DIR}")

# Add ZLIB-NG to deal.II
list(APPEND dealii_cmake_args "DEAL_II_WITH_ZLIB:BOOL=ON")
list(APPEND dealii_cmake_args "-D ZLIB_DIR:PATH=${ZLIB-NG_DIR}")

