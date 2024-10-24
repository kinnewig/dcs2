include(ExternalProject)

find_package(OCCT)
if(OCCT_FOUND)


else()
  message(STATUS "Building OCCT")
  
  set(occt_cmake_args
    -D OCE_TESTING=OFF
    -D OCE_VISUALISATION=OFF
    -D OCE_DISABLE_X11=ON
    -D CMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}/occt/${OCCT_VERSION}
    -D CMAKE_C_COMPILER:PATH=${CMAKE_MPI_C_COMPILER}
    -D CMAKE_Fortran_COMPILER:PATH=${CMAKE_MPI_Fortran_COMPILER}
    -D CMAKE_BUILD_TYPE:STRING=Release
    ${occt_cmake_args}
  )

  # get the download url for occt:
  file(READ ${CMAKE_CURRENT_LIST_DIR}/libraries.json json)
  string(JSON occt_url GET ${json} occt git)
  string(JSON occt_tag GET ${json} occt ${OCCT_VERSION} tag)
  if (NOT occt_tag)
    message(FATAL_ERROR "Git tag for OCCT version ${OCCT_VERSION} not found in ${CMAKE_CURRENT_LIST_DIR}/libraries.json.")
  endif()
  
  # If a custom URL for occt is defined, use it.
  if (DEFINED OCCT_CUSTOM_URL)
    set(occt_url ${OCCT_CUSTOM_URL})
    message("Using custom download URL for OCCT: ${OCCT_CUSTOM_URL}")
  endif()
  
  # If a custom tag for occt is defined, use it.
  if (DEFINED OCCT_CUSTOM_TAG)
    set(occt_tag ${OCCT_CUSTOM_TAG})
    message("Using custom git tag for OCCT: ${OCCT_CUSTOM_TAG}")
  endif()

  if (DEFINED OCCT_SOURCE_DIR)
    ExternalProject_Add(occt
      URL ${OCCT_SOURCE_DIR}
      GIT_SHALLOW true
      CMAKE_ARGS ${occt_cmake_args}
      INSTALL_DIR ${CMAKE_INSTALL_PREFIX}/occt/${OCCT_VERSION}
      BUILD_BYPRODUCTS ${OCCT_LIBRARIES}
      CONFIGURE_HANDLED_BY_BUILD true
      CMAKE_GENERATOR ${DEFAULT_GENERATOR}
      DEPENDS ${occt_dependencies}
    ) 
  else()
    ExternalProject_Add(occt
      GIT_REPOSITORY ${occt_url}
      GIT_TAG ${occt_tag}
      GIT_SHALLOW true
      CMAKE_ARGS ${occt_cmake_args}
      INSTALL_DIR ${CMAKE_INSTALL_PREFIX}/occt/${OCCT_VERSION}
      BUILD_BYPRODUCTS ${OCCT_LIBRARIES}
      CONFIGURE_HANDLED_BY_BUILD true
      CMAKE_GENERATOR ${DEFAULT_GENERATOR}
      DEPENDS ${occt_dependencies}
    )
  endif()
  
  ExternalProject_Get_Property(occt INSTALL_DIR)
  
  # Populate the path
  set(OCCT_DIR ${INSTALL_DIR})
  list(APPEND CMAKE_PREFIX_PATH "${OCCT_DIR}")
  
  # Dependencies:
  # add OCCT as dependencie to trilinos
  list(APPEND dealii_dependencies "occt")
endif()

# Force deal.II to use OCCT
list(APPEND dealii_cmake_args "-D OPENCASCADE_DIR=${OCCT_DIR}")
