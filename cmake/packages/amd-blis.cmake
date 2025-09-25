include(ExternalProject)

find_package(AMD-BLIS)
if (NOT AMD-BLIS_FOUND)
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

  # symlink blis to blas:
  ExternalProject_Add_Step(
    amd-blis blis_symlink_to_blas
    COMMAND ln -sf libblis-mt${CMAKE_SHARED_LIBRARY_SUFFIX} libblas${CMAKE_SHARED_LIBRARY_SUFFIX}
    COMMAND ln -sf libblis-mt${CMAKE_SHARED_LIBRARY_SUFFIX} libblis${CMAKE_SHARED_LIBRARY_SUFFIX}
    COMMAND ln -sf libblis-mt.a libblis.a
    WORKING_DIRECTORY ${AMD-BLIS_DIR}/lib
    DEPENDEES install
  )

  # symlink for amd-blis to work with petsc
  ExternalProject_Add_Step(
    amd-blis blis_symlink_inluce
    COMMAND ln -sf ${AMD-BLIS_DIR}/include ${AMD-BLIS_DIR}/include/blis
    WORKING_DIRECTORY ${AMD-BLIS_DIR}
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

# Add blis to arpack-ng
list(APPEND arpack-ng_cmake_args "-D BLAS_LIBRARIES:PATH=${AMD-BLIS_DIR}/lib/libblas${CMAKE_SHARED_LIBRARY_SUFFIX}")

# Add blis to deal.II
list(APPEND dealii_cmake_args "-D DEAL_II_WITH_BLAS:BOOL=ON")
list(APPEND dealii_cmake_args "-D BLAS_DIR=${AMD-BLIS_DIR}")

# Add blis to PETSc
list(APPEND petsc_autotool_args "--with-blis=true")
list(APPEND petsc_autotool_args "--with-blis-dir=${AMD-BLIS_DIR}")

# Add blis to trilinos
list(APPEND trilinos_cmake_args "-D TPL_ENABLE_BLAS:BOOL=ON")
list(APPEND trilinos_cmake_args "-D BLAS_LIBRARY_NAMES=blis")
list(APPEND trilinos_cmake_args "-D BLAS_LIBRARY_DIRS:PATH=${AMD-BLIS_DIR}/lib")

# Add blis to ScaLAPACK
list(APPEND amd-scalapack_cmake_args "-D BLAS_LIBRARIES:STRING='${AMD-BLIS_DIR}/lib/libblis-mt${CMAKE_SHARED_LIBRARY_SUFFIX}'")

# Add blis to MUMPS
list(APPEND amd-mumps_cmake_args "-D BLAS_LIBRARY:PATH=${AMD-BLIS_DIR}/lib/libblas${CMAKE_SHARED_LIBRARY_SUFFIX}")
list(APPEND amd-mumps_cmake_args "-D USER_PROVIDED_BLIS_LIBRARY_PATH:PATH=${AMD-BLIS_DIR}")
list(APPEND amd-mumps_cmake_args "-D USER_PROVIDED_BLIS_INCLUDE_PATH:PATH=${AMD-BLIS_DIR}")

# Add blis to SuiteSparse
list(APPEND suitesparse_cmake_args "-D BLAS_LIBRARIES:PATH=${AMD-BLIS_DIR}/lib/libblis${CMAKE_SHARED_LIBRARY_SUFFIX}")

# Add blis to libflame
list(APPEND amd-libflame_cmake_args "-D ENABLE_AOCL_BLAS:BOOL=ON")
list(APPEND amd-libflame_cmake_args "-D AOCL_BLAS_INCLUDE_DIR:PATH=${AMD-BLIS_DIR}/include")
list(APPEND amd-libflame_cmake_args "-D AOCL_BLAS_LIB:PATH=${AMD-BLIS_DIR}/lib/libblis${CMAKE_SHARED_LIBRARY_SUFFIX}")
