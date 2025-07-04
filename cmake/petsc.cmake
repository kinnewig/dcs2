include(ExternalProject)

find_package(PETSC)
if(PETSC_FOUND)
  
else()
  message(STATUS "Building PETSC")

  list(APPEND petsc_autotool_args "--prefix=${CMAKE_INSTALL_PREFIX}/petsc/${PETSC_VERSION}")
  list(APPEND petsc_autotool_args "--with-debuggin")
  list(APPEND petsc_autotool_args "--with-shared-librarie")
  list(APPEND petsc_autotool_args "--with-mpi=1")
  list(APPEND petsc_autotool_args "--with-x=0")

  if(${DEALII_WITH_64BIT})
    list(APPEND petsc_autotool_args "--with-64-bit-indices=1")
  else()
    list(APPEND petsc_autotool_args "--with-64-bit-indices=0")
  endif()
  
  
  # get the download url for petsc:
  file(READ ${CMAKE_CURRENT_LIST_DIR}/libraries.json json)

  string(JSON petsc_url GET ${json} petsc git)
  string(JSON petsc_tag GET ${json} petsc ${PETSC_VERSION} tag)

  if (NOT petsc_tag)
    message(FATAL_ERROR "Git tag for PETSC version ${PETSC_VERSION} not found in ${CMAKE_CURRENT_LIST_DIR}/libraries.json.")
  endif()


  
  # If a custom URL for petsc is defined, use it.
  if (DEFINED PETSC_CUSTOM_URL)
    set(petsc_url ${PETSC_CUSTOM_URL})
    message("Using custom download URL for PETSC: ${PETSC_CUSTOM_URL}")
  endif()
  
  # If a custom tag for petsc is defined, use it.
  if (DEFINED PETSC_CUSTOM_TAG)
    set(petsc_tag ${PETSC_CUSTOM_TAG})
    message("Using custom git tag for PETSC: ${PETSC_CUSTOM_URL}")
  endif()
  
  if (DEFINED PETSC_SOURCE_DIR)
    ExternalProject_Add(petsc
      URL ${PETSC_SOURCE_DIR}
      BUILD_COMMAND make -j ${THREADS}
      INSTALL_COMMAND make install
      CONFIGURE_COMMAND ./configure ${petsc_autotool_args}
      INSTALL_DIR ${CMAKE_INSTALL_PREFIX}/petsc/${PETSC_VERSION}
      BUILD_IN_SOURCE ON
      BUILD_BYPRODUCTS ${PETSC_LIBRARIES}
      CMAKE_GENERATOR ${DEFAULT_GENERATOR}
      DEPENDS ${petsc_dependencies}
    )
  else()
    ExternalProject_Add(petsc
      GIT_REPOSITORY ${petsc_url}
      GIT_TAG ${petsc_tag}
      GIT_SHALLOW true
      BUILD_COMMAND make -j ${THREADS}
      INSTALL_COMMAND make install
      CONFIGURE_COMMAND ./configure ${petsc_autotool_args}
      INSTALL_DIR ${CMAKE_INSTALL_PREFIX}/petsc/${PETSC_VERSION}
      BUILD_IN_SOURCE ON
      BUILD_BYPRODUCTS ${PETSC_LIBRARIES}
      CMAKE_GENERATOR ${DEFAULT_GENERATOR}
      DEPENDS ${petsc_dependencies}
    )
  endif()
  
  ExternalProject_Get_Property(petsc INSTALL_DIR)

  # Populate the path
  set(PETSC_DIR ${INSTALL_DIR})
  list(APPEND CMAKE_PREFIX_PATH "${PETSC_DIR}")

  # Linking
  add_library(PETSC::PETSC INTERFACE IMPORTED GLOBAL)
  # TODO?
  #set_target_properties(PETSC::PETSC PROPERTIES
  #  IMPORTED_LOCATION ${PETSC_DIR}/lib/petsc${CMAKE_SHARED_LIBRARY_SUFFIX}
  #  INTERFACE_INCLUDE_DIRECTORIES ${PETSC_DIR}/include
  #)

  # Dependencies:
  # Add petsc as dependecie to deal.II
  list(APPEND dealii_dependencies "petsc")
endif()

# Add petsc to deal.II
list(APPEND dealii_cmake_args "-D DEAL_II_WITH_PETSC:BOOL=ON")
list(APPEND dealii_cmake_args "-D PETSC_DIR=${PETSC_DIR}")
