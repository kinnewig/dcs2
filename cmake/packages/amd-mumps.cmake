include(ExternalProject)

find_package(MUMPS)
if(NOT MUMPS_FOUND)
  message(STATUS "Building MUMPS")
  
  set(amd-mumps_cmake_args
    -D CMAKE_C_COMPILER:PATH=clang
    -D CMAKE_CXX_COMPILER:PATH=clang++
    -D CMAKE_Fortran_COMPILER:PATH=flang
    -D BUILD_SINGLE:BOOL=ON
    -D BUILD_DOUBLE:BOOL=ON
    -D BUILD_COMPLEX:BOOL=${DEALII_WITH_COMPLEX}
    -D BUILD_COMPLEX16:BOOL=${DEALII_WITH_COMPLEX}
    -D BUILD_TESTING:BOOL=OFF
    -D MUMPS_BUILD_SAMPLES:BOOL=OFF
    -D MUMPS_BUILD_TESTING:BOOL=OFF 
    -D MUMPS_parallel:BOOL=ON 
    -D MPI_Fortran_WORKS:BOOL=TRUE
    ${amd-mumps_cmake_args}
  )

  # -D CMAKE_CFLAGS="-openmp "
  # -D CMAKE_Fortran_FLAGS="-fopenmp"

  if(${DEALII_WITH_64BIT})
    list(APPEND amd-mumps_cmake_args "-D intsize64:BOOL=ON")
  endif()

  # Fix for the CMakeLists that does not find MPI_Fortran
  #ExternalProject_Add_Step(
  #  amd-scalapack amd-scalapack_patch
  #  COMMAND sed -i "s/if (MPI_FOUND)/if (TRUE)/g" CMakeLists.txt
  #  COMMAND sed -i "s/CHECK_FORTRAN_FUNCTION_EXISTS(\"dgesv\" LAPACK_FOUND)/set(LAPACK_FOUND TRUE)/g" CMakeLists.txt
  #  WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/amd-mumps-prefix/src/amd-mumps
  #  DEPENDEES download
  #  DEPENDERS update
  #)

  build_cmake_subproject("amd-mumps")

  # Dependencies:
  list(APPEND petsc_dependencies "amd-mumps")
  list(APPEND trilinos_dependencies "amd-mumps")
endif()

# add MUMPS to PETSc
list(APPEND petsc_autotool_args "--with-mumps=true")
list(APPEND petsc_autotool_args "--with-mumps-dir=${MUMPS_DIR}")

# add MUMPS to trilinos
list(APPEND trilinos_cmake_args "-D TPL_ENABLE_MUMPS=ON")
list(APPEND trilinos_cmake_args "-D MUMPS_LIBRARY_DIRS:PATH=${MUMPS_DIR}/lib")
list(APPEND trilinos_cmake_args "-D MUMPS_INCLUDE_DIRS:PATH=${MUMPS_DIR}/include")
list(APPEND trilinos_cmake_args "-D Amesos_ENABLE_MUMPS:BOOL=ON")

# Force deal.II to use MUMPS
list(APPEND dealii_cmake_args "-D DEAL_II_TRILINOS_WITH_MUMPS:BOOL=ON")
