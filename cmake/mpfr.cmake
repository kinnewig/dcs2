include(ExternalProject)

find_package(MPFR "4.0.2")
if(MPFR_FOUND)

  # add MPFR to SuiteSparse
  list(APPEND suitesparse_cmake_args "-D MPFR_INCLUDE_DIR:PATH=${MPFR_INCLUDE_DIR}")
  list(APPEND suitesparse_cmake_args "-D MPFR_LIBRARY:PATH=${MPFR_LIBRARY}")

  # add MPFR to PETSc
  list(APPEND petsc_autotool_args "--with-mpfr=true")
  list(APPEND petsc_autotool_args "--with-mpfr-dir=${MPFR_DIR}")

else()
  message(STATUS "Building MPFR")
  
  list(APPEND mpfr_autotool_args "--prefix=${CMAKE_INSTALL_PREFIX}/mpfr/${MPFR_VERSION}")
  
  # get the download url for MPFR:
  file(READ ${CMAKE_CURRENT_LIST_DIR}/libraries.json json)
  string(JSON mpfr_url GET ${json} mpfr git)
  string(JSON mpfr_tag GET ${json} mpfr ${MPFR_VERSION} tag)
  if (NOT mpfr_tag)
    message(FATAL_ERROR "Git tag for MPFR version ${MPFR_VERSION} not found in ${CMAKE_CURRENT_LIST_DIR}/libraries.json.")
  endif()
  
  # If a custom URL for MPFR is defined, use it.
  if (DEFINED MPFR_CUSTOM_URL)
    set(MPFR_url ${MPFR_CUSTOM_URL})
    message("Using custom download URL for MPFR: ${MPFR_CUSTOM_URL}")
  endif()
  
  # If a custom tag for MPFR is defined, use it.
  if (DEFINED MPFR_CUSTOM_TAG)
    set(mpfr_tag ${MPFR_CUSTOM_TAG})
    message("Using custom git tag for MPFR: ${MPFR_CUSTOM_TAG}")
  endif()
  
  if (DEFINED MPFR_SOURCE_DIR)
    ExternalProject_Add(mpfr
      URL ${MPFR_SOURCE_DIR}
      BUILD_COMMAND make
      INSTALL_COMMAND make install
      CMAKE_ARGS ${mpfr_cmake_args}
      CONFIGURE_COMMAND ./autogen.sh && ./configure ${mpfr_autotool_args}
      INSTALL_DIR ${CMAKE_INSTALL_PREFIX}/mpfr/${MPFR_VERSION}
      BUILD_IN_SOURCE ON
      BUILD_BYPRODUCTS ${MPFR_LIBRARIES}
      CMAKE_GENERATOR ${DEFAULT_GENERATOR}
      DEPENDS ${mpfr_dependencies}
    )
  else()
    ExternalProject_Add(mpfr
      GIT_REPOSITORY ${mpfr_url}
      GIT_TAG ${mpfr_tag}
      GIT_SHALLOW true
      BUILD_COMMAND make
      INSTALL_COMMAND make install
      CMAKE_ARGS ${mpfr_cmake_args}
      CONFIGURE_COMMAND ./autogen.sh && ./configure ${mpfr_autotool_args}
      INSTALL_DIR ${CMAKE_INSTALL_PREFIX}/mpfr/${MPFR_VERSION}
      BUILD_IN_SOURCE ON
      BUILD_BYPRODUCTS ${MPFR_LIBRARIES}
      CMAKE_GENERATOR ${DEFAULT_GENERATOR}
      DEPENDS ${mpfr_dependencies}
    )
  endif()
  
  ExternalProject_Get_Property(mpfr INSTALL_DIR)
  
  # Populate the path
  set(MPFR_DIR ${INSTALL_DIR})
  list(APPEND CMAKE_PREFIX_PATH "${MPFR_DIR}")
  
  # Linking
  add_library(MPFR::MPFR INTERFACE IMPORTED GLOBAL)
  set_target_properties(MPFR::MPFR PROPERTIES
    IMPORTED_LOCATION ${MPFR_DIR}/lib/libmpfr${CMAKE_SHARED_LIBRARY_SUFFIX}
    INTERFACE_INCLUDE_DIRECTORIES ${MPFR_DIR}/include
  )

  set(MPFR_LIBRARY "${MPFR_DIR}/lib")
  set(MPFR_INCLUDE_DIR "${MPFR_DIR}/include")

  # Dependencies:
  # add MPFR as dependencie to SuiteSparse
  list(APPEND suitesparse_dependencies "mpfr")

  # add MPFR as dependencie to PETSc
  list(APPEND petsc_dependencies "mpfr")

  # add MPFR to PETSc
  list(APPEND petsc_autotool_args "--with-mpfr=true")
  list(APPEND petsc_autotool_args "--with-mpfr-dir=${MPFR_DIR}")

  # add MPFR to SuiteSparse
  list(APPEND suitesparse_cmake_args "-D MPFR_INCLUDE_DIR:PATH=${MPFR_INCLUDE_DIR}")
  list(APPEND suitesparse_cmake_args "-D MPFR_LIBRARY:PATH=${MPFR_LIBRARY}/libmpfr${CMAKE_SHARED_LIBRARY_SUFFIX}")
  list(APPEND suitesparse_cmake_args "-D MPFR_STATIC:PATH=${MPFR_LIBRARY}/libmpfr.a")
endif()


