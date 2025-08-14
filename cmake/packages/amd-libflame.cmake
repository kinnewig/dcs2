include(ExternalProject)

find_package(LIBFLAME)
if(NOT LIBFLAME_FOUND)
  message(STATUS "Building AMD LIBFLAME")

  set(amd-libflame_cmake_args
    -D CMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}/amd-libflame/${AMD-LIBFLAME_VERSION}
    -D CMAKE_C_COMPILER:PATH=${CMAKE_MPI_C_COMPILER}
    -D CMAKE_CXX_COMPILER:PATH=${CMAKE_MPI_CXX_COMPILER}
    -D CMAKE_Fortran_COMPILER:PATH=${CMAKE_MPI_Fortran_COMPILER}
    -D CMAKE_BUILD_TYPE:STRING=Release
    -D ENABLE_AMD_AOCC_FLAGS:BOOL=ON
    -D ENABLE_AMD_OPT:BOOL=ON
    -D ENABLE_BUILTIN_LAPACK2FLAME:BOOL=ON 
    -D ENABLE_EXT_LAPACK_INTERFACE:BOOL=ON
    -D AOCL_ROOT=${AOCL_ROOT}
    ${amd-libflame_cmake_args}
  )

  if(${DEALII_WITH_64BIT})
    list(APPEND ${amd-libflame_cmake_args} "-D ENABLE_ILP64=ON")
  endif()
  
  build_cmake_subproject(amd-libflame)

  set(LIBFLAME_DIR ${AMD-LIBFLAME_DIR})

  ExternalProject_Add_Step(
    amd-libflame amd-libflame_symlink_to_lapack
    COMMAND ln -s libflame.a liblapack.a
    COMMAND ln -s libflame${CMAKE_SHARED_LIBRARY_SUFFIX} liblapack${CMAKE_SHARED_LIBRARY_SUFFIX}
    COMMAND ln -s libflame.a flame.a
    COMMAND ln -s libflame${CMAKE_SHARED_LIBRARY_SUFFIX} flame${CMAKE_SHARED_LIBRARY_SUFFIX}
    WORKING_DIRECTORY ${LIBFLAME_DIR}/lib
    DEPENDEES install
  )

  list(APPEND arpackng_dependencies  "amd-libflame")
  list(APPEND dealii_dependencies    "amd-libflame")
  list(APPEND petsc_dependencies     "amd-libflame")
  list(APPEND trilinos_dependencies  "amd-libflame")
  list(APPEND scalapack_dependencies "amd-libflame")
  list(APPEND mumps_dependencies     "amd-libflame")
endif()

add_library(LIBFLAME::LIBFLAME INTERFACE IMPORTED GLOBAL)

# Add libflame to ARPACK-NG
list(APPEND arpack-ng_cmake_args "-D LAPACK_LIBRARIES:PATH=${LIBFLAME_DIR}/lib/libflame${CMAKE_SHARED_LIBRARY_SUFFIX}")

# Add libflame to deal.II
list(APPEND dealii_cmake_args "-D DEAL_II_WITH_LAPACK:BOOL=ON")
list(APPEND dealii_cmake_args "-D LAPACK_DIR=${LIBFLAME_DIR}")
list(APPEND dealii_cmake_args "-D LAPACK_LIBRARIES=${LIBFLAME_DIR}/lib/libflame${CMAKE_SHARED_LIBRARY_SUFFIX}")

# Add libflame to PETSc
list(APPEND petsc_autotool_args "--with-libflame=true")
list(APPEND petsc_autotool_args "--with-libflame-dir=${LIBFLAME_DIR}")

# Add libflame to trilinos
list(APPEND trilinos_cmake_args "-D TPL_ENABLE_LAPACK:BOOL=ON")
list(APPEND trilinos_cmake_args "-D LAPACK_LIBRARY_NAMES=libflame${CMAKE_SHARED_LIBRARY_SUFFIX}")
list(APPEND trilinos_cmake_args "-D LAPACK_LIBRARY_DIRS:PATH=${LIBFLAME_DIR}/lib")

# Add libflame to ScaLAPACK
list(APPEND scalapack_cmake_args "-D LAPACK_ROOT=${LIBFLAME_DIR}")
list(APPEND amd-scalapack_cmake_args "-D LAPACK_LIBRARIES:STRING='${LIBFLAME_DIR}/lib/libflame${CMAKE_SHARED_LIBRARY_SUFFIX};${AMD-AOCL-UTILS_DIR}/lib/libaoclutils${CMAKE_SHARED_LIBRARY_SUFFIX}'")

# Add libflame to MUMPS
list(APPEND mumps_cmake_args "-D LAPACK_ROOT=${LIBFLAME_DIR}")
list(APPEND mumps_cmake_args "-D LAPACK_s_FOUND:BOOL=TRUE")
list(APPEND mumps_cmake_args "-D LAPACK_d_FOUND:BOOL=TRUE")

# Add libflame to SuiteSparse
list(APPEND suitesparse_cmake_args "-D LAPACK_LIBRARIES:PATH=${LIBFLAME_DIR}/lib/libflame${CMAKE_SHARED_LIBRARY_SUFFIX}")
