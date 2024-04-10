include(ExternalProject)

find_package(SUITESPARSE)
if(SUITESPARSE_FOUND)

else()
  message(STATUS "Building SuiteSparse")
  
  set(suitesparse_cmake_args
    -D SUITESPARSE_USE_64BIT_BLAS:BOOL=ON
    -D CMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}/suitesparse/${SUITESPARSE_VERSION}
    -D CMAKE_C_COMPILER:PATH=${CMAKE_C_COMPILER}
    -D CMAKE_Fortran_COMPILER:PATH=${CMAKE_Fortran_COMPILER}
    -D CMAKE_BUILD_TYPE:STRING=Release
    ${suitesparse_cmake_args}
  )
  
  # get the download url for SuiteSparse:
  file(READ ${CMAKE_CURRENT_LIST_DIR}/libraries.json json)
  string(JSON suitesparse_url GET ${json} suitesparse git)
  string(JSON suitesparse_tag GET ${json} suitesparse ${SUITESPARSE_VERSION} tag)
  if (NOT suitesparse_tag)
    message(FATAL_ERROR "Git tag for SUITESPARSE version ${SUITESPARSE_VERSION} not found in ${CMAKE_CURRENT_LIST_DIR}/libraries.json.")
  endif()
  
  # If a custom URL for SuiteSparse is defined, use it.
  if (DEFINED SUITESPARSE_CUSTOM_URL)
    set(SUITESPARSE_url ${SUITESPARSE_CUSTOM_URL})
    message("Using custom download URL for MUMPS: ${SUITESPARSE_CUSTOM_URL}")
  endif()
  
  # If a custom tag for SuiteSparse is defined, use it.
  if (DEFINED SUITESPARSE_CUSTOM_TAG)
    set(mumps_tag ${SUITESPARSE_CUSTOM_TAG})
    message("Using custom git tag for MUMPS: ${SUITESPARSE_CUSTOM_TAG}")
  endif()
  
  ExternalProject_Add(suitesparse
    GIT_REPOSITORY ${suitesparse_url}
    GIT_TAG ${suitesparse_tag}
    GIT_SHALLOW true
    CMAKE_ARGS ${suitesparse_cmake_args}
    INSTALL_DIR ${CMAKE_INSTALL_PREFIX}/suitesparse/${SUITESPARSE_VERSION}
    BUILD_BYPRODUCTS ${SUITESPARSE_LIBRARIES}
    CONFIGURE_HANDLED_BY_BUILD true
    CMAKE_GENERATOR ${DEFAULT_GENERATOR}
    DEPENDS ${suitesparse_dependencies}
  )
  
  ExternalProject_Get_Property(suitesparse INSTALL_DIR)
  
  # Populate the path
  set(SUITESPARSE_DIR ${INSTALL_DIR})
  list(APPEND CMAKE_PREFIX_PATH "${SUITESPARSE_DIR}")
  
  # Linking
  add_library(SUITESPARSE::SUITESPARSE INTERFACE IMPORTED GLOBAL)
  set_target_properties(SUITESPARSE::SUITESPARSE PROPERTIES
    IMPORTED_LOCATION ${SUITESPARSE_DIR}/lib64/libumfpack.so
    INTERFACE_INCLUDE_DIRECTORIES ${SUITESPARSE_DIR}/include/suitesparse
  )

  # Dependencies:
  # add SuiteSparse as dependencie to trilinos
  list(APPEND trilinos_dependencies "suitesparse")
endif()

# add SuiteSparse to deal.II
list(APPEND dealii_cmake_args "-D DEAL_II_WITH_UMFPACK:BOO=ON")
list(APPEND dealii_cmake_args "-D UMFPACK_DIR=${UMFPACK_DIR}")

# add SuiteSparse to Trilinos
list(APPEND trilinos_cmake_args "-D TPL_ENABLE_UMFPACK=ON")
list(APPEND trilinos_cmake_args "-D UMFPACK_LIBRARY_DIRS:PATH=${SUITESPARSE_DIR}/lib64")
list(APPEND trilinos_cmake_args "-D UMFPACK_INCLUDE_DIRS:PATH=${SUITESPARSE_DIR}/include/suitesparse")
