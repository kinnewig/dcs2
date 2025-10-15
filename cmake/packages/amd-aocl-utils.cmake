include(ExternalProject)

find_package(AMD-AOCL-UTILS)

if(NOT AMD-AOCL-UTILS_FOUND)
  message(STATUS "Building AOCL-UTILS")

  build_cmake_subproject(amd-aocl-utils)

  # Dependencies:
  list(APPEND amd-libflame_dependencies "amd-aocl-utils")
  list(APPEND amd-mumps_dependencies "amd-aocl-utils")
  list(APPEND mumps_dependencies "amd-aocl-utils")
endif()

add_library(AMD-AOCL-UTILS::AMD-AOCL-UTILS INTERFACE IMPORTED GLOBAL)

# amd-libflame
list(APPEND amd-libflame_cmake_args "-D LIBAOCLUTILS_INCLUDE_PATH=${AMD-AOCL-UTILS_DIR}/include")
list(APPEND amd-libflame_cmake_args "-D LIBAOCLUTILS_LIBRARY_PATH=${AMD-AOCL-UTILS_DIR}/lib")

# amd-mumps
list(APPEND amd-mumps_cmake_args "-D USER_PROVIDED_UTILS_LIBRARY_PATH=${AMD-AOCL-UTILS_DIR}")
list(APPEND amd-mumps_cmake_args "-D USER_PROVIDED_UTILS_INCLUDE_PATH=${AMD-AOCL-UTILS_DIR}")
