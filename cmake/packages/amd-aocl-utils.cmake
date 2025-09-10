include(ExternalProject)

#find_package(AOCL-UTILS)
set(AOCL-UTILS_FOUND FALSE)
if(NOT AOCL-UTILS_FOUND)
  message(STATUS "Building AOCL-UTILS")
  
  build_cmake_subproject(amd-aocl-utils)

  # Dependencies:
  list(APPEND amd-libflame_dependencies "amd-aocl-utils")
  list(APPEND amd-mumps_dependencies "amd-aocl-utils")

  set(AOCL-UTILS_DIR ${AMD-AOCL-UTILS_DIR})
endif()

list(APPEND AOCL_ROOT "${AMD-AOCL-UTILS_DIR}")

# libflame
list(APPEND amd-libflame_cmake_args "-D LIBAOCLUTILS_INCLUDE_PATH=${AMD-AOCL-UTILS_DIR}/include")
list(APPEND amd-libflame_cmake_args "-D LIBAOCLUTILS_LIBRARY_PATH=${AMD-AOCL-UTILS_DIR}/lib")

# mumps
list(APPEND amd-mumps_cmake_args "-D CMAKE_AOCL_ROOT=${AOCL_ROOT}")
