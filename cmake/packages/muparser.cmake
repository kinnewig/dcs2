include(ExternalProject)

find_package(MUPARSER)
if(NOT MUPARSER_FOUND)
  message(STATUS "Building MUPARSER")
  
  set(muparser_cmake_args
    -D CMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}/muparser/${MUPARSER_VERSION}
    -D CMAKE_C_COMPILER:PATH=${MPI_C_COMPILER}
    -D CMAKE_C_COMPILER:PATH=${MPI_CXX_COMPILER}
    -D CMAKE_Fortran_COMPILER:PATH=${MPI_Fortran_COMPILER}
    -D CMAKE_BUILD_TYPE:STRING=Release
    -D ENABLE_SAMPLES=OFF
    ${muparser_cmake_args}
  )

  build_cmake_subproject("muparser")

  # Dependencies:
  list(APPEND dealii_dependencies "muparser")
endif()

# Force deal.II to use MUPARSER
list(APPEND dealii_cmake_args "-D MUPARSER_DIR:PATH=${MUPARSER_DIR}")
