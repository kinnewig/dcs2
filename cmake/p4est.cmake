include(ExternalProject)

find_package(P4EST)
if(P4EST_FOUND)
  message(STATUS "P4EST found: ${P4EST_DIR}")
  return()
endif()

# Scalapack
set(p4est_tag "v2.8.5")
set(p4est_url "https://github.com/cburstedde/p4est.git")

set(p4est_cmake_args,
  -D CMAKE_INSTALL_PREFIX:PATH=${INSTALL_PREFIX}/p4est/${P4EST_VERSION}
  -D CMAKE_C_COMPILER:PATH=${CMAKE_C_COMPILER}
  -D CMAKE_CXX_COMPILER:PATH=${CMAKE_CXX_COMPILER}
  -D CMAKE_Fortran_COMPILER:PATH=${CMAKE_Fortran_COMPILER}
  -D mpi=BOOL:ON 
  -D openmp=BOOL=ON
)
#-Dfind_lapack=off #<-- force LAPACK to be compiled

ExternalProject_Add(
    p4est
    GIT_REPOSITORY ${p4est_url}
    GIT_TAG ${p4est_tag}
    CMAKE_ARGS ${p4est_cmake_args}
    UPDATE_COMMAND ""
    BUILD_BYPRODUCTS ${P4EST_LIBRARIES}
    BUILD_COMMAND ${DEFAULT_BUILD_COMMAND}
)

set(P4EST_DIR "${p4est_DIR}")
