include(ExternalProject)

find_package(NETCDF)
if(NOT NETCDF_FOUND)
  message(STATUS "Building netcdf")
  
  set(netcdf_cmake_args
    -D CMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}/netcdf/${netcdf_VERSION}
    -D CMAKE_C_COMPILER:PATH=${MPI_C_COMPILER}
    -D CMAKE_BUILD_TYPE:STRING=Release
    -D ENABLE_DAP:BOOL=OFF 
    -D ENABLE_NETCDF_4:BOOL=ON
    ${netcdf_cmake_args}
  )

  build_cmake_subproject("netcdf")

  # Dependencies:
  list(APPEND trilinos_dependencies "netcdf")
endif()

# add netcdf to trilinos
list(APPEND trilinos_cmake_args "-D TPL_ENABLE_Netcdf:BOOL=ON")
list(APPEND trilinos_cmake_args "-D Netcdf_LIBRARY_DIRS:PATH=${NETCDF_DIR}/lib")
list(APPEND trilinos_cmake_args "-D Netcdf_INCLUDE_DIRS:PATH=${NETCDF_DIR}/include")
# To use netcdf in Trilinos we also need to enable the follwoing packages in Trilinos
list(APPEND trilinos_cmake_args "-D Trilinos_ENABLE_SEACAS=ON")
