include(ExternalProject)

find_package(HDF5)
if(NOT HDF5_FOUND)
  message(STATUS "Building HDF5")
  
  set(hdf5_cmake_args
    -D CMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}/hdf5/${HDF5_VERSION}
    -D CMAKE_C_COMPILER:PATH=${CMAKE_MPI_C_COMPILER}
    -D CMAKE_C_COMPILER:PATH=${CMAKE_MPI_CXX_COMPILER}
    -D CMAKE_Fortran_COMPILER:PATH=${CMAKE_MPI_Fortran_COMPILER}
    -D CMAKE_BUILD_TYPE:STRING=Release
    ${hdf5_cmake_args}
  )

  build_cmake_subproject("hdf5")

  # Dependencies:
  list(APPEND petsc_dependencies "hdf5")
  #list(APPEND trilinos_dependencies "hdf5")
  list(APPEND dealii_dependencies "hdf5")
endif()

# add HDF5 to PETSc
list(APPEND petsc_autotool_args "--with-hdf5=true")
list(APPEND petsc_autotool_args "--with-hdf5-dir=${HDF5_DIR}")

# add HDF5 to trilinos
#list(APPEND trilinos_cmake_args "-D TPL_ENABLE_HDF5=ON")
#list(APPEND trilinos_cmake_args "-D HDF5_LIBRARY_DIRS:PATH=${HDF5_DIR}/lib64")
#list(APPEND trilinos_cmake_args "-D HDF5_INCLUDE_DIRS:PATH=${HDF5_DIR}/include")

# Force deal.II to use HDF5
list(APPEND dealii_cmake_args "-D HDF5_DIR:PATH=${HDF5_DIR}")
