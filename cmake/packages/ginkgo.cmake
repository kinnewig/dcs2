include(ExternalProject)

find_package(GINKGO)
if(NOT GINKGO_FOUND)
  message(STATUS "Building ginkgo")
  
  set(ginkgo_cmake_args
    -D CMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}/ginkgo/${GINKGO_VERSION}
    -D CMAKE_C_COMPILER:PATH=${CMAKE_MPI_C_COMPILER}
    -D CMAKE_C_COMPILER:PATH=${CMAKE_MPI_CXX_COMPILER}
    -D CMAKE_Fortran_COMPILER:PATH=${CMAKE_MPI_Fortran_COMPILER}
    -D CMAKE_BUILD_TYPE:STRING=Release
    -D BUILD_SHARED_LIBS:BOOL=ON
    -D GINKGO_BUILD_TESTS:BOOL=OFF 
    -D GINKGO_FAST_TESTS:BOOL=OFF 
    -D GINKGO_BUILD_EXAMPLES:BOOL=OFF 
    -D GINKGO_BUILD_BENCHMARKS:BOOL=OFF 
    -D GINKGO_BENCHMARK_ENABLE_TUNING:BOOL=OFF 
    -D GINKGO_BUILD_DOC:BOOL=OFF 
    -D GINKGO_VERBOSE_LEVEL=1 
    -D GINKGO_DEVEL_TOOLS:BOOL=OFF 
    -D GINKGO_WITH_CLANG_TIDY:BOOL=OFF 
    -D GINKGO_WITH_IWYU:BOOL=OFF 
    -D GINKGO_CHECK_CIRCULAR_DEPS:BOOL=OFF 
    -D GINKGO_WITH_CCACHE:BOOL=OFF 
    -D GINKGO_BUILD_HWLOC:BOOL=OFF
    ${ginkgo_cmake_args}
  )

  build_cmake_subproject("ginkgo")

  # Dependencies:
  list(APPEND dealii_dependencies "ginkgo")
endif()

# Force deal.II to use ginkgo
list(APPEND dealii_cmake_args "-D GINKGO_DIR:PATH=${GINKGO_DIR}")
message("dealii_cmake_args = ${dealii_cmake_args}")
