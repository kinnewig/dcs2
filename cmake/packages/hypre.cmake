include(ExternalProject)

find_package(HYPRE)
if(NOT HYPRE_FOUND)
  message(STATUS "Building HYPRE")
  
  set(hypre_cmake_args
    -D CMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}/hypre/${HYPRE_VERSION}
    -D CMAKE_C_COMPILER:PATH=${CMAKE_MPI_C_COMPILER}
    -D CMAKE_CXX_COMPILER:PATH=${CMAKE_MPI_CXX_COMPILER}
    -D CMAKE_Fortran_COMPILER:PATH=${CMAKE_MPI_Fortran_COMPILER}
    -D CMAKE_C_FLAGS="-fPIC"
    -D CMAKE_CXX_FLAGS="-fPIC"
    -D CMAKE_BUILD_TYPE:STRING=Release
    -D BUILD_SHARED_LIBS:BOOL=ON
    ${hypre_cmake_args}
  )

  if(${DEALII_WITH_64BIT})
    list(APPEND hypre_cmake_args "-D HYPRE_ENABLE_BIGINT:BOOL=ON")
  endif()

  # unfortunally hypre's build-chain is... ..non standard...
  ############################################
  # get the download url for hypre:
  file(READ ${CMAKE_CURRENT_LIST_DIR}/../libraries.json json)
  string(JSON hypre_url GET ${json} hypre git)
  string(JSON hypre_tag GET ${json} hypre ${HYPRE_VERSION})

  if (NOT hypre_tag)
    message(FATAL_ERROR "Git tag for HYPRE version ${HYPRE_VERSION} not found in ${CMAKE_CURRENT_LIST_DIR}/libraries.json.")
  endif()
  
  # If a custom URL is defined, use it.
  if (DEFINED HYPRE_CUSTOM_URL)
    set(hypre_url ${HYPRE_CUSTOM_URL})
    message("Using custom download URL for HYPRE: ${HYPRE_CUSTOM_URL}")
  endif()
  
  # If a custom tag is defined, use it.
  if (DEFINED HYPRE_CUSTOM_TAG)
    set(hypre_tag ${HYPRE_CUSTOM_TAG})
    message("Using custom git tag for HYPRE: ${HYPRE_CUSTOM_TAG}")
  endif()

  if (DEFINED HYPRE_SOURCE_DIR)
    ExternalProject_Add(hypre
      URL ${HYPRE_SOURCE_DIR}
      GIT_SHALLOW true
      INSTALL_DIR ${CMAKE_INSTALL_PREFIX}/hypre/${HYPRE_VERSION}
      BUILD_BYPRODUCTS ${HYPRE_LIBRARIES}
      CONFIGURE_COMMAND ${CMAKE_COMMAND} ${hypre_cmake_args} src
      BUILD_COMMAND cmake --build . --parallel ${THREADS}
      CMAKE_GENERATOR ${DEFAULT_GENERATOR}
      DEPENDS ${hypre_dependencies}
    ) 
  else()
    ExternalProject_Add(hypre
      GIT_REPOSITORY ${hypre_url}
      GIT_TAG ${hypre_tag}
      GIT_SHALLOW true
      INSTALL_DIR ${CMAKE_INSTALL_PREFIX}/hypre/${HYPRE_VERSION}
      BUILD_BYPRODUCTS ${HYPRE_LIBRARIES}
      CONFIGURE_COMMAND ${CMAKE_COMMAND} ${hypre_cmake_args} ../hypre/src
      BUILD_COMMAND cmake --build . --parallel ${THREADS}
      CMAKE_GENERATOR ${DEFAULT_GENERATOR}
      DEPENDS ${hypre_dependencies}
    )
  endif()
  
  ExternalProject_Get_Property(hypre INSTALL_DIR)

  # Populate the path
  set(HYPRE_DIR ${INSTALL_DIR} CACHE INTERNAL "")

  set(cmake_prefix_path_local "${CMAKE_PREFIX_PATH}")
  list(APPEND cmake_prefix_path_local "${HYPRE_DIR}")
  set(CMAKE_PREFIX_PATH ${cmake_prefix_path_local} CACHE INTERNAL "")

  # Check if lib exists, if it does not, create a symlink
  ExternalProject_Add_Step(
    hypre hypre_symlink
    COMMAND bash -c "[ -d \"${HYPRE_DIR}/lib\" ] || ( [ -d \"${HYPRE_DIR}/lib64\" ] && ln -s \"${HYPRE_DIR}/lib64\" \"${HYPRE_DIR}/lib\" )"
    WORKING_DIRECTORY ${HYPRE_DIR}
    DEPENDEES install
  )

  # Check if lib64 exists, if it does not, create a symlink
  ExternalProject_Add_Step(
    hypre hypre_symlink64
    COMMAND bash -c "[ -d \"${HYPRE_DIR}/lib64\" ] || ( [ -d \"${HYPRE_DIR}/lib\" ] && ln -s \"${HYPRE_DIR}/lib\" \"${HYPRE_DIR}/lib64\" )"
    WORKING_DIRECTORY ${HYPRE_DIR}
    DEPENDEES install
  )

  ############################################


  set(HYPRE_LIBRARY "${HYPRE_DIR}/lib")
  set(HYPRE_INCLUDE_DIR "${HYPRE_DIR}/include")

  # Dependencies:
  list(APPEND petsc_dependencies "hypre")
  list(APPEND trilinos_dependencies "hypre")
endif()

# add HYPRE to PETSc
list(APPEND petsc_autotool_args "--with-hypre=true")
list(APPEND petsc_autotool_args "--with-hypre-dir=${HYPRE_DIR}")

# add HYPRE to Trilinos
# TODO: HYPRE with 64-bit does not work with Epetra... 
# As Epetra will be removed in the next release of Trilinos no patch can be expected.
# Once Epetra is removed, this can be reenabled, but for the moment, deal.II requires Epetra
#list(APPEND trilinos_cmake_args "-D TPL_ENABLE_HYPRE=ON")
#list(APPEND trilinos_cmake_args "-D HYPRE_LIBRARY_DIRS:PATH=${HYPRE_DIR}/lib")
#list(APPEND trilinos_cmake_args "-D HYPRE_INCLUDE_DIRS:PATH=${HYPRE_DIR}/include")
