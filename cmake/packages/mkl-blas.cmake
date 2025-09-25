set(MKLROOT ${MKL_DIR})

# BLAS
set(BLA_VENDOR Intel10_64lp)
find_package(BLAS)

if(${BLAS_FOUND})
  # Add blas to aprack
  list(APPEND arpack-ng_cmake_args "-D BLAS_LIBRARIES:PATH=${BLAS_LIBRARIES}")
  
  # Add blas to deal.II
  list(APPEND dealii_cmake_args "-D BLAS_LIBRARIES=${BLAS_LIBRARIES}")
  
  # Add blas to PETSc
  list(APPEND petsc_autotool_args "--with-blas-lapack-lib=${BLAS_LIBRARIES}")
  
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

# ScaLAPACK
set(MKL_LP_TYPE "lp64")
find_package(MKL-ScaLAPACK)
if()
  # Add scalapack to deal.II
  list(APPEND dealii_cmake_args "-D DEAL_II_WITH_SCALAPACK:BOOL=ON")
  list(APPEND dealii_cmake_args "-D SCALAPACK_LIBRARIES=${MKL-ScaLAPACK_LIBRARIES}/libmkl_scalapack_${MKL_LP_TYPE}${CMAKE_SHARED_LIBRARY_SUFFIX}")
  
  # Add scalapack as dependecie to PETSc
  list(APPEND petsc_autotool_args "--with-scalapack=true")
  list(APPEND petsc_autotool_args "--with-scalapack-lib=${MKL-ScaLAPACK_LIBRARIES}/libmkl_scalapack_${MKL_LP_TYPE}${CMAKE_SHARED_LIBRARY_SUFFIX}")
  
  # Add scalapack to trilinos
  list(APPEND trilinos_cmake_args "-D TPL_ENABLE_SCALAPACK:BOOL=ON")
  list(APPEND trilinos_cmake_args "-D Amesos_ENABLE_SCALAPACK:BOOL=ON")
  list(APPEND trilinos_cmake_args "-D SCALAPACK_LIBRARIES:PATH=${MKL-ScaLAPACK_LIBRARIES}/libmkl_scalapack_${MKL_LP_TYPE}${CMAKE_SHARED_LIBRARY_SUFFIX}")
else()
  message(ERROR "Could not find ScaLAPACK MKL, please ensure MKL ScaLAPACK is installed, or provide the MKL root directory via -D MKL_DIR=</path/to/mkl-root>")
endif()

# TBB
# TODO 
