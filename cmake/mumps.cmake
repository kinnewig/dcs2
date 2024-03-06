include(ExternalProject)

find_package(MUMPS)
if(MUMPS_FOUND)
  return()
else()
  message(STATUS "Building MUMPS")
endif()

set(mumps_cmake_args
  -D BUILD_SINGLE:BOOL=ON
  -D BUILD_DOUBLE:BOOL=ON
  -D BUILD_COMPLEX:BOOL=${TRILINOS_WITH_COMPLEX}
  -D BUILD_COMPLEX16:BOOL=${TRILNIOS_WITH_COMPLEX}
  -D BUILD_SHARED_LIBS:BOOL=ON
  -D BUILD_TESTING:BOOL=OFF
  -D CMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}/mumps/${MUMPS_VERSION}
  -D CMAKE_C_COMPILER:PATH=${CMAKE_C_COMPILER}
  -D CMAKE_Fortran_COMPILER:PATH=${CMAKE_Fortran_COMPILER}
  -D CMAKE_BUILD_TYPE:STRING=Release
  -D CMAKE_TLS_VERIFY:BOOL=${CMAKE_TLS_VERIFY}
)

list(APPEND mumps_cmake_args -D LAPACK_ROOT=${LAPACK_DIR})
list(APPEND mumps_cmake_args -D SCALAPACK_ROOT=${SCALAPACK_DIR})

# get the download url for mumps:
file(READ ${CMAKE_CURRENT_LIST_DIR}/libraries.json json)
string(JSON mumps_url GET ${json} mumps git)
string(JSON mumps_tag GET ${json} mumps ${MUMPS_VERSION} tag)
if (NOT mumps_tag)
  message(FATAL_ERROR "Git tag for MUMPS version ${MUMPS_VERSION} not found in ${CMAKE_CURRENT_LIST_DIR}/libraries.json.")
endif()

# If a custom URL for mumps is defined, use it.
if (DEFINED MUMPS_CUSTOM_URL)
  set(mumps_url ${MUMPS_CUSTOM_URL})
endif()

# If a custom tag for mumps is defined, use it.
if (DEFINED BLIS_CUSTOM_TAG)
  set(mumps_tag ${MUMPS_CUSTOM_TAG})
endif()

ExternalProject_Add(mumps
  GIT_REPOSITORY ${mumps_url}
  GIT_TAG ${mumps_tag}
  GIT_SHALLOW true
  CMAKE_ARGS ${mumps_cmake_args}
  BUILD_BYPRODUCTS ${MUMPS_LIBRARIES}
  CONFIGURE_HANDLED_BY_BUILD true
  CMAKE_GENERATOR ${DEFAULT_GENERATOR}
)

add_library(MUMPS::MUMPS INTERFACE IMPORTED GLOBAL)
target_include_directories(MUMPS::MUMPS INTERFACE ${MUMPS_INCLUDE_DIRS})
target_link_libraries(MUMPS::MUMPS INTERFACE ${MUMPS_LIBRARIES})

add_dependencies(MUMPS::MUMPS mumps)

# Populate the path
set(MUMPS_DIR "${CMAKE_INSTALL_PREFIX}/mumps/${MUMPS_VERSION}")
set(MUMPS_LIBRARIES "${CMAKE_INSTALL_PREFIX}/mumps/${MUMPS_VERSION}/lib64")
set(MUMPS_INCLUDE_DIRS "${CMAKE_INSTALL_PREFIX}/mumps/${MUMPS_VERSION}/include")
