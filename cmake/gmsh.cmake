include(ExternalProject)

find_package(GMSH)
if(NOT GMSH_FOUND)
  message(STATUS "Building GMSH")
  
  set(gmsh_cmake_args
    -D CMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}/gmsh/${GMSH_VERSION}
    -D CMAKE_C_COMPILER:PATH=${CMAKE_MPI_C_COMPILER}
    -D CMAKE_CXX_COMPILER:PATH=${CMAKE_MPI_CXX_COMPILER}
    -D CMAKE_Fortran_COMPILER:PATH=${CMAKE_MPI_Fortran_COMPILER}
    -D CMAKE_BUILD_TYPE:STRING=Release
    -D ENABLE_GRAPHICS:BOOL=ON 
    -D ENABLE_MPI:BOOL=ON 
    -D ENABLE_BUILD_LIB:BOOL=ON 
    -D ENABLE_BUILD_SHARED:BOOL=ON 
    -D ENABLE_BUILD_DYNAMIC:BOOL=ON 
    -D ENABLE_FLTK:BOOL=ON
    -D CMAKE_POLICY_VERSION_MINIMUM=3.5
    ${gmsh_cmake_args}
  )
  
  # get the download url for GMSH:
  file(READ ${CMAKE_CURRENT_LIST_DIR}/libraries.json json)
  string(JSON gmsh_url GET ${json} gmsh git)
  string(JSON gmsh_tag GET ${json} gmsh ${GMSH_VERSION} tag)
  if (NOT gmsh_tag)
    message(FATAL_ERROR "Git tag for GMSH version ${GMSH_VERSION} not found in ${CMAKE_CURRENT_LIST_DIR}/libraries.json.")
  endif()
  
  # If a custom URL for GMSH is defined, use it.
  if (DEFINED GMSH_CUSTOM_URL)
    set(GMSH_url ${GMSH_CUSTOM_URL})
    message("Using custom download URL for GMSH: ${GMSH_CUSTOM_URL}")
  endif()
  
  # If a custom tag for GMP is defined, use it.
  if (DEFINED GMSH_CUSTOM_TAG)
    set(GMSH_tag ${GMSH_CUSTOM_TAG})
    message("Using custom git tag for GMSH: ${GMSH_CUSTOM_TAG}")
  endif()
  
  if (DEFINED GMSH_SOURCE_DIR)
    ExternalProject_Add(gmsh
      URL ${GMSH_SOURCE_DIR}
      CMAKE_ARGS ${gmsh_cmake_args}
      INSTALL_DIR ${CMAKE_INSTALL_PREFIX}/gmsh/${GMSH_VERSION}
      BUILD_BYPRODUCTS ${GMSH_LIBRARIES}
      CONFIGURE_HANDLED_BY_BUILD true
      CMAKE_GENERATOR ${DEFAULT_GENERATOR}
      DEPENDS ${gmsh_dependencies}
    )
  else()
    ExternalProject_Add(gmsh
      GIT_REPOSITORY ${gmsh_url}
      GIT_TAG ${gmsh_tag}
      GIT_SHALLOW true
      CMAKE_ARGS ${gmsh_cmake_args}
      INSTALL_DIR ${CMAKE_INSTALL_PREFIX}/gmsh/${GMSH_VERSION}
      BUILD_BYPRODUCTS ${GMSH_LIBRARIES}
      CONFIGURE_HANDLED_BY_BUILD true
      CMAKE_GENERATOR ${DEFAULT_GENERATOR}
      DEPENDS ${gmsh_dependencies}
    )
  endif()

  ExternalProject_Get_Property(gmsh source_dir)

  # Work arround, this seems to be necessary...
  ExternalProject_Add_Step(gmsh workarround
    COMMAND sed -i "15i#define _XOPEN_SOURCE" string.c
    WORKING_DIRECTORY ${source_dir}/contrib/metis/GKlib/
    DEPENDEES download
    DEPENDERS configure
  )

  ExternalProject_Add_Step(
    gmsh gmsh_symlink
    COMMAND ln -s ${GMSH_DIR}/bin/gmsh ${BIN_DIR}/gmsh
    COMMAND ln -s ${GMSH_DIR}/lib64/libgmsh${CMAKE_SHARED_LIBRARY_SUFFIX} ${LIB64_DIR}/libgmsh${CMAKE_SHARED_LIBRARY_SUFFIX}
    WORKING_DIRECTORY ${GMSH_DIR}
    DEPENDEES install
  )
  
  ExternalProject_Get_Property(gmsh INSTALL_DIR)
  
  # Populate the path
  set(GMSH_DIR ${INSTALL_DIR})
  list(APPEND CMAKE_PREFIX_PATH "${GMSH_DIR}")
  
  set(GMP_LIBRARY "${GMSH_DIR}/lib64")
  set(GMP_INCLUDE_DIRS "${GMSH_DIR}/include")

  # Dependencies:
  # add GMSH as dependencie for deal.II
  list(APPEND dealii_dependencies "gmsh")

  # add GMSH as dependencie for PETSc
  list(APPEND petsc_dependencies "gmsh")

endif()

# add GMSH to deal.II
list(APPEND dealii_cmake_args "-D GMSH_DIR=${GMSH_DIR}")

# add GMSH to PETSc
list(APPEND petsc_autotool_args "--with-gmsh=true")
list(APPEND petsc_autotool_args "--with-gmsh-dir=${GMSH_DIR}")
