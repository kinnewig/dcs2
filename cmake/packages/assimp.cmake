include(ExternalProject)

find_package(ASSIMP)
if(NOT ASSIMP_FOUND)
  message(STATUS "Building ASSIMP")
  
  set(assimp_cmake_args
    -D CMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}/assimp/${ASSIMP_VERSION}
    -D CMAKE_C_COMPILER:PATH=${CMAKE_MPI_C_COMPILER}
    -D CMAKE_C_COMPILER:PATH=${CMAKE_MPI_CXX_COMPILER}
    -D CMAKE_Fortran_COMPILER:PATH=${CMAKE_MPI_Fortran_COMPILER}
    -D CMAKE_BUILD_TYPE:STRING=Release
    -D BUILD_SHARED_LIBS:BOOL=ON
    ${assimp_cmake_args}
  )

  build_cmake_subproject("assimp")

  # Dependencies:
  list(APPEND dealii_dependencies "assimp")
endif()

# Force deal.II to use ASSIMP
list(APPEND dealii_cmake_args "-D ASSIMP_DIR:PATH=${ASSIMP_DIR}")
