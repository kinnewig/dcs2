include(ExternalProject)

find_package(TBB)
if(TBB_FOUND)


else()
  message(STATUS "Building TBB")
  
  set(tbb_cmake_args
    -D TBB_STRICT:BOOL=OFF
    -D CMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}/tbb/${TBB_VERSION}
    -D CMAKE_C_COMPILER:PATH=${CMAKE_MPI_C_COMPILER}
    -D CMAKE_CXX_COMPILER:PATH=${CMAKE_MPI_CXX_COMPILER}
    -D CMAKE_Fortran_COMPILER:PATH=${CMAKE_MPI_Fortran_COMPILER}
    -D CMAKE_BUILD_TYPE:STRING=Release
    ${tbb_cmake_args}
  )

  build_cmake_subproject("tbb")
  
  # Dependencies:
  list(APPEND occt_dependencies "tbb")
  list(APPEND dealii_dependencies "tbb")
endif()

# add TBB to OpenCascade
list(APPEND occt_cmake_args "-D 3RDPARTY_TBB_LIBRARY_DIR=${TBB_DIR}/lib;${TBB_DIR}/lib64")

# add TBB to deal.II
list(APPEND dealii_cmake_args "-D TBB_DIR=${TBB_DIR}")
