include(ExternalProject)

find_package(SUPERLU_DIST)
if(NOT SUPERLU_DIST_FOUND)
  message(STATUS "Building SUPERLU_DIST")
  
  set(superlu_dist_cmake_args
    -D BUILD_SHARED_LIBS:BOOL=ON
    -D BUILD_TESTING:BOOL=OFF
    -D CMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}/superlu_dist/${SUPERLU_DIST_VERSION}
    -D CMAKE_C_COMPILER:PATH=${CMAKE_MPI_C_COMPILER}
    -D CMAKE_C_FLAGS:STRING="-fPIC"
    -D CMAKE_Fortran_COMPILER:PATH=${CMAKE_MPI_Fortran_COMPILER}
    -D CMAKE_BUILD_TYPE:STRING=Release
    ${superlu_dist_cmake_args}
  )

  build_cmake_subproject("superlu_dist")

  # Dependencies:
  list(APPEND trilinos_dependencies "superlu_dist")
endif()

# add SUPERLU_DIST to trilinos
list(APPEND trilinos_cmake_args "-D TPL_ENABLE_SUPERLU_DIST=ON")
list(APPEND trilinos_cmake_args "-D SUPERLU_DIST_LIBRARY_DIRS:PATH=${SUPERLU_DIST_DIR}/lib")
list(APPEND trilinos_cmake_args "-D SUPERLU_DIST_INCLUDE_DIRS:PATH=${SUPERLU_DIST_DIR}/include")
