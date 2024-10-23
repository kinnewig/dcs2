include(ExternalProject)

find_package(TK)
if(TK_FOUND)


else()
  message(STATUS "Building TK")
  
  # get the download url for tk:
  file(READ ${CMAKE_CURRENT_LIST_DIR}/libraries.json json)
  string(JSON tk_url GET ${json} tk git)
  string(JSON tk_tag GET ${json} tk ${TK_VERSION} tag)
  if (NOT tk_tag)
    message(FATAL_ERROR "Git tag for TK version ${TK_VERSION} not found in ${CMAKE_CURRENT_LIST_DIR}/libraries.json.")
  endif()
  
  # If a custom URL for tk is defined, use it.
  if (DEFINED TK_CUSTOM_URL)
    set(tk_url ${TK_CUSTOM_URL})
    message("Using custom download URL for TK: ${TK_CUSTOM_URL}")
  endif()
  
  # If a custom tag for tk is defined, use it.
  if (DEFINED TK_CUSTOM_TAG)
    set(tk_tag ${TK_CUSTOM_TAG})
    message("Using custom git tag for TK: ${TK_CUSTOM_TAG}")
  endif()

  if (DEFINED TK_SOURCE_DIR)
    ExternalProject_Add(tk
      URL ${TK_SOURCE_DIR}
      BUILD_COMMAND make
      INSTALL_COMMAND make install
      CONFIGURE_COMMAND ./unix/configure --prefix=${CMAKE_INSTALL_PREFIX}/tk/${TK_VERSION} ${tk_autotools_args}
      INSTALL_DIR ${CMAKE_INSTALL_PREFIX}/tk/${TK_VERSION}
      BUILD_IN_SOURCE ON
      BUILD_BYPRODUCTS ${TK_LIBRARIES}
      CONFIGURE_HANDLED_BY_BUILD true
      CMAKE_GENERATOR ${DEFAULT_GENERATOR}
      DEPENDS ${tk_dependencies}
    ) 
  else()
    ExternalProject_Add(tk
      GIT_REPOSITORY ${tk_url}
      GIT_TAG ${tk_tag}
      BUILD_COMMAND make
      INSTALL_COMMAND make install
      CONFIGURE_COMMAND ./unix/configure --prefix=${CMAKE_INSTALL_PREFIX}/tk/${TK_VERSION} ${tk_autotools_args}
      INSTALL_DIR ${CMAKE_INSTALL_PREFIX}/tk/${TK_VERSION}
      BUILD_IN_SOURCE ON
      BUILD_BYPRODUCTS ${TK_LIBRARIES}
      CONFIGURE_HANDLED_BY_BUILD true
      CMAKE_GENERATOR ${DEFAULT_GENERATOR}
      DEPENDS ${tk_dependencies}
    )
  endif()
  
  ExternalProject_Get_Property(tk INSTALL_DIR)
  
  # Populate the path
  set(TK_DIR ${INSTALL_DIR})
  list(APPEND CMAKE_PREFIX_PATH "${TK_DIR}")

  # Dependencies:
  # add TK as dependencie to OpenCascade
  list(APPEND occt_dependencies "tk")
endif()

# add TK to OpenCascade
list(APPEND occt_cmake_args "-D 3RDPARTY_TK_DIR=${TK_DIR}")
