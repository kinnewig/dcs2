include(ExternalProject)

find_package(SLEPSC)
if(SLEPSC_FOUND)
  
else()
  message(STATUS "Building SLEPSC")

  list(APPEND slepsc_autotool_args "--prefix=${CMAKE_INSTALL_PREFIX}/slepsc/${SLEPSC_VERSION}")
  
  # get the download url for slepsc:
  file(READ ${CMAKE_CURRENT_LIST_DIR}/libraries.json json)

  string(JSON slepsc_url GET ${json} slepsc git)
  string(JSON slepsc_tag GET ${json} slepsc ${SLEPSC_VERSION} tag)

  if (NOT slepsc_tag)
    message(FATAL_ERROR "Git tag for SLEPSC version ${SLEPSC_VERSION} not found in ${CMAKE_CURRENT_LIST_DIR}/libraries.json.")
  endif()

  
  # If a custom URL for slepsc is defined, use it.
  if (DEFINED SLEPSC_CUSTOM_URL)
    set(slepsc_url ${SLEPSC_CUSTOM_URL})
    message("Using custom download URL for SLEPSC: ${SLEPSC_CUSTOM_URL}")
  endif()
  
  # If a custom tag for slepsc is defined, use it.
  if (DEFINED SLEPSC_CUSTOM_TAG)
    set(slepsc_tag ${SLEPSC_CUSTOM_TAG})
    message("Using custom git tag for SLEPSC: ${SLEPSC_CUSTOM_URL}")
  endif()
  
  if (DEFINED SLEPSC_SOURCE_DIR)
    ExternalProject_Add(slepsc
      URL ${SLEPSC_SOURCE_DIR}
      BUILD_COMMAND make -j ${THREADS}
      INSTALL_COMMAND make install
      CONFIGURE_COMMAND ./configure ${slepsc_autotool_args}
      INSTALL_DIR ${CMAKE_INSTALL_PREFIX}/slepsc/${SLEPSC_VERSION}
      BUILD_IN_SOURCE ON
      BUILD_BYPRODUCTS ${SLEPSC_LIBRARIES}
      CMAKE_GENERATOR ${DEFAULT_GENERATOR}
      DEPENDS ${slepsc_dependencies}
    )
  else()
    ExternalProject_Add(slepsc
      GIT_REPOSITORY ${slepsc_url}
      GIT_TAG ${slepsc_tag}
      GIT_SHALLOW true
      BUILD_COMMAND make -j ${THREADS}
      INSTALL_COMMAND make install
      CONFIGURE_COMMAND ./configure ${slepsc_autotool_args}
      INSTALL_DIR ${CMAKE_INSTALL_PREFIX}/slepsc/${SLEPSC_VERSION}
      BUILD_IN_SOURCE ON
      BUILD_BYPRODUCTS ${SLEPSC_LIBRARIES}
      CMAKE_GENERATOR ${DEFAULT_GENERATOR}
      DEPENDS ${slepsc_dependencies}
    )
  endif()
  
  ExternalProject_Get_Property(slepsc INSTALL_DIR)

  # Populate the path
  set(SLEPSC_DIR ${INSTALL_DIR})
  list(APPEND CMAKE_PREFIX_PATH "${SLEPSC_DIR}")

  # Dependencies:
  # Add slepsc as dependecie to deal.II
  list(APPEND dealii_dependencies "slepsc")
endif()

# Add slepsc to deal.II
list(APPEND dealii_cmake_args "-D DEAL_II_WITH_SLEPSC:BOOL=ON")
list(APPEND dealii_cmake_args "-D SLEPSC_DIR=${SLEPSC_DIR}")
