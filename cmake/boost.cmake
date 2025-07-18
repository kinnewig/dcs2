include(ExternalProject)

# Provide the hints:
if(DEFINED BOOST_DIR)
  set(BOOST_ROOT ${BOOST_DIR})
endif()
# Try to find boost on the system
find_package(Boost)

if(Boost_FOUND)
  # Extract the BOOST root dir:
  get_filename_component(Boost_DIR "${Boost_INCLUDE_DIR}" DIRECTORY)
else()
  message(STATUS "Building BOOST")
  
  list(APPEND boost_autotool_args "--target=shared,static release")
  list(APPEND boost_autotool_args "-j ${THREADS}")

  set(boost_install_prefix ${CMAKE_INSTALL_PREFIX}/boost/${BOOST_VERSION})

  # get the download url for boost:
  file(READ ${CMAKE_CURRENT_LIST_DIR}/libraries.json json)
  string(JSON boost_url GET ${json} boost git)
  string(JSON boost_tag GET ${json} boost ${BOOST_VERSION} tag)
  if (NOT boost_tag)
    message(FATAL_ERROR "Git tag for BOOST version ${BOOST_VERSION} not found in ${CMAKE_CURRENT_LIST_DIR}/libraries.json.")
  endif()
  
  # If a custom URL for boost is defined, use it.
  if (DEFINED BOOST_CUSTOM_URL)
    set(boost_url ${BOOST_CUSTOM_URL})
    message("Using custom download URL for BOOST: ${BOOST_CUSTOM_URL}")
  endif()
  
  # If a custom tag for boost is defined, use it.
  if (DEFINED BOOST_CUSTOM_TAG)
    set(boost_tag ${BOOST_CUSTOM_TAG})
    message("Using custom git tag for BOOST: ${BOOST_CUSTOM_TAG}")
  endif()

  if (DEFINED BOOST_SOURCE_DIR)
    ExternalProject_Add(boost
      URL ${BOOST_SOURCE_DIR}
      BUILD_COMMAND ./b2 install ${boost_autotool_args}
      INSTALL_COMMAND ""
      CMAKE_ARGS ${boost_cmake_args}
      CONFIGURE_COMMAND echo 'using mpi ;' >> project-config.jam && echo 'using mpi ;' >> user-config.jam && ./bootstrap.sh --prefix=${boost_install_prefix} 
      INSTALL_DIR ${boost_install_prefix}
      BUILD_IN_SOURCE ON
      BUILD_BYPRODUCTS ${BOOST_LIBRARIES}
      CMAKE_GENERATOR ${DEFAULT_GENERATOR}
      DEPENDS ${boost_dependencies}
    )
  else()
    ExternalProject_Add(boost
      GIT_REPOSITORY ${boost_url}
      GIT_TAG ${boost_tag}
      GIT_SHALLOW true
      BUILD_COMMAND ./b2 install ${boost_autotool_args}
      INSTALL_COMMAND ""
      CMAKE_ARGS ${boost_cmake_args}
      CONFIGURE_COMMAND echo 'using mpi ;' >> project-config.jam && echo 'using mpi ;' >> user-config.jam && ./bootstrap.sh --prefix=${boost_install_prefix} 
      INSTALL_DIR ${boost_install_prefix}
      BUILD_IN_SOURCE ON
      BUILD_BYPRODUCTS ${BOOST_LIBRARIES}
      CMAKE_GENERATOR ${DEFAULT_GENERATOR}
      DEPENDS ${boost_dependencies}
    )
  endif()

  
  ExternalProject_Get_Property(boost INSTALL_DIR)
  
  # Populate the path
  set(Boost_DIR ${INSTALL_DIR})
  set(Boost_INCLUDE_DIR ${Boost_DIR}/include)
  list(APPEND CMAKE_PREFIX_PATH "${Boost_DIR}")
  
  # Dependencies:
  # add BOOST as dependencie to PETSc
  list(APPEND petsc_dependencies "boost")

  # add BOOST as dependencie to trilinos
  list(APPEND trilinos_dependencies "boost")

  # add BOOST as dependencie to dealii
  list(APPEND dealii_dependencies "boost")
endif()

# add BOOST to PETSc
list(APPEND petsc_autotool_args "--with-boost=true")
list(APPEND petsc_autotool_args "--with-boost-dir=${Boost_DIR}")

# add BOOST to trilinos
list(APPEND trilinos_cmake_args "-D TPL_ENABLE_BOOST=ON")
list(APPEND trilinos_cmake_args "-D Boost_LIBRARY_DIRS:PATH=${Boost_DIR}/lib;${Boost_DIR}/lib64")
list(APPEND trilinos_cmake_args "-D Boost_INCLUDE_DIRS:PATH=${Boost_INCLUDE_DIR}")

# add BOOST to deal.II
list(APPEND dealii_cmake_args "-D BOOST_DIR=${Boost_DIR}")
