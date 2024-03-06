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
)

# TODO
list(APPEND dealii_cmake_args "-D BOOST_DIR=/opt/ifam/12.2.0-V3/lib64/boost-1.81.0")

# deal.II with Trilinos
list(APPEND dealii_cmake_args "-D TRILINOS_DIR=${TRILINOS_DIR}") 

# deal.II with P4est
list(APPEND dealii_cmake_args "-D P4EST_DIR=${P4EST_DIR}") 

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
endif()

# If a custom tag for deal.II is defined, use it.
if (DEFINED DEALII_CUSTOM_TAG)
  set(dealii_tag ${DEALII_CUSTOM_TAG})
endif()

ExternalProject_Add(
    dealii
    GIT_REPOSITORY ${dealii_url}
    GIT_TAG ${dealii_tag}
    CMAKE_ARGS ${dealii_cmake_args}
    BUILD_BYPRODUCTS ${DEALII_LIBRARIES}
    CMAKE_GENERATOR ${DEFAULT_GENERATOR}
)
