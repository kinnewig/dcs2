include(ExternalProject)

find_package(LAPACK)
if(NOT LAPACK_FOUND)
  set(lapack_cmake_args
    -D BUILD_TESTING:BOOL=OFF
    -D CMAKE_TLS_VERIFY:BOOL=${CMAKE_TLS_VERIFY}
    ${lapack_cmake_args}
  )

  if(DEALII_WITH_64BIT)
    list(APPEND lapack_cmake_args "-D CMAKE_Fortran_FLAGS='-fdefault-integer-8'")
    list(APPEND lapack_cmake_args "-D CMAKE_C_FLAGS='-fdefault-integer-8'")
    list(APPEND lapack_cmake_args "-D CMAKE_CXX_FLAGS='-fdefault-integer-8'" )
  endif()

  build_cmake_subproject("lapack")

  # BLAS
  # Populate the path
  #set(BLAS_DIR ${INSTALL_DIR})
  
  # BLACS
  # Populate the path
  #set(BLACS_DIR ${INSTALL_DIR})
endif()

# Add LAPACK to deal.II
list(APPEND dealii_dependencies "lapack")
list(APPEND dealii_cmake_args "-D DEAL_II_WITH_LAPACK:BOOL=ON")
list(APPEND dealii_cmake_args "-D LAPACK_DIR=${LAPACK_DIR}")
list(APPEND dealii_cmake_args "-D LAPACK_LIBRARIES=${LAPACK_DIR}/lib/liblapack.so;${LAPACK_DIR}/lib64/liblapack.so")

  # BLAS
  #list(APPEND dealii_cmake_args "-D DEAL_II_WITH_BLAS:BOOL=ON")
  #list(APPEND dealii_cmake_args "-D BLAS_DIR=${BLAS_DIR}")


# Add LAPACK to trilinos
list(APPEND trilinos_dependencies "lapack")
list(APPEND trilinos_cmake_args "-D TPL_ENABLE_LAPACK:BOOL=ON")
list(APPEND trilinos_cmake_args "-D LAPACK_LIBRARY_DIRS:PATH=${LAPACK_DIR}/lib;${LAPACK_DIR}/lib64")

  # BLAS
  #list(APPEND trilinos_cmake_args "-D TPL_ENABLE_BLAS:BOOL=ON")
  #list(APPEND trilinos_cmake_args "-D BLAS_LIBRARY_DIRS:PATH=${BLAS_DIR}/lib64")

# Add LAPACK as dependecie to petsc
list(APPEND petsc_dependencies "lapack")
list(APPEND petsc_autotool_args " --with-lapack-dir=${LAPACK_DIR}")

# Add LAPACK to SuiteSparse
list(APPEND suitesparse_dependencies "lapack")
list(APPEND suitesparse_cmake_args "-D LAPACK_LIBRARIES=${LAPACK_DIR}/lib/liblapack${CMAKE_SHARED_LIBRARY_SUFFIX};${LAPACK_DIR}/lib64/liblapack${CMAKE_SHARED_LIBRARY_SUFFIX}")

# Add LAPACK to MUMPS
list(APPEND mumps_dependencies "lapack")
list(APPEND mumps_cmake_args -D LAPACK_ROOT=${LAPACK_DIR})

# Add LAPACK to ScaLAPACK
list(APPEND scalapack_dependencies "lapack")
list(APPEND scalapack_cmake_args -D LAPACK_ROOT=${LAPACK_DIR})


