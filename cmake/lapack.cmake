include(ExternalProject)

find_package(LAPACK)
if(LAPACK_FOUND)
  set(BUILD_LAPACK OFF)
else()
  set(BUILD_LAPACK ON)
endif()

if(BUILD_LAPACK)
  set(lapack_cmake_args
    -D BUILD_SHARED_LIBS:BOOL=ON
    -D BUILD_TESTING:BOOL=OFF
    -D CMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}/lapack/${LAPACK_VERSION}
    -D CMAKE_C_COMPILER:PATH=${CMAKE_C_COMPILER}
    -D CMAKE_Fortran_COMPILER:PATH=${CMAKE_Fortran_COMPILER}
    -D CMAKE_BUILD_TYPE:STRING=Release
    -D CMAKE_TLS_VERIFY:BOOL=${CMAKE_TLS_VERIFY}
    ${lapack_cmake_args}
  )

  if(DEALII_WITH_64BIT)
    list(APPEND lapack_cmake_args "-D CMAKE_Fortran_FLAGS='-fdefault-integer-8'")
    list(APPEND lapack_cmake_args "-D CMAKE_C_FLAGS='-fdefault-integer-8'")
    list(APPEND lapack_cmake_args "-D CMAKE_CXX_FLAGS='-fdefault-integer-8'" )
  endif()

  # get the download url for lapack:
  file(READ ${CMAKE_CURRENT_LIST_DIR}/libraries.json json)
  string(JSON lapack_url GET ${json} lapack git)
  string(JSON lapack_tag GET ${json} lapack ${LAPACK_VERSION} tag)
  if (NOT lapack_tag)
    message(FATAL_ERROR "Git tag for LAPACK version ${LAPACK_VERSION} not found in ${CMAKE_CURRENT_LIST_DIR}/libraries.json.")
  endif()
  
  # If a custom URL for lapack is defined, use it.
  if (DEFINED LAPACK_CUSTOM_URL)
    set(lapack_url ${LAPCK_CUSTOM_URL})
    message("Using custom download URL for LAPACK: ${LAPACK_CUSTOM_URL}")
  endif()
  
  # If a custom tag for lapack is defined, use it.
  if (DEFINED LAPACK_CUSTOM_TAG)
    set(lapack_tag ${LAPACK_CUSTOM_TAG})
    message("Using custom git tag for LAPACK: ${LAPACK_CUSTOM_TAG}")
  endif()
  
  if(BUILD_SHARED_LIBS)
    set(LAPACK_LIBRARIES ${CMAKE_INSTALL_FULL_LIBDIR}/${CMAKE_SHARED_LIBRARY_PREFIX}lapack${CMAKE_SHARED_LIBRARY_SUFFIX}
      ${CMAKE_INSTALL_FULL_LIBDIR}/${CMAKE_SHARED_LIBRARY_PREFIX}blacs${CMAKE_SHARED_LIBRARY_SUFFIX}
    )
  else()
    set(LAPACK_LIBRARIES ${CMAKE_INSTALL_FULL_LIBDIR}/${CMAKE_STATIC_LIBRARY_PREFIX}lapack${CMAKE_STATIC_LIBRARY_SUFFIX}
      ${CMAKE_INSTALL_FULL_LIBDIR}/${CMAKE_STATIC_LIBRARY_PREFIX}blacs${CMAKE_STATIC_LIBRARY_SUFFIX}
    )
  endif()
  
  if (DEFINED LAPACK_SOURCE_DIR)
    ExternalProject_Add(lapack
      URL ${LAPACK_SOURCE_DIR}
      CMAKE_ARGS ${lapack_cmake_args}
      INSTALL_DIR ${CMAKE_INSTALL_PREFIX}/lapack/${LAPACK_VERSION}
      BUILD_BYPRODUCTS ${LAPACK_LIBRARIES}
      CONFIGURE_HANDLED_BY_BUILD true
      CMAKE_GENERATOR ${DEFAULT_GENERATOR}
      DEPENDS ${lapack_dependencies}
    )
  else()
    ExternalProject_Add(lapack
      GIT_REPOSITORY ${lapack_url}
      GIT_TAG ${apack_tag}
      GIT_SHALLOW true
      CMAKE_ARGS ${lapack_cmake_args}
      INSTALL_DIR ${CMAKE_INSTALL_PREFIX}/lapack/${LAPACK_VERSION}
      BUILD_BYPRODUCTS ${LAPACK_LIBRARIES}
      CONFIGURE_HANDLED_BY_BUILD true
      CMAKE_GENERATOR ${DEFAULT_GENERATOR}
      DEPENDS ${lapack_dependencies}
    )
  endif()
  
  ExternalProject_Get_Property(lapack INSTALL_DIR)
  
  # Populate the path
  set(LAPACK_DIR ${INSTALL_DIR})
  list(APPEND CMAKE_PREFIX_PATH "${LAPACK_DIR}")
  
  # Linking
  add_library(LAPACK::LAPACK INTERFACE IMPORTED GLOBAL)
  set_target_properties(LAPACK::LAPACK PROPERTIES
    IMPORTED_LOCATION ${LAPACK_DIR}/lib64/liblapack.so
    INTERFACE_INCLUDE_DIRECTORIES ${LAPACK_DIR}/include
  )
  
  # BLAS
  # Populate the path
  #set(BLAS_DIR ${INSTALL_DIR})
  
  # Linking
  #add_library(BLAS::BLAS INTERFACE IMPORTED GLOBAL)
  #set_target_properties(BLAS::BLAS PROPERTIES
  #  IMPORTED_LOCATION ${LAPACK_DIR}/lib64/libblas.so
  #  INTERFACE_INCLUDE_DIRECTORIES ${LAPACK_DIR}/include
  #)
  
  # BLACS
  # Populate the path
  #set(BLACS_DIR ${INSTALL_DIR})
  
  # Linking
  #add_library(BLACS::BLACS INTERFACE IMPORTED GLOBAL)
  #set_target_properties(BLACS::BLACS PROPERTIES
  #  IMPORTED_LOCATION ${LAPACK_DIR}/lib64/libblacs.so
  #  INTERFACE_INCLUDE_DIRECTORIES ${LAPACK_DIR}/include
  #)

endif()

# Add LAPACK to deal.II
list(APPEND dealii_dependencies "lapack")
list(APPEND dealii_cmake_args "-D DEAL_II_WITH_LAPACK:BOOL=ON")
list(APPEND dealii_cmake_args "-D LAPACK_DIR=${LAPACK_DIR}")
list(APPEND dealii_cmake_args "-D LAPACK_LIBRARIES=${LAPACK_DIR}/lib/liblapack.so;${LAPACK_DIR}/lib64/liblapack.so")

  # BLAS
  #list(APPEND dealii_cmake_args "-D DEAL_II_WITH_BLAS:BOOL=ON")
  #list(APPEND dealii_cmake_args "-D BLAS_DIR=${BLAS_DIR}")


# Add LAPACK to trilinos
list(APPEND trilinos_dependencies "lapack")
list(APPEND trilinos_cmake_args "-D TPL_ENABLE_LAPACK:BOOL=ON")
list(APPEND trilinos_cmake_args "-D LAPACK_LIBRARY_DIRS:PATH=${LAPACK_DIR}/lib;${LAPACK_DIR}/lib64")

  # BLAS
  #list(APPEND trilinos_cmake_args "-D TPL_ENABLE_BLAS:BOOL=ON")
  #list(APPEND trilinos_cmake_args "-D BLAS_LIBRARY_DIRS:PATH=${BLAS_DIR}/lib64")

# Add LAPACK as dependecie to petsc
list(APPEND petsc_dependencies "lapack")
list(APPEND petsc_autotool_args " --with-lapack-dir=${LAPACK_DIR}")

# Add LAPACK to SuiteSparse
list(APPEND suitesparse_dependencies "lapack")
list(APPEND suitesparse_cmake_args "-D LAPACK_LIBRARIES=${LAPACK_DIR}/lib/liblapack${CMAKE_SHARED_LIBRARY_SUFFIX};${LAPACK_DIR}/lib64/liblapack${CMAKE_SHARED_LIBRARY_SUFFIX}")

# Add LAPACK to MUMPS
list(APPEND mumps_dependencies "lapack")
list(APPEND mumps_cmake_args -D LAPACK_ROOT=${LAPACK_DIR})

# Add LAPACK to ScaLAPACK
list(APPEND scalapack_dependencies "lapack")
list(APPEND scalapack_cmake_args -D LAPACK_ROOT=${LAPACK_DIR})


