set(MKLROOT ${MKL_DIR})

# BLAS
set(BLA_VENDOR Intel10_64lp)
set(MKL_LP_TYPE "lp64")
find_package(BLAS)

if(${BLAS_FOUND})
  # Add blas to aprack # TODO
  
  # Add blas to deal.II
  list(APPEND dealii_cmake_args "-D BLAS_DIR=${MKL_ROOT}/mkl/latest/")
  
  # Add blas to PETSc 
  list(APPEND petsc_autotool_args "--with-blas-lapack-dir=${MKL_ROOT}/mkl/latest")
  
  # Add blas to trilinos
  list(APPEND trilinos_cmake_args "-D TPL_ENABLE_BLAS:BOOL=ON")
  list(APPEND trilinos_cmake_args "-D BLAS_LIBRARY_NAMES:STRING='libmkl_core${CMAKE_SHARED_LIBRARY_SUFFIX}'")
  list(APPEND trilinos_cmake_args "-D BLAS_LIBRARY_DIRS:STRING=${MKL_ROOT}/mkl/latest/lib")
  
  # Add blas to SuiteSparse #TODO
else()
  message(ERROR "Could not find BLAS MKL, please ensure MKL BLAS is installed, please provide the MKL root directory via -D MKL_DIR=</path/to/mkl-root>")
endif()

# LAPACK
find_package(LAPACK)
if(${LAPACK_FOUND})
  # Add lapack to ARPACK-NG # TODO
  
  # Add lapack to deal.II (Does not work with MKL)
  #list(APPEND dealii_cmake_args "-D DEAL_II_WITH_LAPACK:BOOL=ON")
  #list(APPEND dealii_cmake_args "-D LAPACK_DIR=${MKL_ROOT}/mkl/latest/")
  
  # Add lapack to trilinos
  list(APPEND trilinos_cmake_args "-D TPL_ENABLE_LAPACK:BOOL=ON")
  list(APPEND trilinos_cmake_args "-D LAPACK_LIBRARY_NAMES:STRING=libmkl_core${CMAKE_SHARED_LIBRARY_SUFFIX}")
  list(APPEND trilinos_cmake_args "-D LAPACK_LIBRARY_DIRS:STRING=${MKL_ROOT}/mkl/latest/lib")
  
  # Add lapack to MUMPS
  list(APPEND mumps_cmake_args "-D LAPACK_FIND_COMPONENTS=MKL")
  list(APPEND mumps_cmake_args "-D MKLROOT=${MKL_ROOT}")
  
  # Add lapack to SuiteSparse # TODO
else()
  message(ERROR "Could not find LAPACK MKL, please ensure MKL LAPACK is installed, please provide the MKL root directory via -D MKL_DIR=</path/to/mkl-root>")
endif()

# ScaLAPACK
find_package(MKL-ScaLAPACK)
if(${MKL-ScaLAPACK_FOUND})
  # Add scalapack to deal.II (Does not work with MKL)
  #list(APPEND dealii_cmake_args "-D DEAL_II_WITH_SCALAPACK:BOOL=ON")
  #list(APPEND dealii_cmake_args "-D SCALAPACK_DIR=${MKL_ROOT}/mkl/latest/")

  # Add scalapack as dependecie to PETSc # TODO
  
  # Add scalapack to trilinos
  list(APPEND trilinos_cmake_args "-D TPL_ENABLE_SCALAPACK:BOOL=ON")
  list(APPEND trilinos_cmake_args "-D Amesos_ENABLE_SCALAPACK:BOOL=ON")
  list(APPEND trilinos_cmake_args "-D SCALAPACK_LIBRARY_NAMES:STRING=libmkl_scalapack_${MKL_LP_TYPE}${CMAKE_SHARED_LIBRARY_SUFFIX}")
  list(APPEND trilinos_cmake_args "-D SCALAPACK_LIBRARY_DIRS:STRING=${MKL_ROOT}/mkl/latest/lib")
else()
  message(ERROR "Could not find ScaLAPACK MKL, please ensure MKL ScaLAPACK is installed, or provide the MKL root directory via -D MKL_DIR=</path/to/mkl-root>")
endif()

# Intel Thread Building Blocks # TODO 
