include(ExternalProject)
find_package(T8CODE)

if(NOT T8CODE_FOUND)
  message(STATUS "Building T8CODE")
  
  list(APPEND t8code_cmake_args "-D T8CODE_ENABLE_MPI:BOOL=ON")

  build_cmake_subproject("t8code")

  # Dependencies:
  list(APPEND dealii_dependencies "t8code")
endif()


# add T8CODE to dealii
list(APPEND dealii_cmake_args "-D DEAL_II_WITH_T8CODE:BOOL=ON")
list(APPEND dealii_cmake_args "-D T8CODE_DIR='${T8CODE_DIR}'")

