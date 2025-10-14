include(ExternalProject)

find_package(AMD-MUMPS)
if(NOT AMD-MUMPS_FOUND)
  message(STATUS "Building MUMPS")
  
  set(amd-mumps_cmake_args
    -D BUILD_SINGLE:BOOL=ON
    -D BUILD_DOUBLE:BOOL=ON
    -D BUILD_COMPLEX:BOOL=${DEALII_WITH_COMPLEX}
    -D BUILD_COMPLEX16:BOOL=${DEALII_WITH_COMPLEX}
    -D BUILD_TESTING:BOOL=OFF
    -D MUMPS_BUILD_SAMPLES:BOOL=OFF
    -D MUMPS_BUILD_TESTING:BOOL=OFF 
    -D MUMPS_parallel:BOOL=ON 
    -D MPI_Fortran_WORKS:BOOL=TRUE
    -D CMAKE_AOCL_ROOT="not-empty"
    ${amd-mumps_cmake_args}
  )

  if(${DEALII_WITH_64BIT})
    list(APPEND amd-mumps_cmake_args "-D intsize64:BOOL=ON")
  else()
    list(APPEND amd-mumps_cmake_args "-D intsize64:BOOL=OFF")
  endif()

  set(amd-mumps_force_mpi_compilier "ON")
  build_cmake_subproject("amd-mumps")

  # Fix for AMD-MUMPS, this is very buggy...
   ExternalProject_Add_Step(
      amd-mumps amd-mumps_patch
      COMMAND sed -i "s/APPEND LAPACK_FIND_COMPONENTS Netlib/APPEND LAPACK_FIND_COMPONENTS AOCL/g" cmake/FindLAPACK.cmake
      COMMAND sed -i "s/AOCL IN_LIST SCALAPACK_FIND_COMPONENTS/TRUE/g" cmake/FindSCALAPACK.cmake
      COMMAND sed -i "s/-i8//g" CMakeLists.txt
      COMMAND sed -i "/^[[:space:]]*NAMES[[:space:]]\+parmetis[[:space:]]*$/a\\ HINTS \${USER_PROVIDED_PARMETIS_LIBRARY_PATH} \${CMAKE_PARMETIS_ROOT}/metis \${CMAKE_PARMETIS_ROOT}" cmake/FindMETIS.cmake
      COMMAND mv cmake/Config.cmake.in cmake/config.cmake.in
      WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/amd-mumps-prefix/src/amd-mumps
      DEPENDEES download
      DEPENDERS update
    )

  # Dependencies:
  list(APPEND petsc_dependencies "amd-mumps")
  list(APPEND trilinos_dependencies "amd-mumps")
endif()

# add MUMPS to PETSc
list(APPEND petsc_autotool_args "--with-mumps=true")
list(APPEND petsc_autotool_args "--with-mumps-dir=${AMD-MUMPS_DIR}")

# add MUMPS to trilinos
list(APPEND trilinos_cmake_args "-D TPL_ENABLE_MUMPS=ON")
list(APPEND trilinos_cmake_args "-D MUMPS_LIBRARY_DIRS:PATH=${AMD-MUMPS_DIR}/lib")
list(APPEND trilinos_cmake_args "-D MUMPS_INCLUDE_DIRS:PATH=${AMD-MUMPS_DIR}/include")
list(APPEND trilinos_cmake_args "-D Amesos_ENABLE_MUMPS:BOOL=ON")
list(APPEND trilinos_cmake_args "-D Amesos2_ENABLE_MUMPS:BOOL=ON")

# Force deal.II to use MUMPS
list(APPEND dealii_cmake_args "-D DEAL_II_WITH_MUMPS:BOOL=ON")
list(APPEND dealii_cmake_args "-D MUMPS_DIR:PATH=${AMD-MUMPS_DIR}")
list(APPEND dealii_cmake_args "-D DEAL_II_TRILINOS_WITH_MUMPS:BOOL=ON")
