include(ExternalProject)

find_package(ARBORX)
if(NOT ARBORX_FOUND)
  message(STATUS "Building ARBORX")
  
  set(arborx_cmake_args
    -D CMAKE_CXX_EXTENSIONS=OFF
    -D ARBORX_ENABLE_MPI:BOOL=ON
    ${arborx_cmake_args}
  )

  build_cmake_subproject("arborx")

  # Dependencies:
  list(APPEND dealii_dependencies "arborx")
endif()


# Add ARBORX to deal.II
list(APPEND dealii_cmake_args "DEAL_II_WITH_ARBORX:BOOL=ON")
list(APPEND dealii_cmake_args "-D ARBORX_DIR:PATH=${ARBORX_DIR}")
