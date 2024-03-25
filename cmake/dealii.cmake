include(ExternalProject)

# deal.II

set(dealii_cmake_args
  -D CMAKE_C_COMPILER=${CMAKE_C_COMPILER}
  -D CMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
  -D CMAKE_Fortran_COMPILER=${CMAKE_Fortran_COMPILER}
  -D CMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}/dealii/${DEALII_VERSION}
  -D DEAL_II_WITH_TRILINOS:BOOL=ON 
  -D DEAL_II_WITH_MPI=ON 
  -D DEAL_II_WITH_64BIT_INDICES=ON 
  -D DEAL_II_COMPONENT_EXAMPLES=ON 
  ${dealii_cmake_args}
)

# deal.II with Boost
if(DEFINED BOOST_DIR)
  list(APPEND dealii_cmake_args "-D BOOST_DIR=${BOOST_DIR}")
endif()

# get the download url for dealii:
file(READ ${CMAKE_CURRENT_LIST_DIR}/libraries.json json)
string(JSON dealii_url GET ${json} dealii git)
string(JSON dealii_tag GET ${json} dealii ${DEALII_VERSION} tag)
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

message("TRILINOS_DIR (in deal.II): ${dealii_cmake_args}")

ExternalProject_Add(
    dealii
    GIT_REPOSITORY ${dealii_url}
    GIT_TAG ${dealii_tag}
    CMAKE_ARGS ${dealii_cmake_args}
    INSTALL_DIR ${CMAKE_INSTALL_PREFIX}/dealii/${DEALII_VERSION}
    BUILD_COMMAND cmake --build . --parallel ${THREADS}
    BUILD_BYPRODUCTS ${DEALII_LIBRARIES}
    CMAKE_GENERATOR ${DEFAULT_GENERATOR}
    DEPENDS ${dealii_dependencies}
)

ExternalProject_Get_Property(dealii INSTALL_DIR)

# Populate the path
set(DEALII_DIR ${INSTALL_DIR})
list(APPEND CMAKE_PREFIX_PATH "${DEALII_DIR}")

# Linking
link_directories(${DEALII_DIR})

message("DEALII: ${DEALII_INCLUDE_DIRS}")
message("DEALII: ${DEALII_LIBRARIES}")
message("DEALII: ${DEALII_DIR}")
