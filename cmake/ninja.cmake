include(ExternalProject)

# Check if Ninja is installed
find_program(NINJA ninja)

# get the download url for ninja:
file(READ ${CMAKE_CURRENT_LIST_DIR}/libraries.json json)
string(JSON ninja_url GET ${json} ninja git)
string(JSON ninja_tag GET ${json} ninja ${Ninja_VERSION} tag)
if (NOT scalapack_tag)
  message(FATAL_ERROR "Git tag for Ninja version ${Ninja_VERSION} not found in ${CMAKE_CURRENT_LIST_DIR}/libraries.json.")
endif()

if(NOT NINJA)
  set(ninja_cmake_args
    -D CMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}/ninja/${NINJA_VERSION}
    -D CMAKE_C_COMPILER:PATH=${CMAKE_C_COMPILER}
    -D CMAKE_CXX_COMPILER:PATH=${CMAKE_CXX_COMPILER}
    -D CMAKE_Fortran_COMPILER:PATH=${CMAKE_Fortran_COMPILER}
  )

  ExternalProject_Add(ninja
    GIT_REPOSITORY ${NINJA_URL}
    GIT_TAG ${NINJA_VERSION}
    GIT_SHALLOW true
    CMAKE_ARGS ${ninja_cmake_args}
    CONFIGURE_HANDLED_BY_BUILD true
    CMAKE_GENERATOR ${DEFAULT_GENERATOR}
    INSTALL_COMMAND ${CMAKE_COMMAND} -E create_symlink ${CMAKE_INSTALL_PREFIX}/ninja/${NINJA_VERSION}/ninja ${CMAKE_INSTALL_PREFIX}/bin/ninja
  )

  # Set the DEFAULT_GENERATOR to Ninja
  set(DEFAULT_GENERATOR "Ninja")
endif()
