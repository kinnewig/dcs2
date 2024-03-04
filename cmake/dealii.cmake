include(ExternalProject)

# deal.II
set(dealii_tag "master")
set(dealii_url "https://github.com/dealii/dealii.git")

set(dealii_cmake_args,
  -D CMAKE_C_COMPILER=mpicc 
  -D CMAKE_CXX_COMPILER=mpicxx 
  -D CMAKE_Fortran_COMPILER=mpifort 
  -D CMAKE_INSTALL_PREFIX:PATH=${INSTALL_PREFIX}/dealii/${DEALII_VERSION}
  -D DEAL_II_WITH_TRILINOS:BOOL=ON 
  -D TRILINOS_DIR=${TRILINOS_DIR} 
  -D DEAL_II_WITH_MPI=ON 
  -D DEAL_II_WITH_64BIT_INDICES=ON 
  -D P4EST_DIR=${P4EST_DIR} 
  -D DEAL_II_COMPONENT_EXAMPLES=ON 
)

ExternalProject_Add(
    dealii
    GIT_REPOSITORY ${dealii_url}
    GIT_TAG ${dealii_tag}
    CMAKE_ARGS ${dealii_cmake_args}
    BUILD_BYPRODUCTS ${DEALII_LIBRARIES}
    BUILD_COMMAND ${DEFAULT_BUILD_COMMAND}
)
