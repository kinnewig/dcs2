set(MKLROOT ${MKL_DIR})

# BLAS
set(BLA_VENDOR Intel10_64lp)
set(MKL_LP_TYPE "lp64")
find_package(BLAS)

if(${BLAS_FOUND})
  set(filtered_so_libs "")
  foreach(item IN LISTS BLAS_LIBRARIES)
    if("${item}" MATCHES "\\.so$")
      list(APPEND filtered_so_libs "${item}")
    endif()
  endforeach()
  set(BLAS_LIBRARIES "${filtered_so_libs}")


  # Add blas to aprack # TODO
  list(APPEND arpack-ng_cmake_args "-D BLAS_LIBRARIES:PATH=${BLAS_LIBRARIES}")
  
  # Add blas to deal.II
  list(APPEND dealii_cmake_args "-D BLAS_DIR=${MKL_ROOT}/mkl/latest/")
  
  # Add blas to PETSc # TODO
  list(APPEND petsc_autotool_args "--with-blas-lapack-lib=${BLAS_LIBRARIES}")
  
  # Add blas to trilinos
  list(APPEND trilinos_cmake_args "-D TPL_ENABLE_BLAS:BOOL=ON")
  list(APPEND trilinos_cmake_args "-D BLAS_LIBRARY_NAMES:STRING='libmkl_core${CMAKE_SHARED_LIBRARY_SUFFIX}'")
  list(APPEND trilinos_cmake_args "-D BLAS_LIBRARY_DIRS:STRING=${MKL_ROOT}/mkl/latest/lib")
  
  # Add blas to SuiteSparse #TODO
  list(APPEND suitesparse_cmake_args "-D BLAS_LIBRARIES:PATH=${BLAS_LIBRARIES}")
else()
  message(ERROR "Could not find BLAS MKL, please ensure MKL BLAS is installed, please provide the MKL root directory via -D MKL_DIR=</path/to/mkl-root>")
endif()

# LAPACK
find_package(LAPACK)
if(${LAPACK_FOUND})
  set(filtered_so_libs "")
  foreach(item IN LISTS LAPACK_LIBRARIES)
    if("${item}" MATCHES "\\.so$")
      list(APPEND filtered_so_libs "${item}")
    endif()
  endforeach()
  set(LAPACK_LIBRARIES "${filtered_so_libs}")

  # Add lapack to ARPACK-NG # TODO
  list(APPEND arpack-ng_cmake_args "-D LAPACK_LIBRARIES:PATH=${LAPACK_LIBRARIES}")
  
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
  list(APPEND suitesparse_cmake_args "-D LAPACK_LIBRARIES:PATH=${LAPACK_LIBRARIES}")
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
  list(APPEND petsc_autotool_args "--with-scalapack=true")
  list(APPEND petsc_autotool_args "--with-scalapack-lib=${MKL-ScaLAPACK_LIBRARIES}/")
  
  # Add scalapack to trilinos
  list(APPEND trilinos_cmake_args "-D TPL_ENABLE_SCALAPACK:BOOL=ON")
  list(APPEND trilinos_cmake_args "-D Amesos_ENABLE_SCALAPACK:BOOL=ON")
  list(APPEND trilinos_cmake_args "-D SCALAPACK_LIBRARY_NAMES:STRING=libmkl_scalapack_${MKL_LP_TYPE}${CMAKE_SHARED_LIBRARY_SUFFIX}")
  list(APPEND trilinos_cmake_args "-D SCALAPACK_LIBRARY_DIRS:STRING=${MKL_ROOT}/mkl/latest/lib")
else()
  message(ERROR "Could not find ScaLAPACK MKL, please ensure MKL ScaLAPACK is installed, or provide the MKL root directory via -D MKL_DIR=</path/to/mkl-root>")
endif()

# TBB
# TODO 
