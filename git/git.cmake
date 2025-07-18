include(ExternalProject)

# get the download url for git:
file(READ ${CMAKE_CURRENT_LIST_DIR}/../cmake/libraries.json json)
string(JSON git_url GET ${json} git url)
string(JSON git_tag GET ${json} git ${GIT_VERSION} tag)
if (NOT git_tag)
  message(FATAL_ERROR "Git tag for git version ${GIT_VERSION} not found in ${CMAKE_CURRENT_LIST_DIR}/../cmake/libraries.json.")
endif()

# If a custom URL for git is defined, use it.
if (DEFINED GIT_CUSTOM_URL)
  set(git_url ${GIT_CUSTOM_URL})
endif()

# If a custom tag for git is defined, use it.
if (DEFINED GIT_CUSTOM_TAG)
  set(git_tag ${GIT_CUSTOM_TAG})
endif()

ExternalProject_Add(git
  URL ${git_url}/${git_tag}.tar.gz
  PREFIX ${CMAKE_BINARY_DIR}
  CONFIGURE_COMMAND ""
  BUILD_COMMAND make NO_CURL=1 prefix=${CMAKE_INSTALL_PREFIX}/git/${GIT_VERSION}
  INSTALL_COMMAND make prefix=${CMAKE_INSTALL_PREFIX}/git/${GIT_VERSION} install
  BUILD_IN_SOURCE ON
  DOWNLOAD_EXTRACT_TIMESTAMP TRUE
)

ExternalProject_Add_Step(
  git git_symlink
  COMMAND ln -s ${CMAKE_INSTALL_PREFIX}/git/${GIT_VERSION}/bin/git ${BIN_DIR}/git
  WORKING_DIRECTORY ${CMAKE_INSTALL_PREFIX}/git/${GIT_VERSION}/bin
  DEPENDEES install
)
