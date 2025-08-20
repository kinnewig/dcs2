include(ExternalProject)

find_package(ASSIMP)
if(NOT ASSIMP_FOUND)
  message(STATUS "Building ASSIMP")
  
  set(assimp_cmake_args
    -D CMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}/assimp/${ASSIMP_VERSION}
    -D CMAKE_C_COMPILER:PATH=${C_COMPILER}
    -D CMAKE_C_FLAGS=-Wno-all
    -D CMAKE_CXX_COMPILER:PATH=${CXX_COMPILER}
    -D CMAKE_CXX_FLAGS=-Wno-all
    -D CMAKE_BUILD_TYPE:STRING=Release
    -D BUILD_SHARED_LIBS:BOOL=ON
    -D ASSIMP_BUILD_TESTS:BOOL=OFF
    -D ASSIMP_WARNINGS_AS_ERRORS:BOOL=OFF
    ${assimp_cmake_args}
  )

  build_cmake_subproject("assimp")

  # Dependencies:
  list(APPEND dealii_dependencies "assimp")
endif()

# Force deal.II to use ASSIMP
list(APPEND dealii_cmake_args "-D ASSIMP_DIR:PATH=${ASSIMP_DIR}")
