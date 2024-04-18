include(ExternalProject)

find_package(MUMPS)
if(MUMPS_FOUND)

else()
  message(STATUS "Building MUMPS")
  
  set(mumps_cmake_args
    -D BUILD_SINGLE:BOOL=ON
    -D BUILD_DOUBLE:BOOL=ON
    -D BUILD_COMPLEX:BOOL=${DEALII_WITH_COMPLEX}
    -D BUILD_COMPLEX16:BOOL=${DEALII_WITH_COMPLEX}
    -D BUILD_SHARED_LIBS:BOOL=ON
    -D BUILD_TESTING:BOOL=OFF
    -D CMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}/mumps/${MUMPS_VERSION}
    -D CMAKE_C_COMPILER:PATH=${CMAKE_MPI_C_COMPILER}
    -D CMAKE_Fortran_COMPILER:PATH=${CMAKE_MPI_Fortran_COMPILER}
    -D CMAKE_BUILD_TYPE:STRING=Release
    ${mumps_cmake_args}
  )

  if (AMD)
    list(APPEND mumps_cmake_args -D CMAKE_CFLAGS="-openmp")
    list(APPEND mumps_cmake_args -D CMAKE_Fortran_FLAGS="-fopenmp")
    list(APPEND mumps_cmake_args -D MPI_Fortran_WORKS:BOOL=TRUE)
  endif()

  # get the download url for mumps:
  file(READ ${CMAKE_CURRENT_LIST_DIR}/libraries.json json)
  string(JSON mumps_url GET ${json} mumps git)
  string(JSON mumps_tag GET ${json} mumps ${MUMPS_VERSION} tag)
  if (NOT mumps_tag)
    message(FATAL_ERROR "Git tag for MUMPS version ${MUMPS_VERSION} not found in ${CMAKE_CURRENT_LIST_DIR}/libraries.json.")
  endif()
  
  # If a custom URL for mumps is defined, use it.
  if (DEFINED MUMPS_CUSTOM_URL)
    set(mumps_url ${MUMPS_CUSTOM_URL})
    message("Using custom download URL for MUMPS: ${MUMPS_CUSTOM_URL}")
  endif()
  
  # If a custom tag for mumps is defined, use it.
  if (DEFINED MUMPS_CUSTOM_TAG)
    set(mumps_tag ${MUMPS_CUSTOM_TAG})
    message("Using custom git tag for MUMPS: ${MUMPS_CUSTOM_TAG}")
  endif()
  
  ExternalProject_Add(mumps
    GIT_REPOSITORY ${mumps_url}
    GIT_TAG ${mumps_tag}
    GIT_SHALLOW true
    CMAKE_ARGS ${mumps_cmake_args}
    INSTALL_DIR ${CMAKE_INSTALL_PREFIX}/mumps/${MUMPS_VERSION}
    BUILD_BYPRODUCTS ${MUMPS_LIBRARIES}
    CONFIGURE_HANDLED_BY_BUILD true
    CMAKE_GENERATOR ${DEFAULT_GENERATOR}
    DEPENDS ${mumps_dependencies}
  )
  
  ExternalProject_Get_Property(mumps INSTALL_DIR)
  
  # Populate the path
  set(MUMPS_DIR ${INSTALL_DIR})
  list(APPEND CMAKE_PREFIX_PATH "${MUMPS_DIR}")
  
  # Linking
  add_library(MUMPS::MUMPS INTERFACE IMPORTED GLOBAL)
  set_target_properties(MUMPS::MUMPS PROPERTIES
    IMPORTED_LOCATION ${MUMPS_DIR}/lib64/libsmumps.so
    INTERFACE_INCLUDE_DIRECTORIES ${MUMPS_DIR}/include
  )

  # Dependencies:
  # add MUMPS as dependencie to trilinos
  list(APPEND trilinos_dependencies "mumps")
endif()

# add MUMPS to trilinos
list(APPEND trilinos_cmake_args "-D TPL_ENABLE_MUMPS=ON")
list(APPEND trilinos_cmake_args "-D MUMPS_LIBRARY_DIRS:PATH=${MUMPS_DIR}/lib")
list(APPEND trilinos_cmake_args "-D MUMPS_INCLUDE_DIRS:PATH=${MUMPS_DIR}/include")
list(APPEND trilinos_cmake_args "-D Amesos_ENABLE_MUMPS:BOOL=ON")
