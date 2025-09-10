include(ExternalProject)

find_package(BLIS)
if (NOT BLIS_FOUND)
  message(STATUS "Building AMD BLIS")

  # Set BLIS architecture if not defined yet
  if (NOT DEFINED BLIS_ARCHITECTURE)
    set(BLIS_ARCHITECTURE auto)
  endif()

  set(amd-blis_cmake_args
    -D CMAKE_C_FLAGS="-DAOCL_F2C -fPIC"
    -D CMAKE_CXX_FLAGS="-DAOCL_F2C -fPIC"
    -D ENABLE_AOCL_DYNAMIC:BOOL=ON
    -D ENABLE_CBLAS:BOOL=ON
    -D ENABLE_THREADING=openmp
    -D BLIS_CONFIG_FAMILY=auto
    ${amd-blis_cmake_args}
  )

  if(${DEALII_WITH_64BIT})
    list(APPEND amd-blis_cmake_args "-D BLAS_INT_SIZE=64")
  endif()

  build_cmake_subproject(amd-blis)

  # update the resulting dir name:
  set(BLIS_DIR ${AMD-BLIS_DIR})

  ExternalProject_Add_Step(
    amd-blis blis_symlink_to_blas
    COMMAND ln -s libblis-mt${CMAKE_SHARED_LIBRARY_SUFFIX} libblas${CMAKE_SHARED_LIBRARY_SUFFIX}
    COMMAND ln -s libblis-mt${CMAKE_SHARED_LIBRARY_SUFFIX} libblis${CMAKE_SHARED_LIBRARY_SUFFIX}
    WORKING_DIRECTORY ${BLIS_DIR}/lib
    DEPENDEES install
  )

  # Dependencies:
  list(APPEND arpack-ng_dependencies "amd-blis")
  list(APPEND dealii_dependencies    "amd-blis")
  list(APPEND petsc_dependencies     "amd-blis")
  list(APPEND trilinos_dependencies  "amd-blis")
  list(APPEND scalapack_dependencies "amd-blis")
  list(APPEND libflame_dependencies  "amd-blis")
endif()

# Add blis to deal.II
list(APPEND arpack-ng_cmake_args "-D BLAS_LIBRARIES:PATH=${BLIS_DIR}/lib/libblas${CMAKE_SHARED_LIBRARY_SUFFIX}")

# Add blis to deal.II
list(APPEND dealii_cmake_args "-D DEAL_II_WITH_BLAS:BOOL=ON")
list(APPEND dealii_cmake_args "-D BLAS_DIR=${BLIS_DIR}")

# Add blis to PETSc
list(APPEND petsc_autotool_args "--with-blis=true")
list(APPEND petsc_autotool_args "--with-blis-dir=${BLIS_DIR}")

# Add blis to trilinos
list(APPEND trilinos_cmake_args "-D TPL_ENABLE_BLAS:BOOL=ON")
list(APPEND trilinos_cmake_args "-D BLAS_LIBRARY_NAMES=blis")
list(APPEND trilinos_cmake_args "-D BLAS_LIBRARY_DIRS:PATH=${BLIS_DIR}/lib")

# Add blis to ScaLAPACK
list(APPEND amd-scalapack_cmake_args "-D BLAS_LIBRARIES:STRING='${BLIS_DIR}/lib/libblis-mt${CMAKE_SHARED_LIBRARY_SUFFIX}'")

# Add blis to MUMPS
list(APPEND amd-mumps_cmake_args "-D BLAS_LIBRARY:PATH=${BLIS_DIR}/lib/libblas${CMAKE_SHARED_LIBRARY_SUFFIX}")

# Add blis to SuiteSparse
list(APPEND suitesparse_cmake_args "-D BLAS_LIBRARIES:PATH=${BLIS_DIR}/lib/libblis${CMAKE_SHARED_LIBRARY_SUFFIX}")

list(APPEND amd-libflame_cmake_args "-D ENABLE_AOCL_BLAS:BOOL=ON")
list(APPEND amd-libflame_cmake_args "-D AOCL_BLAS_INCLUDE_DIR:PATH=${BLIS_DIR}/include")
list(APPEND amd-libflame_cmake_args "-D AOCL_BLAS_LIB:PATH=${BLIS_DIR}/lib/libblis${CMAKE_SHARED_LIBRARY_SUFFIX}")
list(APPEND AOCL_ROOT "${BLIS_DIR}")
