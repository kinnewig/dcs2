include(ExternalProject)

# Try to find HDF5 via the CMake build-in function:
list(APPEND HDF5_ROOT "${HDF5_DIR}")
list(APPEND HDF5_ROOT "/usr/include/openmpi-x86_64")
list(APPEND HDF5_ROOT "/usr/lib64/openmpi")
list(APPEND HDF5_ROOT "${SEARCH_DEFAULTS}")
list(APPEND HDF5_ROOT "${CMAKE_INSTALL_PREFIX}/hdf5/${HDF5_VERSION}")
find_package(HDF5)

if(HDF5_FOUND)
  # Check that the LIBRARY is populated:
  if(NOT DEFINED HDF5_LIBRARIES)
    # Try to find the HDF5_DIR:
    get_filename_component(HDF5_DIR "${HDF5_INCLUDE_DIR}" DIRECTORY)

    # Set the Library
    set(HDF5_LIBRARIES "${HDF5_DIR}/lib/libhdf5${CMAKE_SHARED_LIBRARY_SUFFIX}")
  endif()
else()

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

  set(HDF5_INCLUDE_DIR "${HDF5_DIR}/include")
  set(HDF5_LIBRARIES "${HDF5_DIR}/lib/libhdf5${CMAKE_SHARED_LIBRARY_SUFFIX}")
endif()

# add HDF5 to GMSH
if(DEFINED HDF5_DIR)
  list(APPEND gmsh_cmake_args "-D HDF5_ROOT:PATH=${HDF5_DIR}")
endif()

# add HDF5 to netcdf
if(DEFINED HDF5_DIR)
  list(APPEND netcdf_cmake_args "-D HDF5_ROOT:PATH=${HDF5_DIR}")
endif()

# add HDF5 to PETSc
list(APPEND petsc_autotool_args "--with-hdf5=true")
if(DEFINED HDF5_DIR)
  list(APPEND petsc_autotool_args "--with-hdf5-dir=${HDF5_DIR}")
else()
  list(APPEND petsc_autotool_args "--with-hdf5-include=${HDF5_INCLUDE_DIR}")
  list(APPEND petsc_autotool_args "--with-hdf5-lib=${HDF5_LIBRARIES}")
endif()

# add HDF5 to trilinos
# TODO:
#list(APPEND trilinos_cmake_args "-D TPL_ENABLE_HDF5=ON")
#list(APPEND trilinos_cmake_args "-D HDF5_LIBRARY_DIRS:PATH=${HDF5_DIR}/lib64")
#list(APPEND trilinos_cmake_args "-D HDF5_INCLUDE_DIRS:PATH=${HDF5_DIR}/include")

# add HDF5 to dealii
list(APPEND dealii_cmake_args "-D DEAL_II_WITH_HDF5:BOOL=ON")
if(DEFINED HDF5_DIR)
  list(APPEND dealii_cmake_args "-D HDF5_DIR='${HDF5_DIR}'")
else()
  list(APPEND dealii_cmake_args "-D HDF5_INCLUDE_DIRS='${HDF5_INCLUDE_DIRS}'")
  list(APPEND dealii_cmake_args "-D HDF5_LIBRARIES='${HDF5_LIBRARIES}'")
endif()
