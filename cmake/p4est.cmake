include(ExternalProject)

find_package(P4EST)
if(P4EST_FOUND)

else()

  # First we need to install libsc
  set(libsc_cmake_args
    -D CMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}/p4est/${P4EST_VERSION} 
    -D BUILD_TESTING=OFF 
    -D BUILD_SHARED_LIBS=ON 
    -D CMAKE_C_COMPILER:PATH=${CMAKE_C_COMPILER} 
    -D mpi=ON 
    -D openmp=ON
    ${libsc_cmake_args}
  )
  
  # get the download url for p4est:
  file(READ ${CMAKE_CURRENT_LIST_DIR}/libraries.json json)
  string(JSON libsc_url GET ${json} libsc git)
  string(JSON libsc_tag GET ${json} libsc ${LIBSC_VERSION} tag)
  if (NOT libsc_tag)
    message(FATAL_ERROR "Git tag for LIBSC version ${LIBSC_VERSION} not found in ${CMAKE_CURRENT_LIST_DIR}/libraries.json.")
  endif()
  
  if (DEFINED LIBSC_SOURCE_DIR)
    ExternalProject_Add(
      libsc
      URL ${LIBSC_SOURCE_DIR}
      CMAKE_ARGS ${libsc_cmake_args}
      CMAKE_GENERATOR ${DEFAULT_GENERATOR}
      DEPENDS ${libsc_dependencies}
    )
  else()
    ExternalProject_Add(
      libsc
      GIT_REPOSITORY ${libsc_url}
      GIT_TAG ${libsc_tag}
      CMAKE_ARGS ${libsc_cmake_args}
      CMAKE_GENERATOR ${DEFAULT_GENERATOR}
      DEPENDS ${libsc_dependencies}
    )
  endif()

  list(APPEND p4est_dependencies "libsc")
  
  
  # P4EST itself
  set(p4est_cmake_args
    -D CMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}/p4est/${P4EST_VERSION}
    -D CMAKE_C_COMPILER:PATH=${CMAKE_C_COMPILER}
    -D CMAKE_CXX_COMPILER:PATH=${CMAKE_CXX_COMPILER}
    -D CMAKE_Fortran_COMPILER:PATH=${CMAKE_Fortran_COMPILER}
    -D mpi:BOOL=ON 
    -D openmp:BOOL=ON
    -D SC_DIR=${CMAKE_INSTALL_PREFIX}/p4est/${P4EST_VERSION}
    ${p4est_cmake_args}
   )
  
  # get the download url for p4est:
  file(READ ${CMAKE_CURRENT_LIST_DIR}/libraries.json json)
  string(JSON p4est_url GET ${json} p4est git)
  string(JSON p4est_tag GET ${json} p4est ${P4EST_VERSION} tag)
  if (NOT p4est_tag)
    message(FATAL_ERROR "Git tag for P4EST version ${P4EST_VERSION} not found in ${CMAKE_CURRENT_LIST_DIR}/libraries.json.")
  endif()
  
  # If a custom URL for p4est is defined, use it.
  if (DEFINED P4EST_CUSTOM_URL)
    set(p4est_url ${P4EST_CUSTOM_URL})
    message("Using custom download URL for P4EST: ${P4EST_CUSTOM_URL}")
  endif()
  
  # If a custom tag for p4est is defined, use it.
  if (DEFINED P4EST_CUSTOM_TAG)
    set(p4est_tag ${P4EST_CUSTOM_TAG})
    message("Using custom git tag for P4EST: ${P4EST_CUSTOM_TAG}")
  endif()
  
  if (DEFINED P4EST_SOURCE_DIR)
    ExternalProject_Add(p4est
      URL ${P4EST_SOURCE_DIR}
      CMAKE_ARGS ${p4est_cmake_args}
      INSTALL_DIR ${CMAKE_INSTALL_PREFIX}/p4est/${P4EST_VERSION} 
      CMAKE_GENERATOR ${DEFAULT_GENERATOR}
      DEPENDS ${p4est_dependencies}
    )
  else()
    ExternalProject_Add(p4est
      GIT_REPOSITORY ${p4est_url}
      GIT_TAG ${p4est_tag}
      CMAKE_ARGS ${p4est_cmake_args}
      INSTALL_DIR ${CMAKE_INSTALL_PREFIX}/p4est/${P4EST_VERSION} 
      CMAKE_GENERATOR ${DEFAULT_GENERATOR}
      DEPENDS ${p4est_dependencies}
    )
  endif()
  
  ExternalProject_Get_Property(p4est INSTALL_DIR)
  
  # Populate the path
  set(P4EST_DIR ${INSTALL_DIR})
  list(APPEND CMAKE_PREFIX_PATH "${P4EST_DIR}")
  
  # Linking
  # TODO: This is old method rework this to be more similar 
  #       to ScaLAPACK and MUMPS
  link_directories(${P4EST_DIR})

  # Dependencies:
  # Add P4est as dependencies to deal.II
  list(APPEND dealii_dependencies "p4est")
endif()

# Add P4est to deal.II
list(APPEND dealii_cmake_args "-D DEAL_II_WITH_P4EST=ON") 
list(APPEND dealii_cmake_args "-D P4EST_DIR=${P4EST_DIR}") 
