include(ExternalProject)

find_package(ARPACK-NG)
if(NOT ARPACK-NG_FOUND)
  message(STATUS "Building ARPACK-NG")
  
  set(arpack-ng_cmake_args
    -D CMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}/arpack-ng/${ARPACK-NG_VERSION}
    -D CMAKE_C_COMPILER:PATH=${CMAKE_MPI_C_COMPILER}
    -D CMAKE_C_COMPILER:PATH=${CMAKE_MPI_CXX_COMPILER}
    -D CMAKE_Fortran_COMPILER:PATH=${CMAKE_MPI_Fortran_COMPILER}
    -D CMAKE_BUILD_TYPE:STRING=Release
    -D EXAMPLES:BOOL=OFF
    -D MPI:BOOL=ON
    -D BUILD_SHARED_LIBS:BOOL=ON
    ${arpack-ng_cmake_args}
  )

  build_cmake_subproject("arpack-ng")

  # Dependencies:
  list(APPEND dealii_dependencies "arpack-ng")
endif()

list(APPEND dealii_cmake_args "-D ARPACK_DIR:PATH=${ARPACK-NG_DIR}")
