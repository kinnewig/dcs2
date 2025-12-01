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
 
  set(libsc_force_mpi_compilier "ON")
  build_cmake_subproject("libsc")

  list(APPEND p4est_dependencies "libsc")
  list(APPEND t8code_dependencies "libsc")
  
  
  # P4EST itself
  set(p4est_cmake_args
    -D mpi:BOOL=ON 
    -D openmp:BOOL=ON
    -D SC_DIR=${LIBSC_DIR}
    ${p4est_cmake_args}
   )
 
  set(p4est_force_mpi_compilier "ON")
  build_cmake_subproject("p4est")

  # Dependencies:
  list(APPEND dealii_dependencies "p4est")
  list(APPEND t8code_dependencies "p4est")
endif()

# Add SC and P4EST to T8CODE
list(APPEND t8code_cmake_args "-D T8CODE_USE_SYSTEM_SC:BOOL=ON")
list(APPEND t8code_cmake_args "-D SC_ROOT=/home/ifam/kinnewig/Software/dcs2/p4est/2.8.7")
list(APPEND t8code_cmake_args "-D T8CODE_USE_SYSTEM_P4EST:BOOL=ON")
list(APPEND t8code_cmake_args "-D P4EST_ROOT=/home/ifam/kinnewig/Software/dcs2/p4est/2.8.7")

# Add P4est to deal.II

# TODO: Only enable P4EST when t8code is not present. 
#       At the moment, t8code still requires P4EST, but P4EST has to be disabled 
#       in deal.II to avoid conflicts between both packages.
if(TPL_ENABLE_T8CODE)
  list(APPEND dealii_cmake_args "-D DEAL_II_WITH_P4EST=OFF") 
else()
  list(APPEND dealii_cmake_args "-D DEAL_II_WITH_P4EST=ON") 
endif()

list(APPEND dealii_cmake_args "-D P4EST_DIR=${P4EST_DIR}") 

