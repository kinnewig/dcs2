# BLAS
find_package(BLAS)

if(${BLAS_FOUND})
  # Add blas to aprack
  list(APPEND arpack-ng_cmake_args "-D BLAS_LIBRARIES:PATH=${BLAS_LIBRARIES}")
  
  # Add blas to deal.II
  list(APPEND dealii_cmake_args "-D BLAS_LIBRARIES=${BLAS_LIBRARIES}")
  
  # Add blas to PETSc
  list(APPEND petsc_autotool_args "--with-blas-lib=${BLAS_LIBRARIES}")
  
  # Add blas to trilinos
  list(APPEND trilinos_cmake_args "-D TPL_ENABLE_BLAS:BOOL=ON")
  list(APPEND trilinos_cmake_args "-D BLAS_LIBRARIES:PATH=${BLAS_LIBRARIES}")
  
  # Add blas to SuiteSparse
  list(APPEND suitesparse_cmake_args "-D BLAS_LIBRARIES:PATH=${BLAS_LIBRARIES}")
else()
  message(ERROR "Could not find BLAS MKL, please ensure MKL BLAS is installed, please provide the MKL root directory via -D MKL_DIR=</path/to/mkl-root>")
endif()

# LAPACK
find_package(LAPACK)
if(${LAPACK_FOUND})
  # Add lapack to ARPACK-NG
  list(APPEND arpack-ng_cmake_args "-D LAPACK_LIBRARIES:PATH=${LAPACK_LIBRARIES}")
  
  # Add lapack to deal.II
  list(APPEND dealii_cmake_args "-D DEAL_II_WITH_LAPACK:BOOL=ON")
  list(APPEND dealii_cmake_args "-D LAPACK_LIBRARIES=${LAPACK_LIBRARIES}")

  # Add lapack to PETSc
  list(APPEND petsc_autotool_args "--with-lapack-lib=${LAPACK_LIBRARIES}")
  
  # Add lapack to trilinos
  list(APPEND trilinos_cmake_args "-D TPL_ENABLE_LAPACK:BOOL=ON")
  list(APPEND trilinos_cmake_args "-D LAPACK_LIBRARIES:PATH=${LAPACK_LIBRARIES}")
  
  # Add lapack to MUMPS
  list(APPEND mumps_cmake_args "-D LAPACK_FIND_COMPONENTS=MKL")
  list(APPEND mumps_cmake_args "-D MKLROOT=MKL")
  
  # Add lapack to SuiteSparse
  list(APPEND suitesparse_cmake_args "-D LAPACK_LIBRARIES:PATH=${LAPACK_LIBRARIES}")
else()
  message(ERROR "Could not find LAPACK MKL, please ensure MKL LAPACK is installed, please provide the MKL root directory via -D MKL_DIR=</path/to/mkl-root>")
endif()
