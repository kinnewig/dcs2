include(ExternalProject)

find_package(P4EST)
if(P4EST_FOUND)

else()

  # First we need to install libsc
  set(libsc_cmake_args
    -D CMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}/libsc/${P4EST_VERSION} 
    -D BUILD_TESTING=OFF 
    -D mpi=ON 
    -D openmp=ON
    ${libsc_cmake_args}
  )
 
  build_cmake_subproject("libsc")

  list(APPEND p4est_dependencies "libsc")
  
  
  # P4EST itself
  set(p4est_cmake_args
    -D mpi:BOOL=ON 
    -D openmp:BOOL=ON
    -D SC_DIR=${LIBSC_DIR}
    ${p4est_cmake_args}
   )
 
   build_cmake_subproject("p4est")

  # Dependencies:
  list(APPEND dealii_dependencies "p4est")
endif()

# Add P4est to deal.II
list(APPEND dealii_cmake_args "-D DEAL_II_WITH_P4EST=ON") 
list(APPEND dealii_cmake_args "-D P4EST_DIR=${P4EST_DIR}") 
