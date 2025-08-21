include(ExternalProject)

find_package(ARPACK-NG)
if(NOT ARPACK-NG_FOUND)
  message(STATUS "Building ARPACK-NG")
  
  set(arpack-ng_cmake_args
    -D EXAMPLES:BOOL=OFF
    -D MPI:BOOL=ON
    ${arpack-ng_cmake_args}
  )

  build_cmake_subproject("arpack-ng")

  # Dependencies:
  list(APPEND dealii_dependencies "arpack-ng")
endif()

list(APPEND dealii_cmake_args "-D ARPACK_DIR:PATH=${ARPACK-NG_DIR}")
