include(ExternalProject)

find_package(TBB)
if(TBB_FOUND)


else()
  message(STATUS "Building TBB")
  
  set(tbb_cmake_args
    -D TBB_STRICT:BOOL=OFF
    -D CMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}/tbb/${TBB_VERSION}
    -D CMAKE_C_COMPILER:PATH=${CMAKE_MPI_C_COMPILER}
    -D CMAKE_CXX_COMPILER:PATH=${CMAKE_MPI_CXX_COMPILER}
    -D CMAKE_Fortran_COMPILER:PATH=${CMAKE_MPI_Fortran_COMPILER}
    -D CMAKE_BUILD_TYPE:STRING=Release
    ${tbb_cmake_args}
  )

  # get the download url for tbb:
  file(READ ${CMAKE_CURRENT_LIST_DIR}/libraries.json json)
  string(JSON tbb_url GET ${json} tbb git)
  string(JSON tbb_tag GET ${json} tbb ${TBB_VERSION} tag)
  if (NOT tbb_tag)
    message(FATAL_ERROR "Git tag for TBB version ${TBB_VERSION} not found in ${CMAKE_CURRENT_LIST_DIR}/libraries.json.")
  endif()
  
  # If a custom URL for tbb is defined, use it.
  if (DEFINED TBB_CUSTOM_URL)
    set(tbb_url ${TBB_CUSTOM_URL})
    message("Using custom download URL for TBB: ${TBB_CUSTOM_URL}")
  endif()
  
  # If a custom tag for tbb is defined, use it.
  if (DEFINED TBB_CUSTOM_TAG)
    set(tbb_tag ${TBB_CUSTOM_TAG})
    message("Using custom git tag for TBB: ${TBB_CUSTOM_TAG}")
  endif()

  if (DEFINED TBB_SOURCE_DIR)
    ExternalProject_Add(tbb
      URL ${TBB_SOURCE_DIR}
      GIT_SHALLOW true
      CMAKE_ARGS ${tbb_cmake_args}
      INSTALL_DIR ${CMAKE_INSTALL_PREFIX}/tbb/${TBB_VERSION}
      BUILD_BYPRODUCTS ${TBB_LIBRARIES}
      CONFIGURE_HANDLED_BY_BUILD true
      CMAKE_GENERATOR ${DEFAULT_GENERATOR}
      DEPENDS ${tbb_dependencies}
    ) 
  else()
    ExternalProject_Add(tbb
      GIT_REPOSITORY ${tbb_url}
      GIT_TAG ${tbb_tag}
      GIT_SHALLOW true
      CMAKE_ARGS ${tbb_cmake_args}
      INSTALL_DIR ${CMAKE_INSTALL_PREFIX}/tbb/${TBB_VERSION}
      BUILD_BYPRODUCTS ${TBB_LIBRARIES}
      CONFIGURE_HANDLED_BY_BUILD true
      CMAKE_GENERATOR ${DEFAULT_GENERATOR}
      DEPENDS ${tbb_dependencies}
    )
  endif()
  
  ExternalProject_Get_Property(tbb INSTALL_DIR)
  
  # Populate the path
  set(TBB_DIR ${INSTALL_DIR})
  list(APPEND CMAKE_PREFIX_PATH "${TBB_DIR}")
  
  # Linking
  add_library(TBB::TBB INTERFACE IMPORTED GLOBAL)
  set_target_properties(TBB::TBB PROPERTIES
    IMPORTED_LOCATION ${TBB_DIR}/lib64/libstbb.so
    INTERFACE_INCLUDE_DIRECTORIES ${TBB_DIR}/include
  )

  # Dependencies:
  # add TBB as dependencie to OpenCascade
  list(APPEND occt_dependencies "tbb")

  # add TBB as dependencie to deal.II 
  list(APPEND dealii_dependencies "tbb")
endif()

# add TBB to OpenCascade
list(APPEND occt_cmake_args "-D 3RDPARTY_TBB_LIBRARY_DIR=${TBB_DIR}/lib64")

# add TBB to deal.II
list(APPEND dealii_cmake_args "-D TBB_DIR=${TBB_DIR}")
