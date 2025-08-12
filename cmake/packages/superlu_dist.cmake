include(ExternalProject)

find_package(SUPERLU_DIST)
if(NOT SUPERLU_DIST_FOUND)
  message(STATUS "Building SUPERLU_DIST")
  
  set(superlu_dist_cmake_args
    -D BUILD_SHARED_LIBS:BOOL=ON
    -D BUILD_TESTING:BOOL=OFF
    -D CMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}/superlu_dist/${SUPERLU_DIST_VERSION}
    -D CMAKE_C_COMPILER:PATH=${MPI_C_COMPILER}
    -D CMAKE_C_FLAGS:STRING="-fPIC"
    -D CMAKE_C_STANDARD=99
    -D CMAKE_CXX_COMPILER:PATH=${MPI_CXX_COMPILER}
    -D CMAKE_CXX_STANDARD=11
    -D CMAKE_BUILD_TYPE:STRING=Release
    -D BUILD_SHARED_LIBS:BOOL=ON
    -D BUILD_STATIC_LIBS:BOOL=OFF
    -D enable_examples:BOOL=OFF
    -D enable_tests:BOOL=OFF
    -D enable_python:BOOL=OFF
    -D XSDK_ENABLE_Fortran:BOOL=OFF
    ${superlu_dist_cmake_args}
  )

  build_cmake_subproject("superlu_dist")

  # Check if lib exists, if it does not, create a symlink
  ExternalProject_Add_Step(
    superlu_dist superlu_dist_install
    COMMAND cmake --install ${CMAKE_BINARY_DIR}/superlu_dist-prefix/src/superlu_dist-build
    DEPENDEES build
    DEPENDERS superlu_dist_symlink superlu_dist_symlink64
  )

  # Dependencies:
  list(APPEND trilinos_dependencies "superlu_dist")
endif()

# add SUPERLU_DIST to trilinos
list(APPEND trilinos_cmake_args "-D TPL_ENABLE_SUPERLU_DIST=ON")
list(APPEND trilinos_cmake_args "-D SUPERLU_DIST_LIBRARY_DIRS:PATH=${SUPERLU_DIST_DIR}/lib")
list(APPEND trilinos_cmake_args "-D SUPERLU_DIST_INCLUDE_DIRS:PATH=${SUPERLU_DIST_DIR}/include")
