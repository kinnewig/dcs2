include(ExternalProject)

find_package(SCALAPACK)
if(NOT SCALAPACK_FOUND)
  message(STATUS "Building AMD SCALAPACK")

  if(${DEALII_WITH_64BIT})
    list(APPEND amd-scalapack_cmake_args "-D ENABLE_ILP64:BOOL=ON")
  endif()


  set(amd-scalapack_cmake_args
    -D CMAKE_C_COMPILER:PATH=clang
    -D CMAKE_CXX_COMPILER:PATH=clang++
    -D CMAKE_Fortran_COMPILER:PATH=flang
    -D SCALAPACK_BUILD_TESTS:BOOL=OFF
    ${amd-scalapack_cmake_args}
  )

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
  list(APPEND dealii_dependencies    "amd-scalapack")
  list(APPEND petsc_dependencies     "amd-scalapack")
  list(APPEND trilinos_dependencies  "amd-scalapack")
  list(APPEND amd-mumps_dependencies "amd-scalapack")
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
list(APPEND amd-mumps_cmake_args -D SCALAPACK_ROOT=${SCALAPACK_DIR})
