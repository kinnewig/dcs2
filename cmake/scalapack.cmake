include(ExternalProject)

#find_package(SCALAPACK)
#if(SCALAPACK_FOUND)
#  return()
#else()
#  message(STATUS "Building SCALAPACK")

  set(scalapack_cmake_args
    -D BUILD_SINGLE:BOOL=ON
    -D BUILD_DOUBLE:BOOL=ON
    -D BUILD_COMPLEX:BOOL=${DEALII_WITH_COMPLEX}
    -D BUILD_COMPLEX16:BOOL=${DEALII_WITH_COMPLEX}
    -D BUILD_SHARED_LIBS:BOOL=ON
    -D BUILD_TESTING:BOOL=OFF
    -D CMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}/scalapack/${SCALAPACK_VERSION}
    -D CMAKE_C_COMPILER:PATH=${CMAKE_C_COMPILER}
    -D CMAKE_Fortran_COMPILER:PATH=${CMAKE_Fortran_COMPILER}
    -D CMAKE_BUILD_TYPE:STRING=Release
    -D CMAKE_TLS_VERIFY:BOOL=${CMAKE_TLS_VERIFY}
    ${scalapack_cmake_args}
  )

  if (AMD)
    list(APPEND scalapack_cmake_args -D CMAKE_C_FLAGS="-openmp")
    list(APPEND scalapack_cmake_args -D CMAKE_Fortran_FLAGS="-openmp")
    list(APPEND scalapack_cmake_args -D MPI_Fortran_WORKS:BOOL=ON)
  endif()

  # get the download url for scalapack:
  file(READ ${CMAKE_CURRENT_LIST_DIR}/libraries.json json)
  string(JSON scalapack_url GET ${json} scalapack git)
  string(JSON scalapack_tag GET ${json} scalapack ${SCALAPACK_VERSION} tag)
  if (NOT scalapack_tag)
    message(FATAL_ERROR "Git tag for SCALAPACK version ${SCALAPACK_VERSION} not found in ${CMAKE_CURRENT_LIST_DIR}/libraries.json.")
  endif()
  
  # If a custom URL for scalapack is defined, use it.
  if (DEFINED SCALAPACK_CUSTOM_URL)
    set(scalapack_url ${SCALAPCK_CUSTOM_URL})
    message("Using custom download URL for ScaLAPACK: ${SCALAPACK_CUSTOM_URL}")
  endif()
  
  # If a custom tag for scalapack is defined, use it.
  if (DEFINED SCALAPACK_CUSTOM_TAG)
    set(scalapack_tag ${SCALAPACK_CUSTOM_TAG})
    message("Using custom git tag for ScaLAPACK: ${SCALAPACK_CUSTOM_TAG}")
  endif()
  
  if(BUILD_SHARED_LIBS)
    set(SCALAPACK_LIBRARIES ${CMAKE_INSTALL_FULL_LIBDIR}/${CMAKE_SHARED_LIBRARY_PREFIX}scalapack${CMAKE_SHARED_LIBRARY_SUFFIX}
      ${CMAKE_INSTALL_FULL_LIBDIR}/${CMAKE_SHARED_LIBRARY_PREFIX}blacs${CMAKE_SHARED_LIBRARY_SUFFIX}
    )
  else()
    set(SCALAPACK_LIBRARIES ${CMAKE_INSTALL_FULL_LIBDIR}/${CMAKE_STATIC_LIBRARY_PREFIX}scalapack${CMAKE_STATIC_LIBRARY_SUFFIX}
      ${CMAKE_INSTALL_FULL_LIBDIR}/${CMAKE_STATIC_LIBRARY_PREFIX}blacs${CMAKE_STATIC_LIBRARY_SUFFIX}
    )
  endif()
  
  if (DEFINED SCALAPACK_SOURCE_DIR)
    ExternalProject_Add(scalapack
      URL ${SCALAPACK_SOURCE_DIR}
      CMAKE_ARGS ${scalapack_cmake_args}
      INSTALL_DIR ${CMAKE_INSTALL_PREFIX}/scalapack/${SCALAPACK_VERSION}
      BUILD_BYPRODUCTS ${SCALAPACK_LIBRARIES}
      CONFIGURE_HANDLED_BY_BUILD true
      CMAKE_GENERATOR ${DEFAULT_GENERATOR}
      DEPENDS ${scalapack_dependencies}
    )
  else()
    ExternalProject_Add(scalapack
      GIT_REPOSITORY ${scalapack_url}
      GIT_TAG ${scalapack_tag}
      GIT_SHALLOW true
      CMAKE_ARGS ${scalapack_cmake_args}
      INSTALL_DIR ${CMAKE_INSTALL_PREFIX}/scalapack/${SCALAPACK_VERSION}
      BUILD_BYPRODUCTS ${SCALAPACK_LIBRARIES}
      CONFIGURE_HANDLED_BY_BUILD true
      CMAKE_GENERATOR ${DEFAULT_GENERATOR}
      DEPENDS ${scalapack_dependencies}
    )
  endif()
  
  ExternalProject_Get_Property(scalapack INSTALL_DIR)
  
  # Populate the path
  set(SCALAPACK_DIR ${INSTALL_DIR})
  list(APPEND CMAKE_PREFIX_PATH "${SCALAPACK_DIR}")
  
  # Linking
  add_library(SCALAPACK::SCALAPACK INTERFACE IMPORTED GLOBAL)
  set_target_properties(SCALAPACK::SCALAPACK PROPERTIES
    IMPORTED_LOCATION ${SCALAPACK_DIR}/lib64/liblapack.so
    INTERFACE_INCLUDE_DIRECTORIES ${SCALAPACK_DIR}/include
  )
  
# Add scalapack to deal.II
list(APPEND dealii_dependencies "scalapack")
list(APPEND dealii_cmake_args "-D DEAL_II_WITH_SCALAPACK:BOOL=ON")
list(APPEND dealii_cmake_args "-D SCALAPACK_DIR=${SCALAPACK_DIR}")

# Add scalapack as dependecie to PETSc
list(APPEND petsc_dependencies "scalapack")
list(APPEND petsc_autotool_args "--with-scalapack-lib=${SCALAPACK_DIR}/lib64/libscalapack${CMAKE_SHARED_LIBRARY_SUFFIX}")

# Add scalapack to trilinos
list(APPEND trilinos_dependencies "scalapack")
list(APPEND trilinos_cmake_args "-D TPL_ENABLE_SCALAPACK:BOOL=ON")
list(APPEND trilinos_cmake_args "-D SCALAPACK_LIBRARY_NAMES='scalapack'")
list(APPEND trilinos_cmake_args "-D SCALAPACK_LIBRARY_DIRS:PATH=${SCALAPACK_DIR}/lib64")
list(APPEND trilinos_cmake_args "-D Amesos_ENABLE_SCALAPACK:BOOL=ON")

# Add scalapack to mumps
list(APPEND mumps_dependencies "scalapack")
list(APPEND mumps_cmake_args -D SCALAPACK_ROOT=${SCALAPACK_DIR})
