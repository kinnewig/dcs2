include(ExternalProject)

find_package(LIBFLAME)
if(LIBFLAME_FOUND)
  
else()
  message(STATUS "Building LIBFLAME")

  list(APPEND libflame_autotool_args "--prefix=${CMAKE_INSTALL_PREFIX}/libflame/${LIBFLAME_VERSION}")

  # Set the corresponding flags, depending if we build AMD Libflame or default libflame
  if (AMD)
    list(APPEND libflame_autotool_args "--enable-amd-flags")
  else()
    list(APPEND libflame_autotool_args "--enable-lapack2flame")
    list(APPEND libflame_autotool_args "--enable-external-lapack-interfaces")
    list(APPEND libflame_autotool_args "--enable-dynamic-build")
    list(APPEND libflame_autotool_args "--with-cc=gcc")
    list(APPEND libflame_autotool_args "--disable-builtin-blas")
    list(APPEND libflame_autotool_args "--enable-max-arg-list-hack")
    list(APPEND libflame_autotool_args "CFLAGS=-fPIC")
    list(APPEND libflame_autotool_args "CPPFLAGS=-fPIC")
    list(APPEND libflame_autotool_args "FFLAGS=-fPIC")
    list(APPEND libflame_autotool_args "FCFLAGS=-fPIC")

    # TODO: this is a workarround for bug: https://github.com/flame/libflame/issues/102
    list(APPEND libflame_autotool_args "--enable-legacy-lapack")
  endif()
  
  if (AMD)
    # update the names:
    if(DEFINED LIBFLAME_CUSTOM_URL)
      set(AMD-LIBFLAME_CUSTOM_URL ${LIBFLAME_CUSTOM_URL})
    endif()
    if(DEFINED LIBFLAME_CUSTOM_TAG)
      set(AMD-LIBFLAME_CUSTOM_TAG ${LIBFLAME_CUSTOM_TAG})
    endif()
    set(amd-libflame_autotool_args ${libflame_autotool_args})
    set(amd-libflame_dependencies ${libflame_dependencies})
    set(package_name "amd-libflame")
  else()
    set(package_name "libflame")
  endif()

  build_autotools_subproject(${package_name})

  if (AMD)
    # update the resulting dir name:
    set(LIBFLAME_DIR ${AMD-LIBFLAME_DIR})
  endif()

  ExternalProject_Add_Step(
    libflame libflame_symlink_to_lapack
    COMMAND ln -s libflame.a liblapack.a
    COMMAND ln -s libflame${CMAKE_SHARED_LIBRARY_SUFFIX} liblapack${CMAKE_SHARED_LIBRARY_SUFFIX}
    COMMAND ln -s libflame.a flame.a
    COMMAND ln -s libflame${CMAKE_SHARED_LIBRARY_SUFFIX} flame${CMAKE_SHARED_LIBRARY_SUFFIX}
    WORKING_DIRECTORY ${LIBFLAME_DIR}/lib
    DEPENDEES install
  )

  # Dependencies:
  if (AMD)
    list(APPEND dealii_dependencies    "amd-libflame")
    list(APPEND petsc_dependencies     "amd-libflame")
    list(APPEND trilinos_dependencies  "amd-libflame")
    list(APPEND scalapack_dependencies "amd-libflame")
    list(APPEND mumps_dependencies     "amd-libflame")
  else()
    list(APPEND dealii_dependencies    "libflame")
    list(APPEND petsc_dependencies     "libflame")
    list(APPEND trilinos_dependencies  "libflame")
    list(APPEND scalapack_dependencies "libflame")
    list(APPEND mumps_dependencies     "libflame")
  endif()
endif()

add_library(LIBFLAME::LIBFLAME INTERFACE IMPORTED GLOBAL)

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

# Add libflame to ScaLAPACK
list(APPEND mumps_cmake_args "-D LAPACK_ROOT=${LIBFLAME_DIR}")
list(APPEND mumps_cmake_args "-D LAPACK_s_FOUND:BOOL=TRUE")
list(APPEND mumps_cmake_args "-D LAPACK_d_FOUND:BOOL=TRUE")

# Add libflame to SuiteSparse
list(APPEND suitesparse_cmake_args "-D LAPACK_LIBRARIES:PATH=${LIBFLAME_DIR}/lib/libflame${CMAKE_SHARED_LIBRARY_SUFFIX}")
