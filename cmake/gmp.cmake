include(ExternalProject)

#find_package(GMP)
set(GMP_FOUND OFF)
if(GMP_FOUND)

else()
  message(STATUS "Building GMP")
  
  set(gmp_cmake_args
    -D CMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}/gmp/${GMP_VERSION}
    -D CMAKE_C_COMPILER:PATH=${CMAKE_C_COMPILER}
    -D CMAKE_CXX_COMPILER:PATH=${CMAKE_CXX_COMPILER}
    -D CMAKE_Fortran_COMPILER:PATH=${CMAKE_Fortran_COMPILER}
    -D CMAKE_BUILD_TYPE:STRING=Release
    ${gmp_cmake_args}
  )
  
  # get the download url for GMP:
  file(READ ${CMAKE_CURRENT_LIST_DIR}/libraries.json json)
  string(JSON gmp_url GET ${json} gmp git)
  string(JSON gmp_tag GET ${json} gmp ${GMP_VERSION} tag)
  if (NOT gmp_tag)
    message(FATAL_ERROR "Git tag for GMP version ${GMP_VERSION} not found in ${CMAKE_CURRENT_LIST_DIR}/libraries.json.")
  endif()
  
  # If a custom URL for GMP is defined, use it.
  if (DEFINED GMP_CUSTOM_URL)
    set(GMP_url ${GMP_CUSTOM_URL})
    message("Using custom download URL for MUMPS: ${GMP_CUSTOM_URL}")
  endif()
  
  # If a custom tag for GMP is defined, use it.
  if (DEFINED GMP_CUSTOM_TAG)
    set(mumps_tag ${GMP_CUSTOM_TAG})
    message("Using custom git tag for MUMPS: ${GMP_CUSTOM_TAG}")
  endif()
  
  ExternalProject_Add(gmp
    GIT_REPOSITORY ${gmp_url}
    GIT_TAG ${gmp_tag}
    GIT_SHALLOW true
    BUILD_COMMAND make
    INSTALL_COMMAND make install
    CMAKE_ARGS ${gmp_cmake_args}
    CONFIGURE_COMMAND ./configure --prefix=${CMAKE_INSTALL_PREFIX}/gmp/${GMP_VERSION} 
    INSTALL_DIR ${CMAKE_INSTALL_PREFIX}/gmp/${GMP_VERSION}
    BUILD_IN_SOURCE ON
    BUILD_BYPRODUCTS ${GMP_LIBRARIES}
    CMAKE_GENERATOR ${DEFAULT_GENERATOR}
    DEPENDS ${gmp_dependencies}
  )
  
  ExternalProject_Get_Property(gmp INSTALL_DIR)
  
  # Populate the path
  set(GMP_DIR ${INSTALL_DIR})
  list(APPEND CMAKE_PREFIX_PATH "${GMP_DIR}")
  
  # Linking
  add_library(GMP::GMP INTERFACE IMPORTED GLOBAL)
  set_target_properties(GMP::GMP PROPERTIES
    IMPORTED_LOCATION ${GMP_DIR}/lib64/libumfpack.so
    INTERFACE_INCLUDE_DIRECTORIES ${GMP_DIR}/include/gmp
  )

  # Dependencies:
  # add GMP as dependencie to suitesparse
  list(APPEND suitesparse_dependencies "gmp")
endif()

# add GMP to deal.II
list(APPEND suitesparse_cmake_args "-D GMP_INCLUDE_DIR=${GMP_DIR}/include")
list(APPEND suitesparse_cmake_args "-D GMP_LIBRARIES=${GMP_DIR}/lib")
