include(ExternalProject)

find_package(GMP "6.1.2")
if(GMP_FOUND)

  # Add GMP to SuiteSparse (how to link GMP depends on wether we build GMP ourself or if we use the system package)
  list(APPEND suitesparse_cmake_args "-D GMP_INCLUDE_DIR=${GMP_INCLUDE_DIR}")
  list(APPEND suitesparse_cmake_args "-D GMP_LIBRARIES=${GMP_DIR}/lib")

else()
  message(STATUS "Building GMP")
  
  list(APPEND gmp_autotool_args "--prefix=${CMAKE_INSTALL_PREFIX}/gmp/${GMP_VERSION}")
  
  # get the download url for GMP:
  file(READ ${CMAKE_CURRENT_LIST_DIR}/libraries.json json)
  string(JSON gmp_url GET ${json} gmp git)
  string(JSON gmp_tag GET ${json} gmp ${GMP_VERSION} tag)
  if (NOT gmp_tag)
    message(FATAL_ERROR "Git tag for GMP version ${GMP_VERSION} not found in ${CMAKE_CURRENT_LIST_DIR}/libraries.json.")
  endif()
  
  # If a custom URL for GMP is defined, use it.
  if (DEFINED GMP_CUSTOM_URL)
    set(GMP_url ${GMP_CUSTOM_URL})
    message("Using custom download URL for GMP: ${GMP_CUSTOM_URL}")
  endif()
  
  # If a custom tag for GMP is defined, use it.
  if (DEFINED GMP_CUSTOM_TAG)
    set(GMP_tag ${GMP_CUSTOM_TAG})
    message("Using custom git tag for GMP: ${GMP_CUSTOM_TAG}")
  endif()
  
  if (DEFINED GMP_SOURCE_DIR)
    ExternalProject_Add(gmp
      URL ${GMP_SOURCE_DIR}
      BUILD_COMMAND make
      INSTALL_COMMAND make install
      CMAKE_ARGS ${gmp_cmake_args}
      CONFIGURE_COMMAND ./configure ${gmp_autotool_args}
      INSTALL_DIR ${CMAKE_INSTALL_PREFIX}/gmp/${GMP_VERSION}
      BUILD_IN_SOURCE ON
      BUILD_BYPRODUCTS ${GMP_LIBRARIES}
      CMAKE_GENERATOR ${DEFAULT_GENERATOR}
      DEPENDS ${gmp_dependencies}
    )
  else()
    ExternalProject_Add(gmp
      GIT_REPOSITORY ${gmp_url}
      GIT_TAG ${gmp_tag}
      GIT_SHALLOW true
      BUILD_COMMAND make
      INSTALL_COMMAND make install
      CMAKE_ARGS ${gmp_cmake_args}
      CONFIGURE_COMMAND ./configure ${gmp_autotool_args}
      INSTALL_DIR ${CMAKE_INSTALL_PREFIX}/gmp/${GMP_VERSION}
      BUILD_IN_SOURCE ON
      BUILD_BYPRODUCTS ${GMP_LIBRARIES}
      CMAKE_GENERATOR ${DEFAULT_GENERATOR}
      DEPENDS ${gmp_dependencies}
    )
  endif()
  
  ExternalProject_Get_Property(gmp INSTALL_DIR)
  
  # Populate the path
  set(GMP_DIR ${INSTALL_DIR})
  list(APPEND CMAKE_PREFIX_PATH "${GMP_DIR}")
  
  # Linking
  add_library(GMP::GMP INTERFACE IMPORTED GLOBAL)
  set_target_properties(GMP::GMP PROPERTIES
    IMPORTED_LOCATION ${GMP_DIR}/lib/libgmp${CMAKE_SHARED_LIBRARY_SUFFIX}
    INTERFACE_INCLUDE_DIRECTORIES ${GMP_DIR}/include
  )
  
  set(GMP_INCLUDE_DIR "${GMP_DIR}/include")
  set(GMP_LIBRARY "${GMP_DIR}/lib")

  # Dependencies:
  # add GMP as dependencie to MPFR
  list(APPEND mpfr_dependencies "gmp")

  # add GMP as dependencie to PETSc
  list(APPEND petsc_dependencies "gmp")

  # add GMP as dependencie to SuiteSparse
  list(APPEND suitesparse_dependencies "gmp")

  # add GMP as dependencie to LibFLAME
  list(APPEND libflame_dependencies "gmp")

  # Add GMP to SuiteSparse (how to link GMP depends on wether we build GMP ourself or if we use the system package)
  list(APPEND suitesparse_cmake_args "-D GMP_INCLUDE_DIR:PATH=${GMP_INCLUDE_DIR}")
  list(APPEND suitesparse_cmake_args "-D GMP_LIBRARY:PATH=${GMP_LIBRARY}/libgmp${CMAKE_SHARED_LIBRARY_SUFFIX}")
  list(APPEND suitesparse_cmake_args "-D GMP_STATIC:PATH=${GMP_LIBRARY}/libgmp.a")

endif()

# add GMP to MPFR
list(APPEND mpfr_autotool_args "--with-gmp=${GMP_DIR}")

# add GMP to PETSc
list(APPEND petsc_autotool_args "--with-gmp=true")
list(APPEND petsc_autotool_args "--with-gmp-dir=${GMP_DIR}")

# add GMP to LibFLAME
list(APPEND libflame_autotools_args "--with-gmp=${GMP_DIR}/lib")
