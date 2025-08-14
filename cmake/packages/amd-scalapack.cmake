include(ExternalProject)

find_package(SCALAPACK)
if(NOT SCALAPACK_FOUND)
  message(STATUS "Building AMD SCALAPACK")

  set(scalapack_cmake_args
    -D CMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}/amd-scalapack/${AMD-SCALAPACK_VERSION}
    -D CMAKE_C_COMPILER:PATH=${MPI_C_COMPILER}
    -D CMAKE_Fortran_COMPILER:PATH=${MPI_Fortran_COMPILER}
    -D CMAKE_BUILD_TYPE:STRING=Release
    -D BUILD_SHARED_LIBS:BOOL=ON 
    ${amd-scalapack_cmake_args}
  )

  get_filename_component(MPI_BASE_DIR "${MPI_C_LIBRARIES}" DIRECTORY)
  get_filename_component(MPI_BASE_DIR "${MPI_BASE_DIR}" DIRECTORY)
  list(APPEND amd-scalapack_cmake_args "-D MPI_BASE_DIR:PATH='${MPI_BASE_DIR}'")

  if(${DEALII_WITH_64BIT})
    list(APPEND amd-scalapack_cmake_args "-D ENABLE_ILP64:BOOL=ON")
  endif()

  build_cmake_subproject(amd-scalapack)

  # patch ParMETIS
  ExternalProject_Add_Step(
    amd-scalapack amd-scalapack_patch
    COMMAND sed -i "s/if (MPI_FOUND)/if (TRUE)/g" CMakeLists.txt
    COMMAND sed -i "s/CHECK_FORTRAN_FUNCTION_EXISTS(\"dgesv\" LAPACK_FOUND)/set(LAPACK_FOUND TRUE)/g" CMakeLists.txt
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/amd-scalapack-prefix/src/amd-scalapack
    DEPENDEES download
    DEPENDERS update
  )


  # update the resulting dir name:
  set(SCALAPACK_DIR ${AMD-SCALAPACK_DIR})

  #  Dependecies
  list(APPEND dealii_dependencies   "amd-scalapack")
  list(APPEND petsc_dependencies    "amd-scalapack")
  list(APPEND trilinos_dependencies "amd-scalapack")
  list(APPEND mumps_dependencies    "amd-scalapack")
endif()
  
# Add scalapack to deal.II
list(APPEND dealii_cmake_args "-D DEAL_II_WITH_SCALAPACK:BOOL=ON")
list(APPEND dealii_cmake_args "-D SCALAPACK_DIR=${SCALAPACK_DIR}")

# Add scalapack as dependecie to PETSc
list(APPEND petsc_autotool_args "--with-scalapack=true")
list(APPEND petsc_autotool_args "--with-scalapack-lib=${SCALAPACK_DIR}/lib64/libscalapack${CMAKE_SHARED_LIBRARY_SUFFIX}")

# Add scalapack to trilinos
list(APPEND trilinos_cmake_args "-D TPL_ENABLE_SCALAPACK:BOOL=ON")
list(APPEND trilinos_cmake_args "-D SCALAPACK_LIBRARY_NAMES='scalapack'")
list(APPEND trilinos_cmake_args "-D SCALAPACK_LIBRARY_DIRS:PATH=${SCALAPACK_DIR}/lib;${SCALAPACK_DIR}/lib64")
list(APPEND trilinos_cmake_args "-D Amesos_ENABLE_SCALAPACK:BOOL=ON")

# Add scalapack to mumps
list(APPEND mumps_cmake_args -D SCALAPACK_ROOT=${SCALAPACK_DIR})
