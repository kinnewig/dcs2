include(ExternalProject)

find_package(TBB)
if(TBB_FOUND)


else()
  message(STATUS "Building TBB")
  
  set(tbb_cmake_args
    -D TBB_STRICT:BOOL=OFF
    ${tbb_cmake_args}
  )

  build_cmake_subproject("tbb")
  
  # Dependencies:
  list(APPEND occt_dependencies "tbb")
  list(APPEND dealii_dependencies "tbb")
endif()

# add TBB to OpenCascade
list(APPEND occt_cmake_args "-D 3RDPARTY_TBB_LIBRARY_DIR=${TBB_DIR}/lib;${TBB_DIR}/lib64")

# Disabled, as Trilinos requires TBB_VERSION < 2019.x.x
# add TBB to Trilinos 
#list(APPEND trilinos_cmake_args "-D TPL_ENABLE_TBB=ON")
#list(APPEND trilinos_cmake_args "-D TBB_LIBRARY_DIRS:PATH=${TBB_DIR}/lib64")
#list(APPEND trilinos_cmake_args "-D TBB_INCLUDE_DIRS:PATH=${TBB_DIR}/include")

# add TBB to deal.II
list(APPEND dealii_cmake_args "-D TBB_DIR=${TBB_DIR}")
