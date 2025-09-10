include(ExternalProject)

find_package(HDF5)
if(NOT HDF5_FOUND)
  message(STATUS "Building HDF5")
  
  list(APPEND hdf5_cmake_args "-D HDF5_ENABLE_PARALLEL:BOOL=ON")

  set(hdf5_force_mpi_compilier "ON")
  build_cmake_subproject("hdf5")

  # Dependencies:
  list(APPEND gmsh_dependencies "hdf5")
  list(APPEND netcdf_dependencies "hdf5")
  list(APPEND petsc_dependencies "hdf5")
  #list(APPEND trilinos_dependencies "hdf5")
  list(APPEND dealii_dependencies "hdf5")
endif()

# add HDF5 to GMSH
list(APPEND gmsh_cmake_args "-D HDF5_ROOT:PATH=${OCCT_DIR}")

# add HDF5 to netcdf
list(APPEND netcdf_cmake_args "-D HDF5_ROOT:PATH=${HDF5_DIR}")

# add HDF5 to PETSc
list(APPEND petsc_autotool_args "--with-hdf5=true")
list(APPEND petsc_autotool_args "--with-hdf5-dir=${HDF5_DIR}")

# add HDF5 to trilinos
# TODO:
#list(APPEND trilinos_cmake_args "-D TPL_ENABLE_HDF5=ON")
#list(APPEND trilinos_cmake_args "-D HDF5_LIBRARY_DIRS:PATH=${HDF5_DIR}/lib64")
#list(APPEND trilinos_cmake_args "-D HDF5_INCLUDE_DIRS:PATH=${HDF5_DIR}/include")

# Force deal.II to use HDF5
list(APPEND dealii_cmake_args "-D DEAL_II_WITH_HDF5:BOOL=ON")
list(APPEND dealii_cmake_args "-D HDF5_DIR:PATH=${HDF5_DIR}")
