include(ExternalProject)

find_package(MUMPS)
if(MUMPS_FOUND)
  message(STATUS "MUMPS found: ${MUMPS_DIR}")
  return()
endif()

# MUMPS
set(mumps_tag "master")
set(mumps_url "https://github.com/scivision/mumps.git")

set(mumps_cmake_args,
  -DBUILD_SINGLE:BOOL=ON
  -DBUILD_DOUBLE:BOOL=ON
  -DBUILD_COMPLEX:BOOL=${DEAL_WITH_COMPLEX}
  -DBUILD_COMPLEX16:BOOL=${DEAL_WITH_COMPLEX}
  -DBUILD_SHARED_LIBS:BOOL=ON
  -DCMAKE_INSTALL_PREFIX:PATH=${INSTALL_PREFIX}/mumps/${MUMPS_VERSION}
  -DCMAKE_C_COMPILER:PATH=${CMAKE_C_COMPILER}
  -DCMAKE_Fortran_COMPILER:PATH=${CMAKE_Fortran_COMPILER}
  -DBUILD_TESTING:BOOL=off
  -DCMAKE_BUILD_TYPE:STRING=Release
)
list(APPEND mumps_cmake_args, -D LAPACK_ROOT=${LAPACK_DIR})
list(APPEND mumps_cmake_args, -D SCALAPACK_ROOT=${SCALAPACK_DIR})

ExternalProject_Add(
    mumps
    GIT_REPOSITORY ${mumps_url}
    GIT_TAG ${mumps_tag}
    CMAKE_ARGS ${mumps_cmake_args}
    BUILD_BYPRODUCTS ${MUMPS_LIBRARIES}
    BUILD_COMMAND ${DEFAULT_BUILD_COMMAND}
)

set(MUMPS_DIR "${mumps_DIR}")
