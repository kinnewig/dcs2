include(ExternalProject)

find_package(PETSC)
if(PETSC_FOUND)
  
else()
  message(STATUS "Building PETSC")

  list(APPEND petsc_autotool_args "--prefix=${CMAKE_INSTALL_PREFIX}/petsc/${PETSC_VERSION}")
  list(APPEND petsc_autotool_args "--with-debuggin")
  list(APPEND petsc_autotool_args "--with-shared-librarie")
  list(APPEND petsc_autotool_args "--with-mpi=1")
  list(APPEND petsc_autotool_args "--with-x=0")
  list(APPEND petsc_autotool_args "--with-cc=${MPI_C_COMPILER}")
  list(APPEND petsc_autotool_args "--with-cxx=${MPI_CXX_COMPILER}")
  list(APPEND petsc_autotool_args "--with-fc=${MPI_Fortran_COMPILER}")

  if(DEALII_WITH_64BIT)
    list(APPEND petsc_autotool_args "--with-64-bit-indices=1")
  else()
    list(APPEND petsc_autotool_args "--with-64-bit-indices=0")
  endif()
  
  build_autotools_subproject("petsc")

  # Dependencies:
  list(APPEND dealii_dependencies "petsc")
  list(APPEND slepc_dependencies "petsc")
endif()

# Add petsc to deal.II
list(APPEND dealii_cmake_args "-D DEAL_II_WITH_PETSC:BOOL=ON")
list(APPEND dealii_cmake_args "-D PETSC_DIR=${PETSC_DIR}")
