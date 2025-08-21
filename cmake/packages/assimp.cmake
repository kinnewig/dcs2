include(ExternalProject)

find_package(ASSIMP)
if(NOT ASSIMP_FOUND)
  message(STATUS "Building ASSIMP")
  
  set(assimp_cmake_args
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
