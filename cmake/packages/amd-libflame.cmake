include(ExternalProject)

find_package(AMD-LIBFLAME)
if(NOT AMD-LIBFLAME_FOUND)
  message(STATUS "Building AMD LIBFLAME")

  set(amd-libflame_cmake_args
    -D ENABLE_AMD_AOCC_FLAGS:BOOL=ON
    -D ENABLE_AMD_OPT:BOOL=ON
    -D ENABLE_BUILTIN_LAPACK2FLAME:BOOL=ON 
    -D ENABLE_EXT_LAPACK_INTERFACE:BOOL=ON
    -D ENABLE_EMBED_AOCLUTILS:BOOL=ON
    ${amd-libflame_cmake_args}
  )

  if(${DEALII_WITH_64BIT})
    list(APPEND amd-libflame_cmake_args "-D ENABLE_ILP64=ON")
  endif()
  
  build_cmake_subproject(amd-libflame)

  # Symlink to lapack names
  ExternalProject_Add_Step(
    amd-libflame amd-libflame_symlink_to_lapack
    COMMAND ln -sf libflame.a liblapack.a
    COMMAND ln -sf libflame${CMAKE_SHARED_LIBRARY_SUFFIX} liblapack${CMAKE_SHARED_LIBRARY_SUFFIX}
    COMMAND ln -sf libflame.a flame.a
    COMMAND ln -sf libflame${CMAKE_SHARED_LIBRARY_SUFFIX} flame${CMAKE_SHARED_LIBRARY_SUFFIX}
    WORKING_DIRECTORY ${AMD-LIBFLAME_DIR}/lib
    DEPENDEES install
  )

  list(APPEND arpackng_dependencies  "amd-libflame")
  list(APPEND dealii_dependencies    "amd-libflame")
  list(APPEND petsc_dependencies     "amd-libflame")
  list(APPEND trilinos_dependencies  "amd-libflame")
  list(APPEND scalapack_dependencies "amd-libflame")
  list(APPEND amd-mumps_dependencies "amd-libflame")
endif()

add_library(LIBFLAME::LIBFLAME INTERFACE IMPORTED GLOBAL)

# Add libflame to ARPACK-NG
list(APPEND arpack-ng_cmake_args "-D LAPACK_LIBRARIES:PATH=${AMD-LIBFLAME_DIR}/lib/libflame${CMAKE_SHARED_LIBRARY_SUFFIX}")

# Add libflame to deal.II
list(APPEND dealii_cmake_args "-D DEAL_II_WITH_LAPACK:BOOL=ON")
list(APPEND dealii_cmake_args "-D LAPACK_DIR=${AMD-LIBFLAME_DIR}")
list(APPEND dealii_cmake_args "-D LAPACK_LIBRARIES=${AMD-LIBFLAME_DIR}/lib/libflame${CMAKE_SHARED_LIBRARY_SUFFIX}")

# Add libflame to PETSc
list(APPEND petsc_autotool_args "--with-libflame=true")
list(APPEND petsc_autotool_args "--with-libflame-dir=${AMD-LIBFLAME_DIR}")

# Add libflame to trilinos
list(APPEND trilinos_cmake_args "-D TPL_ENABLE_LAPACK:BOOL=ON")
list(APPEND trilinos_cmake_args "-D LAPACK_LIBRARY_NAMES=libflame${CMAKE_SHARED_LIBRARY_SUFFIX}")
list(APPEND trilinos_cmake_args "-D LAPACK_LIBRARY_DIRS:PATH=${AMD-LIBFLAME_DIR}/lib")

# Add libflame to ScaLAPACK
list(APPEND amd-scalapack_cmake_args "-D LAPACK_LIBRARIES:STRING=${AMD-LIBFLAME_DIR}/lib/libflame${CMAKE_SHARED_LIBRARY_SUFFIX}")

# Add libflame to MUMPS
list(APPEND amd-mumps_cmake_args "-D USER_PROVIDED_LAPACK_LIBRARY_PATH=${AMD-LIBFLAME_DIR}")
list(APPEND amd-mumps_cmake_args "-D USER_PROVIDED_LAPACK_INCLUDE_PATH=${AMD-LIBFLAME_DIR}")

# Add libflame to SuiteSparse
list(APPEND suitesparse_cmake_args "-D LAPACK_LIBRARIES:PATH=${AMD-LIBFLAME_DIR}/lib/libflame${CMAKE_SHARED_LIBRARY_SUFFIX}")
