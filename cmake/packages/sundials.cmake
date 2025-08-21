include(ExternalProject)

find_package(SUNDIALS)
if(NOT SUNDIALS_FOUND)
  message(STATUS "Building SUNDIALS")
  
  set(sundials_cmake_args
    -D ENABLE_MPI:BOOL=ON
    -D EXAMPLES_ENABLE_C=OFF
    -D EXAMPLES_INSTALL=OFF
    ${sundials_cmake_args}
  )

  build_cmake_subproject("sundials")

  # Dependencies:
  list(APPEND dealii_dependencies "sundials")
endif()

# add SUNDIALS to deal.II
list(APPEND dealii_cmake_args "-D DEAL_II_WITH_SUNDIALS:BOOL=ON")
list(APPEND dealii_cmake_args "-D SUNDIALS_DIR=${SUNDIALS_DIR}")
      
