include(ExternalProject)

# deal.II

set(dealii_cmake_args
  -D CMAKE_C_COMPILER=${C_COMPILER}
  -D CMAKE_CXX_COMPILER=${CXX_COMPILER}
  -D CMAKE_Fortran_COMPILER=${MPI_Fortran_COMPILER}
  -D CMAKE_CXX_FLAGS="-fdiagnostics-color"
  -D CMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}/dealii/${DEALII_VERSION}
  -D DEAL_II_WITH_MPI=ON 
  -D DEAL_II_WITH_64BIT_INDICES=${DEALII_WITH_64BIT} 
  -D DEAL_II_COMPONENT_EXAMPLES=ON 
  -D CMAKE_POLICY_VERSION_MINIMUM=3.5
  ${dealii_cmake_args}
)

# get the download url for dealii:
file(READ ${CMAKE_CURRENT_LIST_DIR}/../libraries.json json)
string(JSON dealii_url GET ${json} dealii git)
string(JSON dealii_tag GET ${json} dealii ${DEALII_VERSION})
if (NOT dealii_tag)
  message(FATAL_ERROR "Git tag for DEALII version ${DEALII_VERSION} not found in ${CMAKE_CURRENT_LIST_DIR}/libraries.json.")
endif()

# If a custom URL for deal.II is defined, use it.
if (DEFINED DEALII_CUSTOM_URL)
  set(dealii_url ${DEALII_CUSTOM_URL})
  message("Using custom download URL for deal.II: ${DEALII_CUSTOM_URL}")
endif()

# If a custom tag for deal.II is defined, use it.
if (DEFINED DEALII_CUSTOM_TAG)
  set(dealii_tag ${DEALII_CUSTOM_TAG})
  message("Using custom git tag for deal.II: ${DEALII_CUSTOM_TAG}")
endif()

if (DEFINED DEALII_CUSTOM_NAME)
  set(dealii_name ${DEALII_CUSTOM_NAME})
else()
  set(dealii_name ${DEALII_VERSION})
endif()

if (DEFINED DEALII_SOURCE_DIR)
  ExternalProject_Add(
      dealii
      SOURCE_DIR ${DEALII_SOURCE_DIR}
      CMAKE_ARGS ${dealii_cmake_args}
      INSTALL_DIR ${CMAKE_INSTALL_PREFIX}/dealii/${dealii_name}
      BUILD_COMMAND cmake --build . --parallel ${THREADS}
      BUILD_BYPRODUCTS ${DEALII_LIBRARIES}
      CMAKE_GENERATOR ${DEFAULT_GENERATOR}
      DEPENDS ${dealii_dependencies}
  )
else()
  ExternalProject_Add(
      dealii
      GIT_REPOSITORY ${dealii_url}
      GIT_TAG ${dealii_tag}
      CMAKE_ARGS ${dealii_cmake_args}
      INSTALL_DIR ${CMAKE_INSTALL_PREFIX}/dealii/${dealii_name}
      BUILD_COMMAND cmake --build . --parallel ${THREADS}
      BUILD_BYPRODUCTS ${DEALII_LIBRARIES}
      CMAKE_GENERATOR ${DEFAULT_GENERATOR}
      DEPENDS ${dealii_dependencies}
  )
endif()

ExternalProject_Get_Property(dealii INSTALL_DIR)

# Populate the path
set(DEALII_DIR ${INSTALL_DIR})
list(APPEND CMAKE_PREFIX_PATH "${DEALII_DIR}")

# Linking
link_directories(${DEALII_DIR})
