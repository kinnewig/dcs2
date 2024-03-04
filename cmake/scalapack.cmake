include(ExternalProject)

find_package(SCALAPACK)
if(SCALAPACK_FOUND)
  message(STATUS "ScaLAPACK found: ${SCALAPACK_DIR}")
  return()
endif()

# Scalapack
set(scalapack_tag "master")
set(scalapack_url "https://github.com/scivision/scalapack.git")

set(scalapack_cmake_args,
  -DBUILD_SINGLE:BOOL=ON
  -DBUILD_DOUBLE:BOOL=ON
  -DBUILD_COMPLEX:BOOL=${DEAL_WITH_COMPLEX}
  -DBUILD_COMPLEX16:BOOL=${DEAL_WITH_COMPLEX}
  -DBUILD_SHARED_LIBS:BOOL=ON
  -DCMAKE_INSTALL_PREFIX:PATH=${INSTALL_PREFIX}/scalapack/${SCALAPACK_VERSION}
  -DCMAKE_C_COMPILER:PATH=${CMAKE_C_COMPILER}
  -DCMAKE_Fortran_COMPILER:PATH=${CMAKE_Fortran_COMPILER}
  -DBUILD_TESTING:BOOL=off
  -DCMAKE_BUILD_TYPE:STRING=Release
)
#-Dfind_lapack=off #<-- force LAPACK to be compiled

ExternalProject_Add(
    scalapack
    GIT_REPOSITORY ${scalapack_url}
    GIT_TAG ${scalapack_tag}
    CMAKE_ARGS ${scalapack_cmake_args}
    UPDATE_COMMAND "git submodule update --init --recursive"
    BUILD_BYPRODUCTS ${SCALAPACK_LIBRARIES}
    BUILD_COMMAND ${DEFAULT_BUILD_COMMAND}
)

set(SCALAPACK_DIR "${scalapack_DIR}")
