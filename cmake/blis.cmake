include(ExternalProject)

find_package(BLIS)
if(BLIS_FOUND)
  return()
else()
  message(STATUS "Building BLIS")
endif()

# Set BLIS architecture if not defined yet
if (NOT DEFINED BLIS_ARCHITECTURE)
  set(BLIS_ARCHITECTURE auto)
endif()

set(blis_autotool_args '--enable-cblas CFLAGS="-DAOCL_F2C -fPIC" CXXFLAGS="-DAOCL_F2C -fPIC" ${BLIS_ARCHITECTURE}')

# get the download url for blis:
file(READ ${CMAKE_CURRENT_LIST_DIR}/libraries.json json)
string(JSON blis_url GET ${json} blis git)
string(JSON blis_tag GET ${json} blis ${BLIS_VERSION} tag)
if (NOT blis_tag)
  message(FATAL_ERROR "Git tag for BLIS version ${BLIS_VERSION} not found in ${CMAKE_CURRENT_LIST_DIR}/libraries.json.")
endif()

# If a custom URL for blis is defined, use it.
if (DEFINED BLIS_CUSTOM_URL)
  set(blis_url ${BLIS_CUSTOM_URL})
endif()

# If a custom tag for blis is defined, use it.
if (DEFINED BLIS_CUSTOM_TAG)
  set(blis_tag ${BLIS_CUSTOM_TAG})
endif()

ExternalProject_Add(blis
  GIT_REPOSITORY ${blis_url}
  GIT_TAG ${blis_tag}
  GIT_SHALLOW true
  BUILD_COMMAND make
  INSTALL_COMMAND make install
  CONFIGURE_COMMAND ./configure --prefix=${CMAKE_INSTALL_PREFIX}/blis/${BLIS_VERSION} --enable-cblas CFLAGS="-DAOCL_F2C -fPIC" CXXFLAGS="-DAOCL_F2C -fPIC" ${BLIS_ARCHITECTURE}
  BUILD_IN_SOURCE ON
  BUILD_BYPRODUCTS ${BLIS_LIBRARIES}
  CMAKE_GENERATOR ${DEFAULT_GENERATOR}
)

add_library(BLIS::BLIS INTERFACE IMPORTED GLOBAL)
target_include_directories(BLIS::BLIS INTERFACE ${BLIS_INCLUDE_DIRS})
target_link_libraries(BLIS::BLIS INTERFACE ${BLIS_LIBRARIES})

add_dependencies(BLIS::BLIS blis)

# Populate the path
set(BLIS_DIR "${CMAKE_INSTALL_PREFIX}/blis/${BLIS_VERSION}")
set(BLIS_LIBRARIES "${CMAKE_INSTALL_PREFIX}/blis/${BLIS_VERSION}/lib64")
set(BLIS_INCLUDE_DIRS "${CMAKE_INSTALL_PREFIX}/blis/${BLIS_VERSION}/include")
