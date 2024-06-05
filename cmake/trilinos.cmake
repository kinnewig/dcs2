include(ExternalProject)

find_package(TRILINOS)
if(TRILINOS_FOUND)

else()
  message(STATUS "Build TRILINOS")

  set(trilinos_cmake_args
    -D BUILD_SHARED_LIBS:BOOL=ON 
    -D CMAKE_C_COMPILER=${CMAKE_MPI_C_COMPILER}
    -D CMAKE_C_FLAGS="${CMAKE_C_FLAGS}-Wno-error=implicit-function-declaration"
    -D CMAKE_CXX_COMPILER=${CMAKE_MPI_CXX_COMPILER}
    -D CMAKE_CXX_FLAGS="${CMAKE_CXX_FLAGS}-Wno-error=implicit-function-declaration"
    -D CMAKE_Fortran_COMPILER=${CMAKE_MPI_Fortran_COMPILER}
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
    -D   ShyLU_DD_ENABLE_TESTS:BOOL=OFF 
    -D Trilinos_ENABLE_Stratimikos:BOOL=ON 
    -D Trilinos_ENABLE_Thyra:BOOL=ON 
    -D Trilinos_ENABLE_Tpetra:BOOL=ON 
    -D   Tpetra_ENABLE_DEPRECATED_CODE:BOOL=ON 
    -D Trilinos_ENABLE_ROL:BOOL=ON 
    -D Trilinos_ENABLE_Xpetra:BOOL=ON 
    -D   Xpetra_ENABLE_DEPRECATED_CODE:BOOL=ON 
    -D Trilinos_ENABLE_Zoltan:BOOL=ON 
    -D Kokkos_ENABLE_SERIAL:BOOL=ON 
    -D Kokkos_ENABLE_TESTS:BOOL=OFF
    ${trilinos_cmake_args}
  )

  # Trilinos index
  if(${DEALII_WITH_64BIT})
    list(APPEND trilinos_cmake_args "-D Tpetra_INST_INT_LONG_LONG:BOOL=ON")
  else()
    list(APPEND trilinos_cmake_args "-D TPETRA_INST_INT_INT:BOOL=ON")
  endif()
  

  # Trilinos with BOOST
  if (DEFINED BOOST_DIR)
    #list(APPEND trilinos_cmake_args "-D TPL_ENABLE_BOOST:BOOL=ON")
    list(APPEND trilinos_cmake_args "-D Boost_LIBRARY_DIRS:PATH=${BOOST_DIR}/lib64")
    list(APPEND trilinos_cmake_args "-D Boost_INCLUDE_DIRS:PATH=${BOOST_DIR}/include")
  endif()
  

  
  # Complex number support
  if ( DEALII_WITH_COMPLEX )
    list(APPEND trilinos_cmake_args "-D Trilinos_ENABLE_COMPLEX_DOUBLE:BOOL=ON")
    list(APPEND trilinos_cmake_args "-D Trilinos_ENABLE_COMPLEX_FLOAT:BOOL=ON")
    list(APPEND trilinos_cmake_args "-D Teuchos_ENABLE_COMPLEX:BOOL=ON")
  endif()
  
  # get the download url for trilinos:
  file(READ ${CMAKE_CURRENT_LIST_DIR}/libraries.json json)
  string(JSON trilinos_url GET ${json} trilinos git)
  string(JSON trilinos_tag GET ${json} trilinos ${TRILINOS_VERSION} tag)
  
  # If a custom URL for trilinos is defined, use it.
  if (DEFINED TRILINOS_CUSTOM_URL)
    set(trilinos_url ${TRILINOS_CUSTOM_URL})
    message("Using custom download URL for Trilinos: ${TRILINOS_CUSTOM_URL}")
  endif()
  
  # If a custom tag for trilinos is defined, use it.
  if (DEFINED TRILINOS_CUSTOM_TAG)
    set(trilinos_tag ${TRILINOS_CUSTOM_TAG})
    message("Using custom git tag for Trilinos: ${TRILINOS_CUSTOM_TAG}")
  endif()
  
  if (DEFINED TRILINOS_SOURCE_DIR)
    ExternalProject_Add(
        trilinos
        URL ${TRILINOS_SOURCE_DIR}
        CMAKE_ARGS ${trilinos_cmake_args}
        INSTALL_DIR ${CMAKE_INSTALL_PREFIX}/trilinos/${TRILINOS_VERSION}
        CMAKE_GENERATOR ${DEFAULT_GENERATOR}
        DEPENDS ${trilinos_dependencies}
    )
  else()
    ExternalProject_Add(
        trilinos
        GIT_REPOSITORY ${trilinos_url}
        GIT_TAG ${trilinos_tag}
        CMAKE_ARGS ${trilinos_cmake_args}
        INSTALL_DIR ${CMAKE_INSTALL_PREFIX}/trilinos/${TRILINOS_VERSION}
        CMAKE_GENERATOR ${DEFAULT_GENERATOR}
        DEPENDS ${trilinos_dependencies}
    )
  endif()
  
  ExternalProject_Get_Property(trilinos INSTALL_DIR)
  
  # Populate the path
  set(TRILINOS_DIR ${INSTALL_DIR})
  list(APPEND CMAKE_PREFIX_PATH "${TRILINOS_DIR}")
  
  # Linking
  # TODO: This is old method rework this to be more similar 
  #       to ScaLAPACK and MUMPS
  link_directories(${TRILINOS_DIR})

  # Dependencies:
  # Add trilinos as dependencie to deal.II 
  list(APPEND dealii_dependencies "trilinos")
endif()

# Add trilinos to deal.II
list(APPEND dealii_cmake_args "-D DEAL_II_WITH_TRILINOS:BOOL=ON")
list(APPEND dealii_cmake_args "-D TRILINOS_DIR=${TRILINOS_DIR}")
