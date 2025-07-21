include(ExternalProject)

find_package(SLEPC)
if(SLEPC_FOUND)
  
else()
  message(STATUS "Building SLEPC")

  list(APPEND slepc_autotool_args "--prefix=${CMAKE_INSTALL_PREFIX}/slepc/${SLEPC_VERSION}")
 
  # get the download url for slepc:
  file(READ ${CMAKE_CURRENT_LIST_DIR}/../libraries.json json)

  string(JSON slepc_url GET ${json} slepc git)
  string(JSON slepc_tag GET ${json} slepc ${SLEPC_VERSION})

  if (NOT slepc_tag)
    message(FATAL_ERROR "Git tag for SLEPC version ${SLEPC_VERSION} not found in ${CMAKE_CURRENT_LIST_DIR}/../libraries.json.")
  endif()
  
  # If a custom URL is defined, use it.
  if (DEFINED SLEPC_CUSTOM_URL)
    set(slepc_url ${SLEPC_CUSTOM_URL})
    message("Using custom download URL for SLEPC: ${SLEPC_CUSTOM_URL}")
  endif()
  
  # If a custom tag is defined, use it.
  if (DEFINED SLEPC_CUSTOM_TAG)
    set(slepc_tag ${SLEPC_CUSTOM_TAG})
    message("Using custom git tag for SLEPC: ${SLEPC_CUSTOM_URL}")
  endif()

  if (DEFINED SLEPC_SOURCE_DIR)
    ExternalProject_Add(slepc
      URL ${SLEPC_SOURCE_DIR}
      BUILD_COMMAND make PETSC_DIR=${PETSC_DIR} SLEPC_DIR=${CMAKE_BINARY_DIR}/slepc-prefix/src/slepc -j ${THREADS} 
      INSTALL_COMMAND make PETSC_DIR=${PETSC_DIR} SLEPC_DIR=${CMAKE_BINARY_DIR}/slepc-prefix/src/slepc install 
      CONFIGURE_COMMAND PETSC_DIR=${PETSC_DIR} ./configure ${slepc_autotool_args}
      INSTALL_DIR ${CMAKE_INSTALL_PREFIX}/slepc/${SLEPC_VERSION}
      BUILD_IN_SOURCE ON
      BUILD_BYPRODUCTS ${SLEPC_LIBRARIES}
      CMAKE_GENERATOR ${DEFAULT_GENERATOR}
      DEPENDS ${slepc_dependencies}
    )
  else()
    ExternalProject_Add(slepc
      GIT_REPOSITORY ${slepc_url}
      GIT_TAG ${slepc_tag}
      GIT_SHALLOW true
      BUILD_COMMAND make PETSC_DIR=${PETSC_DIR} SLEPC_DIR=${CMAKE_BINARY_DIR}/slepc-prefix/src/slepc -j ${THREADS} 
      INSTALL_COMMAND make PETSC_DIR=${PETSC_DIR} SLEPC_DIR=${CMAKE_BINARY_DIR}/slepc-prefix/src/slepc install 
      CONFIGURE_COMMAND PETSC_DIR=${PETSC_DIR} ./configure ${slepc_autotool_args}
      INSTALL_DIR ${CMAKE_INSTALL_PREFIX}/slepc/${SLEPC_VERSION}
      BUILD_IN_SOURCE ON
      BUILD_BYPRODUCTS ${SLEPC_LIBRARIES}
      CMAKE_GENERATOR ${DEFAULT_GENERATOR}
      DEPENDS ${slepc_dependencies}
    )
  endif()
  
  ExternalProject_Get_Property(slepc INSTALL_DIR)

  # Populate the path
  set("SLEPC_DIR" "${INSTALL_DIR}" CACHE INTERNAL "")


  # Dependencies:
  list(APPEND dealii_dependencies "slepc")
endif()

# Add slepc to deal.II
list(APPEND dealii_cmake_args "-D DEAL_II_WITH_SLEPC:BOOL=ON")
list(APPEND dealii_cmake_args "-D SLEPC_DIR=${SLEPC_DIR}")
