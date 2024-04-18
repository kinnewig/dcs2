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
  
  list(APPEND blis_autotool_args "--prefix=${CMAKE_INSTALL_PREFIX}/blis/${BLIS_VERSION}")
  list(APPEND blis_autotool_args "--enable-cblas")
  list(APPEND blis_autotool_args "CFLAGS='-DAOCL_F2C -fPIC'")
  list(APPEND blis_autotool_args "CXXFLAGS='-DAOCL_F2C -fPIC'")

  if (AMD)
    list(APPEND blis_autotool_args "--enable-aocl-dynamic")
  endif()
  
  # get the download url for blis:
  file(READ ${CMAKE_CURRENT_LIST_DIR}/libraries.json json)
  if (AMD)
    string(JSON blis_url GET ${json} amd blis git)
    string(JSON blis_tag GET ${json} amd blis ${AMD_VERSION} tag)
  else()
    string(JSON blis_url GET ${json} blis git)
    string(JSON blis_tag GET ${json} blis ${BLIS_VERSION} tag)
  endif()

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
    BUILD_COMMAND make -j ${THREADS}
    INSTALL_COMMAND make install
    CONFIGURE_COMMAND ./configure ${blis_autotool_args} ${BLIS_ARCHITECTURE}
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

  ExternalProject_Add_Step(
    blis blis_symlink
    COMMAND ln -s libblis${CMAKE_SHARED_LIBRARY_SUFFIX} libblas${CMAKE_SHARED_LIBRARY_SUFFIX}
    WORKING_DIRECTORY ${BLIS_DIR}/lib
    DEPENDEES install
  )

  # Linking
  add_library(BLIS::BLIS INTERFACE IMPORTED GLOBAL)
  set_target_properties(BLIS::BLIS PROPERTIES
    IMPORTED_LOCATION ${BLIS_DIR}/lib/libblis${CMAKE_SHARED_LIBRARY_SUFFIX}
    INTERFACE_INCLUDE_DIRECTORIES ${BLIS_DIR}/include
  )

  # Dependencies:
  # Add blis as dependecie to deal.II
  list(APPEND dealii_dependencies "blis")

  # Add blis as dependecie to trilinos
  list(APPEND trilinos_dependencies "blis")

  # Add blis as dependecie to ScaLAPACK
  list(APPEND scalapack_dependencies "blis")

  # Add blis as dependecie to LibFLAME
  list(APPEND libflame_dependencies "blis")
endif()

# Add blis to deal.II
list(APPEND dealii_cmake_args "-D DEAL_II_WITH_BLAS:BOOL=ON")
list(APPEND dealii_cmake_args "-D BLAS_DIR=${BLIS_DIR}")

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
