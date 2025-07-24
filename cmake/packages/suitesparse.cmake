include(ExternalProject)

find_package(SUITESPARSE)
if(SUITESPARSE_FOUND)

else()
  message(STATUS "Building SuiteSparse")
  
  set(suitesparse_cmake_args
    -D SUITESPARSE_USE_64BIT_BLAS:BOOL=ON
    -D CMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}/suitesparse/${SUITESPARSE_VERSION}
    -D CMAKE_C_COMPILER:PATH=${CMAKE_C_COMPILER}
    -D CMAKE_Fortran_COMPILER:PATH=${CMAKE_Fortran_COMPILER}
    -D CMAKE_BUILD_TYPE:STRING=Release
    ${suitesparse_cmake_args}
  )
  
  build_cmake_subproject(suitesparse)

  # Dependencies:
  list(APPEND dealii_dependencies "suitesparse")
  list(APPEND petsc_dependencies "suitesparse")
  list(APPEND trilinos_dependencies "suitesparse")
endif()

# add SuiteSparse to deal.II
list(APPEND dealii_cmake_args "-D DEAL_II_WITH_UMFPACK:BOOL=ON")
list(APPEND dealii_cmake_args "-D UMFPACK_DIR=${SUITESPARSE_DIR}")

# add SuiteSparse to PETSc
list(APPEND petsc_autotool_args "--with-suitesparse=true")
list(APPEND petsc_autotool_args "--with-suitesparse-dir=${SUITESPARSE_DIR}")

# add SuiteSparse to Trilinos
list(APPEND trilinos_cmake_args "-D TPL_ENABLE_UMFPACK=ON")
list(APPEND trilinos_cmake_args "-D UMFPACK_LIBRARY_DIRS:PATH=${SUITESPARSE_DIR}/lib;${SUITESPARSE_DIR}/lib64")
list(APPEND trilinos_cmake_args "-D UMFPACK_INCLUDE_DIRS:PATH=${SUITESPARSE_DIR}/include/suitesparse")
