include(ExternalProject)

find_package(P4EST)
if(P4EST_FOUND)
  message(STATUS "P4EST found: ${P4EST_DIR}")
  return()
endif()

set(p4est_cmake_args
  -D CMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}/p4est/${P4EST_VERSION}
  -D CMAKE_C_COMPILER:PATH=${CMAKE_C_COMPILER}
  -D CMAKE_CXX_COMPILER:PATH=${CMAKE_CXX_COMPILER}
  -D CMAKE_Fortran_COMPILER:PATH=${CMAKE_Fortran_COMPILER}
  -D mpi:BOOL=ON 
  -D openmp:BOOL=ON
)

# get the download url for p4est:
file(READ ${CMAKE_CURRENT_LIST_DIR}/libraries.json json)
string(JSON p4est_url GET ${json} p4est git)
string(JSON p4est_tag GET ${json} p4est ${P4EST_VERSION} tag)
if (NOT p4est_tag)
  message(FATAL_ERROR "Git tag for P4EST version ${P4EST_VERSION} not found in ${CMAKE_CURRENT_LIST_DIR}/libraries.json.")
endif()

# If a custom URL for p4est is defined, use it.
if (DEFINED P4EST_CUSTOM_URL)
  set(p4est_url ${P4EST_CUSTOM_URL})
endif()

# If a custom tag for p4est is defined, use it.
if (DEFINED P4EST_CUSTOM_TAG)
  set(p4est_tag ${P4EST_CUSTOM_TAG})
endif()

ExternalProject_Add(
    p4est
    GIT_REPOSITORY ${p4est_url}
    GIT_TAG ${p4est_tag}
    CMAKE_ARGS ${p4est_cmake_args}
    UPDATE_COMMAND git submodule update --init --recursive
    BUILD_BYPRODUCTS ${P4EST_LIBRARIES}
    CMAKE_GENERATOR ${DEFAULT_GENERATOR}
)

add_library(P4EST::P4EST INTERFACE IMPORTED GLOBAL)
target_include_directories(P4EST::P4EST INTERFACE ${P4EST_INCLUDE_DIRS})
target_link_libraries(P4EST::P4EST INTERFACE ${P4EST_LIBRARIES})

add_dependencies(P4EST::P4EST p4est)

# Populate the path
set(P4EST_DIR "${CMAKE_INSTALL_PREFIX}/p4est/${P4EST_VERSION}")
set(P4EST_LIBRARIES "${CMAKE_INSTALL_PREFIX}/p4est/${P4EST_VERSION}/lib64")
set(P4EST_INCLUDE_DIRS "${CMAKE_INSTALL_PREFIX}/p4est/${P4EST_VERSION}/include")
