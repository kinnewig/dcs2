include(ExternalProject)

# get the download url for ninja:
file(READ ${CMAKE_CURRENT_LIST_DIR}/../cmake/libraries.json json)
string(JSON mold_url GET ${json} mold git)
string(JSON mold_tag GET ${json} mold ${MOLD_VERSION} tag)
if (NOT mold_tag)
  message(FATAL_ERROR "Git tag for MOLD version ${MOLD_VERSION} not found in ${CMAKE_CURRENT_LIST_DIR}/../cmake/libraries.json.")
endif()

# If a custom URL for mold is defined, use it.
if (DEFINED MOLD_CUSTOM_URL)
  set(mold_url ${MOLD_CUSTOM_URL})
endif()

# If a custom tag for mold is defined, use it.
if (DEFINED MOLD_CUSTOM_TAG)
  set(mold_tag ${MOLD_CUSTOM_TAG})
endif()


set(mold_cmake_args
  -D CMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}/mold/${MOLD_VERSION}
  -D CMAKE_C_COMPILER:PATH=${CMAKE_C_COMPILER}
  -D CMAKE_CXX_COMPILER:PATH=${CMAKE_CXX_COMPILER}
  -D CMAKE_Fortran_COMPILER:PATH=${CMAKE_Fortran_COMPILER}
)

ExternalProject_Add(mold
  GIT_REPOSITORY ${mold_url}
  GIT_TAG ${mold_tag}
  GIT_SHALLOW true
  CMAKE_ARGS ${mold_cmake_args}
  CONFIGURE_HANDLED_BY_BUILD true
)

ExternalProject_Add_Step(
  mold mold_symlink
  COMMAND ln -s ${CMAKE_INSTALL_PREFIX}/mold/${MOLD_VERSION}/bin/mold ${BIN_DIR}/mold
  COMMAND ln -s ${CMAKE_INSTALL_PREFIX}/mold/${MOLD_VERSION}/bin/ld.mold ${BIN_DIR}/ld.mold
  COMMAND ln -s ${CMAKE_INSTALL_PREFIX}/mold/${MOLD_VERSION}/lib/mold ${LIB_DIR}/mold
  WORKING_DIRECTORY ${CMAKE_INSTALL_PREFIX}/mold/${MOLD_VERSION}/bin
  DEPENDEES install
)
