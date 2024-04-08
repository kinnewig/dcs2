include(ExternalProject)

find_package(BLIS)
if(BLIS_FOUND)
  message(STATUS "BLIS found: ${BLIS_DIR}")
  
else()
  message(STATUS "Building BLIS")

  # Set BLIS architecture if not defined yet
  if (NOT DEFINED BLIS_ARCHITECTURE)
    set(BLIS_ARCHITECTURE auto)
  endif()
  
  set(blis_autotool_args '--prefix=${CMAKE_INSTALL_PREFIX}/blis/${BLIS_VERSION} --enable-cblas CFLAGS="-DAOCL_F2C -fPIC" CXXFLAGS="-DAOCL_F2C -fPIC" ${BLIS_ARCHITECTURE} ${blis_autotool_args}')
  
  # get the download url for blis:
  file(READ ${CMAKE_CURRENT_LIST_DIR}/libraries.json json)
  string(JSON blis_url GET ${json} blis git)
  string(JSON blis_tag GET ${json} blis ${BLIS_VERSION} tag)
  if (NOT blis_tag)
    message(FATAL_ERROR "Git tag for BLIS version ${BLIS_VERSION} not found in ${CMAKE_CURRENT_LIST_DIR}/libraries.json.")
  endif()
  
  # If a custom URL for blis is defined, use it.
  if (DEFINED BLIS_CUSTOM_URL)
    set(blis_url ${BLIS_CUSTOM_URL})
    message("Using custom download URL for BLIS: ${BLIS_CUSTOM_URL}")
  endif()
  
  # If a custom tag for blis is defined, use it.
  if (DEFINED BLIS_CUSTOM_TAG)
    set(blis_tag ${BLIS_CUSTOM_TAG})
    message("Using custom git tag for BLIS: ${BLIS_CUSTOM_URL}")
  endif()
  
  ExternalProject_Add(blis
    GIT_REPOSITORY ${blis_url}
    GIT_TAG ${blis_tag}
    GIT_SHALLOW true
    BUILD_COMMAND make
    INSTALL_COMMAND make install
    CONFIGURE_COMMAND ./configure ${blis_autotool_args}
    INSTALL_DIR ${CMAKE_INSTALL_PREFIX}/blis/${BLIS_VERSION}
    BUILD_IN_SOURCE ON
    BUILD_BYPRODUCTS ${BLIS_LIBRARIES}
    CMAKE_GENERATOR ${DEFAULT_GENERATOR}
    DEPENDS ${blis_dependencies}
  )
  
  ExternalProject_Get_Property(blis INSTALL_DIR)

  # Populate the path
  set(BLIS_DIR ${INSTALL_DIR})
  list(APPEND CMAKE_PREFIX_PATH "${BLIS_DIR}")

  # Linking
  add_library(BLIS::BLIS INTERFACE IMPORTED GLOBAL)
  set_target_properties(BLIS::BLIS PROPERTIES
    IMPORTED_LOCATION ${BLIS_DIR}/lib/libblis.so
    INTERFACE_INCLUDE_DIRECTORIES ${BLIS_DIR}/include
  )

  # Dependencies:
  # Add blis as dependecie to deal.II
  list(APPEND dealii_dependencies "blis")

  # Add blis as dependecie to trilinos
  list(APPEND trilinos_dependencies "blis")

  # Add blis as dependecie to ScaLAPACK
  list(APPEND scalapack_dependencies "blis")

endif()

# Add blis to deal.II
list(APPEND dealii_cmake_args "-D DEAL_II_WITH_BLAS:BOOL=ON")
list(APPEND dealii_cmake_args "-D BLAS_DIR=${BLIS_DIR}")

# Add blis to trilinos
list(APPEND trilinos_cmake_args "-D TPL_ENABLE_BLAS:BOOL=ON")
list(APPEND trilinos_cmake_args "-D BLAS_LIBRARY_NAMES=blis")
list(APPEND trilinos_cmake_args "-D BLAS_LIBRARY_DIRS:PATH=${BLIS_DIR}/lib")

# Add blis to ScaLAPACK
list(APPEND scalapack_cmake_args "-D BLAS_LIBRARIES:PATH=${BLIS_DIR}/lib/libblis${CMAKE_SHARED_LIBRARY_SUFFIX}")

# Add blis to SuiteSparse
list(APPEND suitesparse_cmake_args "-D BLAS_LIBRARIES:PATH=${BLIS_DIR}/lib/libblis${CMAKE_SHARED_LIBRARY_SUFFIX}")
