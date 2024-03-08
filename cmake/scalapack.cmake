include(ExternalProject)

if(SCALAPACK_FOUND)
  return()
else()
  message(STATUS "Building SCALAPACK")
endif()

set(scalapack_cmake_args
  -D BUILD_SINGLE:BOOL=ON
  -D BUILD_DOUBLE:BOOL=ON
  -D BUILD_COMPLEX:BOOL=${TRILINIOS_WITH_COMPLEX}
  -D BUILD_COMPLEX16:BOOL=${TRILINOS_WITH_COMPLEX}
  -D BUILD_SHARED_LIBS:BOOL=ON
  -D BUILD_TESTING:BOOL=OFF
  -D CMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}/scalapack/${SCALAPACK_VERSION}
  -D CMAKE_C_COMPILER:PATH=${CMAKE_C_COMPILER}
  -D CMAKE_Fortran_COMPILER:PATH=${CMAKE_Fortran_COMPILER}
  -D CMAKE_BUILD_TYPE:STRING=Release
  -D CMAKE_TLS_VERIFY:BOOL=${CMAKE_TLS_VERIFY}
  -D BLAS_LIBRARIES:PATH=${BLIS_DIR}/lib/libblis${CMAKE_SHARED_LIBRARY_SUFFIX}
)
#list(APPEND scalapack_cmake_args "-D find_lapack=off")

if(DEFINED BLIS_DIR)
  # Configure ScaLAPACK to use BLIS
  list(APPEND SCALAPACK_DEPENDENCIES "BLIS")
  list(APPEND SCALAPACK_CONFOPTS "-D BLAS_LIBRARIES:PATH=${BLIS_DIR}/lib/libblis${CMAKE_SHARED_LIBRARY_SUFFIX}")
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
endif()

# If a custom tag for scalapack is defined, use it.
if (DEFINED SCALAPACK_CUSTOM_TAG)
  set(scalapack_tag ${SCALAPACK_CUSTOM_TAG})
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

ExternalProject_Add(scalapack
  GIT_REPOSITORY ${scalapack_url}
  GIT_TAG ${scalapack_tag}
  GIT_SHALLOW true
  CMAKE_ARGS ${scalapack_cmake_args}
  BUILD_BYPRODUCTS ${SCALAPACK_LIBRARIES}
  CONFIGURE_HANDLED_BY_BUILD true
  CMAKE_GENERATOR ${DEFAULT_GENERATOR}
)

add_library(SCALAPACK::SCALAPACK INTERFACE IMPORTED GLOBAL)
target_include_directories(SCALAPACK::SCALAPACK INTERFACE ${SCALAPACK_INCLUDE_DIRS})
target_link_libraries(SCALAPACK::SCALAPACK INTERFACE ${SCALAPACK_LIBRARIES})

add_dependencies(SCALAPACK::SCALAPACK scalapack)

# Populate the path
set(SCALAPACK_DIR "${CMAKE_INSTALL_PREFIX}/scalapack/${SCALAPACK_VERSION}")
set(SCALAPACK_LIBRARIES "${CMAKE_INSTALL_PREFIX}/scalapack/${SCALAPACK_VERSION}/lib64")
set(SCALAPACK_INCLUDE_DIRS "${CMAKE_INSTALL_PREFIX}/scalapack/${SCALAPACK_VERSION}/include")
