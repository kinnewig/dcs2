include(ExternalProject)

find_package(TRILINOS)
if(TRILINOS_FOUND)
  message(STATUS "TRILINOS found: ${TRILINOS_DIR}")
  return()
endif()

# Trilinos
set(trilinos_tag "trilinos-release-15-1-0")
set(trilinos_url "https://github.com/trilinos/trilinos.git")

set(trilinos_cmake_args,
  -D BUILD_SHARED_LIBS:BOOL=ON 
  -D CMAKE_C_COMPILER=mpicc 
  -D CMAKE_CXX_COMPILER=mpicxx 
  -D CMAKE_Fortran_COMPILER=mpifort 
  -D CMAKE_BUILD_TYPE:STRING=RELEASE 
  -D CMAKE_INSTALL_PREFIX:PATH=${INSTALL_PREFIX}/trilinos/${TRILINOS_VERSION}
  -D CMAKE_POSITION_INDEPENDENT_CODE:BOOL=ON 
  -D CMAKE_VERBOSE_MAKEFILE:BOOL=OFF 
  -D TPL_ENABLE_Boost:BOOL=ON 
  -D TPL_ENABLE_MPI:BOOL=ON 
  -D TPL_ENABLE_Matio=OFF 
  -D TPL_ENABLE_TBB:BOOL=OFF 
  -D TPL_ENABLE_BLAS:BOOL=ON 
  -D Trilinos_VERBOSE_CONFIGURE:BOOL=OFF 
  -D Trilinos_ENABLE_EXPLICIT_INSTANTIATION:BOOL=ON 
  -D Trilinos_ENABLE_ALL_PACKAGES:BOOL=OFF 
  -D Trilinos_ENABLE_ALL_OPTIONAL_PACKAGES:BOOL=OFF 
  -D Trilinos_ENABLE_Amesos:BOOL=ON 
  -D Trilinos_ENABLE_Amesos2:BOOL=ON 
  -D Trilinos_ENABLE_AztecOO:BOOL=ON 
  -D Trilinos_ENABLE_Belos:BOOL=ON 
  -D Trilinos_ENABLE_Epetra:BOOL=ON 
  -D Trilinos_ENABLE_EpetraExt:BOOL=ON 
  -D Trilinos_ENABLE_Fortran:BOOL=ON 
  -D Trilinos_ENABLE_Ifpack:BOOL=ON  
  -D Trilinos_ENABLE_Ifpack2:BOOL=ON 
  -D Trilinos_ENABLE_ML:BOOL=ON 
  -D Trilinos_ENABLE_MueLu:BOOL=ON 
  -D Trilinos_ENABLE_OpenMP:BOOL=OFF 
  -D Trilinos_ENABLE_Sacado:BOOL=ON 
  -D Trilinos_ENABLE_Sacado:BOOL=ON 
  -D Trilinos_ENABLE_ShyLU_DD:BOOL=ON 
  -D   ShyLU_DD_ENABLE_TESTS:BOOL=ON 
  -D Trilinos_ENABLE_Stratimikos:BOOL=ON 
  -D Trilinos_ENABLE_Thyra:BOOL=ON 
  -D Trilinos_ENABLE_Tpetra:BOOL=ON 
  -D   Tpetra_ENABLE_DEPRECATED_CODE:BOOL=ON 
  -D   Tpetra_INST_INT_LONG_LONG:BOOL=ON 
  -D Trilinos_ENABLE_ROL:BOOL=ON 
  -D Trilinos_ENABLE_Xpetra:BOOL=ON 
  -D   Xpetra_ENABLE_DEPRECATED_CODE:BOOL=ON 
  -D Trilinos_ENABLE_Zoltan:BOOL=ON 
  -D Kokkos_ENABLE_SERIAL:BOOL=ON 
  -D Kokkos_ENABLE_TESTS:BOOL=ON 
)

# Trilinos with MUMPS
list(APPEND "-D TPL_ENABLE_MUMPS=ON")
list(APPEND "-D MUMPS_INCLUDE_DIRS:STRING=${mumps_DIR}/include")
list(APPEND "-D MUMPS_LIBRARY_DIRS:STRING=${mumps_DIR}/lib")

# Complex number support
if ( DEALII_WITH_COMPLEX )
  list(APPEND trilinos_cmake_args "-D Trilinos_ENABLE_COMPLEX_DOUBLE=ON")
  list(APPEND trilinos_cmake_args "-D Trilinos_ENABLE_COMPLEX_FLOAT=ON")
  list(APPEND trilinos_cmake_args "-D Teuchos_ENABLE_COMPLEX:BOOL=ON")
endif()

ExternalProject_Add(
    trilinos
    GIT_REPOSITORY ${trilinos_url}
    GIT_TAG ${trilinos_tag}
    CMAKE_ARGS ${trilinos_cmake_args}
    BUILD_BYPRODUCTS ${TRILINOS_LIBRARIES}
    BUILD_COMMAND ${DEFAULT_BUILD_COMMAND}
)

set(TRILINOS_DIR "${trilinos_DIR}")
