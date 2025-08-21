include(ExternalProject)

find_package(SYMENGINE)
if(NOT SYMENGINE_FOUND)
  message(STATUS "Building SYMENGINE")
  
  set(symengine_cmake_args
    -D BUILD_TESTS:BOOL=OFF
    -D BUILD_BENCHMARKS:BOOL=OFF
    -D WITH_SYMENGINE_THREAD_SAFE:BOOL=ON
    ${symengine_cmake_args}
  )

  build_cmake_subproject("symengine")

  # Dependencies:
  list(APPEND dealii_dependencies "symengine")
endif()


# Add SYMENGINE to deal.II
list(APPEND dealii_cmake_args "DEAL_II_WITH_SYMENGINE:BOOL=ON")
list(APPEND dealii_cmake_args "-D SYMENGINE_DIR:PATH=${SYMENGINE_DIR}")
