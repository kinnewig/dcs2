include(ExternalProject)

find_package(MUPARSER)
if(NOT MUPARSER_FOUND)
  message(STATUS "Building MUPARSER")
  
  set(muparser_cmake_args
    -D ENABLE_SAMPLES=OFF
    -D CMAKE_BUILD_WITH_INSTALL_RPATH=TRUE
    ${muparser_cmake_args}
  )

  build_cmake_subproject("muparser")

  # Dependencies:
  list(APPEND dealii_dependencies "muparser")
endif()

# Force deal.II to use MUPARSER
list(APPEND dealii_cmake_args "-D MUPARSER_DIR:PATH=${MUPARSER_DIR}")
