include(ExternalProject)

find_package(BLIS)
if (NOT BLIS_FOUND)
  message(STATUS "Building BLIS")

  # Set BLIS architecture if not defined yet
  if (NOT DEFINED BLIS_ARCHITECTURE)
    set(BLIS_ARCHITECTURE auto)
  endif()
  
  list(APPEND blis_autotool_args "--enable-cblas")
  list(APPEND blis_autotool_args "--prefix=${CMAKE_INSTALL_PREFIX}/blis/${BLIS_VERSION}")
  list(APPEND blis_autotool_args "CFLAGS='-DAOCL_F2C -fPIC'")
  list(APPEND blis_autotool_args "CXXFLAGS='-DAOCL_F2C -fPIC'")
  list(APPEND blis_autotool_args "CXXFLAGS='-DAOCL_F2C -fPIC'")

  list(APPEND blis_autotool_args "${BLIS_ARCHITECTURE}")
  
  build_autotools_subproject(blis)

  ExternalProject_Add_Step(
    blis blis_symlink_to_blas
    COMMAND ln -s libblis${CMAKE_SHARED_LIBRARY_SUFFIX} libblas${CMAKE_SHARED_LIBRARY_SUFFIX}
    WORKING_DIRECTORY ${BLIS_DIR}/lib
    DEPENDEES install
  )

  list(APPEND arpack-ng_dependencies "blis")
  list(APPEND dealii_dependencies    "blis")
  list(APPEND petsc_dependencies     "blis")
  list(APPEND trilinos_dependencies  "blis")
  list(APPEND scalapack_dependencies "blis")
  list(APPEND libflame_dependencies  "blis")
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
list(APPEND scalapack_cmake_args "-D BLAS_LIBRARY:PATH=${BLIS_DIR}/lib/libblas${CMAKE_SHARED_LIBRARY_SUFFIX}")

# Add blis to MUMPS
list(APPEND mumps_cmake_args "-D BLAS_LIBRARY:PATH=${BLIS_DIR}/lib/libblas${CMAKE_SHARED_LIBRARY_SUFFIX}")

# Add blis to SuiteSparse
list(APPEND suitesparse_cmake_args "-D BLAS_LIBRARIES:PATH=${BLIS_DIR}/lib/libblis${CMAKE_SHARED_LIBRARY_SUFFIX}")
