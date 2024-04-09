include(ExternalProject)

find_package(MPFR)
if(MPFR_FOUND)

else()
  message(STATUS "Building MPFR")
  
  set(mpfr_cmake_args
    -D CMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}/mpfr/${MPFR_VERSION}
    -D CMAKE_C_COMPILER:PATH=${CMAKE_C_COMPILER}
    -D CMAKE_CXX_COMPILER:PATH=${CMAKE_CXX_COMPILER}
    -D CMAKE_Fortran_COMPILER:PATH=${CMAKE_Fortran_COMPILER}
    -D CMAKE_BUILD_TYPE:STRING=Release
    ${mpfr_cmake_args}
  )
  
  # get the download url for MPFR:
  file(READ ${CMAKE_CURRENT_LIST_DIR}/libraries.json json)
  string(JSON mpfr_url GET ${json} mpfr git)
  string(JSON mpfr_tag GET ${json} mpfr ${MPFR_VERSION} tag)
  if (NOT mpfr_tag)
    message(FATAL_ERROR "Git tag for MPFR version ${MPFR_VERSION} not found in ${CMAKE_CURRENT_LIST_DIR}/libraries.json.")
  endif()
  
  # If a custom URL for MPFR is defined, use it.
  if (DEFINED MPFR_CUSTOM_URL)
    set(MPFR_url ${MPFR_CUSTOM_URL})
    message("Using custom download URL for MUMPS: ${MPFR_CUSTOM_URL}")
  endif()
  
  # If a custom tag for MPFR is defined, use it.
  if (DEFINED MPFR_CUSTOM_TAG)
    set(mumps_tag ${MPFR_CUSTOM_TAG})
    message("Using custom git tag for MUMPS: ${MPFR_CUSTOM_TAG}")
  endif()
  
  ExternalProject_Add(mpfr
    GIT_REPOSITORY ${mpfr_url}
    GIT_TAG ${mpfr_tag}
    GIT_SHALLOW true
    BUILD_COMMAND make
    INSTALL_COMMAND make install
    CMAKE_ARGS ${mpfr_cmake_args}
    CONFIGURE_COMMAND ./autogen.sh && ./configure --prefix=${CMAKE_INSTALL_PREFIX}/mpfr/${MPFR_VERSION} 
    INSTALL_DIR ${CMAKE_INSTALL_PREFIX}/mpfr/${MPFR_VERSION}
    BUILD_IN_SOURCE ON
    BUILD_BYPRODUCTS ${MPFR_LIBRARIES}
    CMAKE_GENERATOR ${DEFAULT_GENERATOR}
    DEPENDS ${mpfr_dependencies}
  )
  
  ExternalProject_Get_Property(mpfr INSTALL_DIR)
  
  # Populate the path
  set(MPFR_DIR ${INSTALL_DIR})
  list(APPEND CMAKE_PREFIX_PATH "${MPFR_DIR}")
  
  # Linking
  add_library(MPFR::MPFR INTERFACE IMPORTED GLOBAL)
  set_target_properties(MPFR::MPFR PROPERTIES
    IMPORTED_LOCATION ${MPFR_DIR}/lib64/libumfpack.so
    INTERFACE_INCLUDE_DIRECTORIES ${MPFR_DIR}/include/mpfr
  )

  set(MPFR_LIBRARY "${MPFR_DIR}/lib")
  set(MPFR_INCLUDE_DIR "${MPFR_DIR}/include")

  # Dependencies:
  # add MPFR as dependencie to SuiteSparse
  list(APPEND suitesparse_dependencies "mpfr")
endif()

# add MPFR to SuiteSparse
list(APPEND suitesparse_cmake_args "-D MPFR_INCLUDE_DIR=${MPFR_INCLUDE_DIR}")
list(APPEND suitesparse_cmake_args "-D MPFR_LIBRARIES=${MPFR_LIBRARY}")
