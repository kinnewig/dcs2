include(ExternalProject)

find_package(TCL)
if(TCL_FOUND)


else()
  message(STATUS "Building TCL")
  
  # get the download url for tcl:
  file(READ ${CMAKE_CURRENT_LIST_DIR}/libraries.json json)
  string(JSON tcl_url GET ${json} tcl git)
  string(JSON tcl_tag GET ${json} tcl ${TCL_VERSION} tag)
  if (NOT tcl_tag)
    message(FATAL_ERROR "Git tag for TCL version ${TCL_VERSION} not found in ${CMAKE_CURRENT_LIST_DIR}/libraries.json.")
  endif()
  
  # If a custom URL for tcl is defined, use it.
  if (DEFINED TCL_CUSTOM_URL)
    set(tcl_url ${TCL_CUSTOM_URL})
    message("Using custom download URL for TCL: ${TCL_CUSTOM_URL}")
  endif()
  
  # If a custom tag for tcl is defined, use it.
  if (DEFINED TCL_CUSTOM_TAG)
    set(tcl_tag ${TCL_CUSTOM_TAG})
    message("Using custom git tag for TCL: ${TCL_CUSTOM_TAG}")
  endif()

  if (DEFINED TCL_SOURCE_DIR)
    ExternalProject_Add(tcl
      URL ${TCL_SOURCE_DIR}
      BUILD_COMMAND make
      INSTALL_COMMAND make install
      CONFIGURE_COMMAND ./unix/configure --prefix=${CMAKE_INSTALL_PREFIX}/tcl/${TCL_VERSION} ${tcl_autotools_args}
      INSTALL_DIR ${CMAKE_INSTALL_PREFIX}/tcl/${TCL_VERSION}
      BUILD_IN_SOURCE ON
      BUILD_BYPRODUCTS ${TCL_LIBRARIES}
      CONFIGURE_HANDLED_BY_BUILD true
      CMAKE_GENERATOR ${DEFAULT_GENERATOR}
      DEPENDS ${tcl_dependencies}
    ) 
  else()
    ExternalProject_Add(tcl
      GIT_REPOSITORY ${tcl_url}
      GIT_TAG ${tcl_tag}
      BUILD_COMMAND make
      INSTALL_COMMAND make install
      CONFIGURE_COMMAND ./unix/configure --prefix=${CMAKE_INSTALL_PREFIX}/tcl/${TCL_VERSION} ${tcl_autotools_args}
      INSTALL_DIR ${CMAKE_INSTALL_PREFIX}/tcl/${TCL_VERSION}
      BUILD_IN_SOURCE ON
      BUILD_BYPRODUCTS ${TCL_LIBRARIES}
      CONFIGURE_HANDLED_BY_BUILD true
      CMAKE_GENERATOR ${DEFAULT_GENERATOR}
      DEPENDS ${tcl_dependencies}
    )
  endif()
  
  ExternalProject_Get_Property(tcl INSTALL_DIR)
  
  # Populate the path
  set(TCL_DIR ${INSTALL_DIR})
  list(APPEND CMAKE_PREFIX_PATH "${TCL_DIR}")
  
  # Dependencies:
  # add TCL as dependencie to TK
  list(APPEND tk_dependencies "tcl")

  # add TCL as dependencie to OpenCascade
  list(APPEND occt_dependencies "tcl")
endif()

# add TCL to TK
list(APPEND tk_autotools_args "--with-tcl=${TCL_DIR}/lib")

# add TCL to OpenCascade
list(APPEND occt_cmake_args "-D 3RDPARTY_TCL_DIR=${TCL_DIR}")
