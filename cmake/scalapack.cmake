include(ExternalProject)

# TODO: Remove, always use the lapack provided by the blas (libflame, reference LAPACK, OpenBLAS, MKL, etc...)
#find_package(LAPACK)
#if(LAPACK_FOUND)
#  set(BUILD_LAPACK OFF)
#else()
#  set(BUILD_LAPACK ON)
#endif()

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

  # TODO: Remove, always use the lapack provided by the blas (libflame, reference LAPACK, OpenBLAS, MKL, etc...)
  #if(BUILD_LAPACK)
  #  list(APPEND scalapack_cmake_args "-D find_lapack=off")
  #endif()
  
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
  
  
  # If we also build LAPACK, we can find BLAS and LAPACK in the SCALAPACK_DIR
  if(BUILD_LAPACK)
    # LAPACK:
    # Populate the path
    set(LAPACK_DIR ${INSTALL_DIR})
  
    # Linking
    #add_library(LAPACK::LAPACK INTERFACE IMPORTED GLOBAL)
    #set_target_properties(LAPACK::LAPACK PROPERTIES
    #  IMPORTED_LOCATION ${SCALAPACK_DIR}/lib64/liblapack.so
    #  INTERFACE_INCLUDE_DIRECTORIES ${SCALAPACK_DIR}/include
    #)
  
    # BLAS
    # Populate the path
    #set(BLAS_DIR ${INSTALL_DIR})
  
    # Linking
    #add_library(BLAS::BLAS INTERFACE IMPORTED GLOBAL)
    #set_target_properties(BLAS::BLAS PROPERTIES
    #  IMPORTED_LOCATION ${SCALAPACK_DIR}/lib64/libblas.so
    #  INTERFACE_INCLUDE_DIRECTORIES ${SCALAPACK_DIR}/include
    #)
  
    # BLACS
    # Populate the path
    set(BLACS_DIR ${INSTALL_DIR})
  
    # Linking
    add_library(BLACS::BLACS INTERFACE IMPORTED GLOBAL)
    set_target_properties(BLACS::BLACS PROPERTIES
      IMPORTED_LOCATION ${SCALAPACK_DIR}/lib64/libblacs.so
      INTERFACE_INCLUDE_DIRECTORIES ${SCALAPACK_DIR}/include
    )
  
  endif()
#endif()

# Add scalapack to deal.II
list(APPEND dealii_dependencies "scalapack")
list(APPEND dealii_cmake_args "-D DEAL_II_WITH_SCALAPACK:BOOL=ON")
list(APPEND dealii_cmake_args "-D SCALAPACK_DIR=${SCALAPACK_DIR}")

if(BUILD_LAPACK)
  # LAPACK
  list(APPEND dealii_cmake_args "-D DEAL_II_WITH_LAPACK:BOO=ON")
  list(APPEND dealii_cmake_args "-D LAPACK_LIBRARIES=${LAPACK_DIR}/lib64/liblapack.so")

  # BLAS
  #list(APPEND dealii_cmake_args "-D DEAL_II_WITH_BLAS:BOOL=ON")
  #list(APPEND dealii_cmake_args "-D BLAS_DIR=${BLAS_DIR}")
else()
  list(APPEND dealii_cmake_args "-D DEAL_II_WITH_LAPACK:BOO=ON")
endif()


# Add scalapack to trilinos
list(APPEND trilinos_dependencies "scalapack")
list(APPEND trilinos_cmake_args "-D TPL_ENABLE_SCALAPACK:BOOL=ON")
list(APPEND trilinos_cmake_args "-D SCALAPACK_LIBRARY_NAMES='scalapack'")
list(APPEND trilinos_cmake_args "-D SCALAPACK_LIBRARY_DIRS:PATH=${SCALAPACK_DIR}/lib64")
list(APPEND trilinos_cmake_args "-D Amesos_ENABLE_SCALAPACK:BOOL=ON")

if(BUILD_LAPACK)
  # LAPACK
  list(APPEND trilinos_cmake_args "-D TPL_ENABLE_LAPACK:BOOL=ON")
  list(APPEND trilinos_cmake_args "-D LAPACK_LIBRARY_DIRS:PATH=${LAPACK_DIR}/lib64")

  # BLAS
  #list(APPEND trilinos_cmake_args "-D TPL_ENABLE_BLAS:BOOL=ON")
  #list(APPEND trilinos_cmake_args "-D BLAS_LIBRARY_DIRS:PATH=${BLAS_DIR}/lib64")
endif()


# Add scalapack to mumps
list(APPEND mumps_dependencies "scalapack")
list(APPEND mumps_cmake_args -D SCALAPACK_ROOT=${SCALAPACK_DIR})

if(BUILD_LAPACK)
  list(APPEND mumps_cmake_args -D LAPACK_ROOT=${LAPACK_DIR})
endif()

# Add ScaLAPACK to SuiteSparse
if(BUILD_LAPACK)
  list(APPEND suitesparse_cmake_args "-D LAPACK_LIBRARIES=${LAPACK_DIR}/lib64/liblapack${CMAKE_SHARED_LIBRARY_SUFFIX}")
endif()

