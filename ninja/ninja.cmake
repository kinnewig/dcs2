include(ExternalProject)

# get the download url for ninja:
file(READ ${CMAKE_CURRENT_LIST_DIR}/libraries.json json)
string(JSON ninja_url GET ${json} ninja git)
string(JSON ninja_tag GET ${json} ninja ${NINJA_VERSION} tag)
if (NOT ninja_tag)
  message(FATAL_ERROR "Git tag for Ninja version ${NINJA_VERSION} not found in ${CMAKE_CURRENT_LIST_DIR}/libraries.json.")
endif()

# If a custom URL for ninja is defined, use it.
if (DEFINED NINJA_CUSTOM_URL)
  set(ninja_url ${NINJA_CUSTOM_URL})
endif()

# If a custom tag for ninja is defined, use it.
if (DEFINED NINJA_CUSTOM_TAG)
  set(blis_tag ${NINJA_CUSTOM_TAG})
endif()


set(ninja_cmake_args
  -D CMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}/ninja/${NINJA_VERSION}
  -D CMAKE_C_COMPILER:PATH=${CMAKE_C_COMPILER}
  -D CMAKE_CXX_COMPILER:PATH=${CMAKE_CXX_COMPILER}
  -D CMAKE_Fortran_COMPILER:PATH=${CMAKE_Fortran_COMPILER}
)

ExternalProject_Add(ninja
  GIT_REPOSITORY ${ninja_url}
  GIT_TAG ${ninja_version}
  GIT_SHALLOW true
  CMAKE_ARGS ${ninja_cmake_args}
  CONFIGURE_HANDLED_BY_BUILD true
  INSTALL_COMMAND ${CMAKE_COMMAND} -E create_symlink ${CMAKE_INSTALL_PREFIX}/ninja/${NINJA_VERSION}/ninja ${BIN_DIR}/ninja
)
