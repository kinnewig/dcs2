include(ExternalProject)

find_package(TRILINOS)
if(TRILINOS_FOUND)
  message(STATUS "TRILINOS found: ${TRILINOS_DIR}")
  return()
else()
  message(STATUS "Build TRILINOS")
endif()

set(trilinos_cmake_args
  -D BUILD_SHARED_LIBS:BOOL=ON 
  -D CMAKE_C_COMPILER=${CMAKE_C_COMPILER}
  -D CMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
  -D CMAKE_Fortran_COMPILER=${CMAKE_Fortran_COMPILER}
  -D CMAKE_BUILD_TYPE:STRING=RELEASE 
  -D CMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}/trilinos/${TRILINOS_VERSION}
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

# Trilinos with ScaLAPACK
if (DEFINED BLIS_DIR)
  list(APPEND trilinos_cmake_args "-D TPL_ENABLE_BLAS:BOOL=ON")
  list(APPEND trilinos_cmake_args "-D BLAS_LIBRARY_DIRS:STRING=${BLIS_DIR}/lib")
endif()

if (DEFINED SCALAPACK_DIR)
  list(APPEND trilinos_cmake_args "-D TPL_ENABLE_SCALAPACK:BOOL=ON")
  list(APPEND trilinos_cmake_args "-D SCALAPACK_LIBRARY_NAMES='scalapack'")
  list(APPEND trilinos_cmake_args "-D SCALAPACK_LIBRARY_DIRS:PATH=${SCALAPACK_DIR}/lib64")
  list(APPEND trilinos_cmake_args "-D Amesos_ENABLE_SCALAPACK:BOOL=ON")
endif()

# Trilinos with MUMPS
if (DEFINED MUMPS_DIR)
  list(APPEND trilinos_cmake_args "-D TPL_ENABLE_MUMPS=ON")
  list(APPEND trilinos_cmake_args "-D MUMPS_LIBRARY_DIRS:PATH=${MUMPS_DIR}/lib")
  list(APPEND trilinos_cmake_args "-D MUMPS_INCLUDE_DIRS:PATH=${MUMPS_DIR}/include")
  list(APPEND trilinos_cmake_args "-D Amesos_ENABLE_MUMPS:BOOL=ON")
endif()

# Complex number support
if ( TRILINOS_WITH_COMPLEX )
  list(APPEND trilinos_cmake_args "-D Trilinos_ENABLE_COMPLEX_DOUBLE=ON")
  list(APPEND trilinos_cmake_args "-D Trilinos_ENABLE_COMPLEX_FLOAT=ON")
  list(APPEND trilinos_cmake_args "-D Teuchos_ENABLE_COMPLEX:BOOL=ON")
endif()

# get the download url for trilinos:
file(READ ${CMAKE_CURRENT_LIST_DIR}/libraries.json json)
string(JSON trilinos_url GET ${json} trilinos git)
string(JSON trilinos_tag GET ${json} trilinos ${TRILINOS_VERSION} tag)

# If a custom URL for trilinos is defined, use it.
if (DEFINED TRILINOS_CUSTOM_URL)
  set(trilinos_url ${TRILINOS_CUSTOM_URL})
endif()

# If a custom tag for trilinos is defined, use it.
if (DEFINED TRILINOS_CUSTOM_TAG)
  set(trilinos_tag ${TRILINOS_CUSTOM_TAG})
endif()

ExternalProject_Add(
    trilinos
    GIT_REPOSITORY ${trilinos_url}
    GIT_TAG ${trilinos_tag}
    CMAKE_ARGS ${trilinos_cmake_args}
    BUILD_BYPRODUCTS ${TRILINOS_LIBRARIES}
    CMAKE_GENERATOR ${DEFAULT_GENERATOR}
)

set(TRILINOS_DIR "${trilinos_DIR}")

add_library(TRILINOS::TRILINOS INTERFACE IMPORTED GLOBAL)
target_include_directories(TRILINOS::TRILINOS INTERFACE ${TRILINOS_INCLUDE_DIRS})
target_link_libraries(TRILINOS::TRILINOS INTERFACE ${TRILINOS_LIBRARIES})

add_dependencies(TRILINOS::TRILINOS trilinos)

# Populate the path
set(TRILINOS_DIR "${CMAKE_INSTALL_PREFIX}/trilinos/${TRILINOS_VERSION}")
set(TRILINOS_LIBRARIES "${CMAKE_INSTALL_PREFIX}/trilinos/${TRILINOS_VERSION}/lib64")
set(TRILINOS_INCLUDE_DIRS "${CMAKE_INSTALL_PREFIX}/trilinos/${TRILINIOS_VERSION}/include")
