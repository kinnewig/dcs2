include(ExternalProject)

#find_package(AOCL-UTILS)
set(AOCL-UTILS_FOUND FALSE)
if(NOT AOCL-UTILS_FOUND)
  message(STATUS "Building AOCL-UTILS")
  
  build_cmake_subproject(amd-aocl-utils)

  # Dependencies:
  list(APPEND amd-libflame_dependencies "amd-aocl-utils")
  list(APPEND amd-mumps_dependencies "amd-aocl-utils")
  list(APPEND mumps_dependencies "amd-aocl-utils")

# Populate the AOCL_ROOT
  ExternalProject_Add_Step(
    amd-aocl-utils amd-aocl-utils_add-to-aocl-root
    COMMAND bash ${CMAKE_SOURCE_DIR}/scripts/create_symlink.sh ${AMD-AOCL-UTILS_DIR}/include ${CMAKE_INSTALL_PREFIX}/aocl/include
    COMMAND bash ${CMAKE_SOURCE_DIR}/scripts/create_symlink.sh ${AMD-AOCL-UTILS_DIR}/lib ${CMAKE_INSTALL_PREFIX}/aocl/lib
    COMMAND ln -sf ${AMD-AOCL-UTILS_DIR} ${CMAKE_INSTALL_PREFIX}/aocl/amd-aocl-utils
    DEPENDEES amd-aocl-utils_symlink
  )
endif()

list(APPEND AOCL_ROOT "${CMAKE_INSTALL_PREFIX}/aocl")

add_library(AMD-AOCL-UTILS::AMD-AOCL-UTILS INTERFACE IMPORTED GLOBAL)

# amd-libflame
list(APPEND amd-libflame_cmake_args "-D LIBAOCLUTILS_INCLUDE_PATH=${AOCL_ROOT}/amd-aocl-utils/include")
#list(APPEND amd-libflame_cmake_args "-D LIBAOCLUTILS_LIBRARY_PATH=${AOCL_ROOT}/amd-aocl-utils/lib")

# amd-mumps
#list(APPEND amd-mumps_cmake_args "-D USER_PROVIDED_UTILS_LIBRARY_PATH=${AMD-AOCL-UTILS_DIR}")
#list(APPEND amd-mumps_cmake_args "-D USER_PROVIDED_UTILS_INCLUDE_PATH=${AMD-AOCL-UTILS_DIR}")
