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
  
  # get the download url for libflame:
  file(READ ${CMAKE_CURRENT_LIST_DIR}/libraries.json json)

  # If we are on a amd build use AMD's libflame:
  if (AMD)
    string(JSON libflame_url GET ${json} amd libflame git)
    string(JSON libflame_tag GET ${json} amd libflame ${AMD_LAPACK_VERSION} tag)
    set(libflame_tag "4.0")
  else()
    string(JSON libflame_url GET ${json} libflame git)
    string(JSON libflame_tag GET ${json} libflame ${LIBFLAME_VERSION} tag)
  endif()

  if (NOT libflame_tag)
    message(FATAL_ERROR "Git tag for LIBFLAME version ${LIBFLAME_VERSION} not found in ${CMAKE_CURRENT_LIST_DIR}/libraries.json.")
  endif()


  
  # If a custom URL for libflame is defined, use it.
  if (DEFINED LIBFLAME_CUSTOM_URL)
    set(libflame_url ${LIBFLAME_CUSTOM_URL})
    message("Using custom download URL for LIBFLAME: ${LIBFLAME_CUSTOM_URL}")
  endif()
  
  # If a custom tag for libflame is defined, use it.
  if (DEFINED LIBFLAME_CUSTOM_TAG)
    set(libflame_tag ${LIBFLAME_CUSTOM_TAG})
    message("Using custom git tag for LIBFLAME: ${LIBFLAME_CUSTOM_URL}")
  endif()
  
  if (DEFINED LIBFLAME_SOURCE_DIR)
    ExternalProject_Add(libflame
      URL ${LIBFLAME_SOURCE_DIR}
      BUILD_COMMAND make -j ${THREADS}
      INSTALL_COMMAND make install
      CONFIGURE_COMMAND ./configure ${libflame_autotool_args}
      INSTALL_DIR ${CMAKE_INSTALL_PREFIX}/libflame/${LIBFLAME_VERSION}
      BUILD_IN_SOURCE ON
      BUILD_BYPRODUCTS ${LIBFLAME_LIBRARIES}
      CMAKE_GENERATOR ${DEFAULT_GENERATOR}
      DEPENDS ${libflame_dependencies}
    )
  else()
    ExternalProject_Add(libflame
      GIT_REPOSITORY ${libflame_url}
      GIT_TAG ${libflame_tag}
      GIT_SHALLOW true
      BUILD_COMMAND make -j ${THREADS}
      INSTALL_COMMAND make install
      CONFIGURE_COMMAND ./configure ${libflame_autotool_args}
      INSTALL_DIR ${CMAKE_INSTALL_PREFIX}/libflame/${LIBFLAME_VERSION}
      BUILD_IN_SOURCE ON
      BUILD_BYPRODUCTS ${LIBFLAME_LIBRARIES}
      CMAKE_GENERATOR ${DEFAULT_GENERATOR}
      DEPENDS ${libflame_dependencies}
    )
  endif()
  
  ExternalProject_Get_Property(libflame INSTALL_DIR)

  # Populate the path
  set(LIBFLAME_DIR ${INSTALL_DIR})
  list(APPEND CMAKE_PREFIX_PATH "${LIBFLAME_DIR}")

  ExternalProject_Add_Step(
    libflame libflame_symlink
    COMMAND ln -s libflame.a liblapack.a
    COMMAND ln -s libflame${CMAKE_SHARED_LIBRARY_SUFFIX} liblapack${CMAKE_SHARED_LIBRARY_SUFFIX}
    COMMAND ln -s libflame.a flame.a
    COMMAND ln -s libflame${CMAKE_SHARED_LIBRARY_SUFFIX} flame${CMAKE_SHARED_LIBRARY_SUFFIX}
    WORKING_DIRECTORY ${LIBFLAME_DIR}/lib
    DEPENDEES install
  )


  # Linking
  add_library(LIBFLAME::LIBFLAME INTERFACE IMPORTED GLOBAL)
  set_target_properties(LIBFLAME::LIBFLAME PROPERTIES
    IMPORTED_LOCATION ${LIBFLAME_DIR}/lib/libflame${CMAKE_SHARED_LIBRARY_SUFFIX}
    INTERFACE_INCLUDE_DIRECTORIES ${LIBFLAME_DIR}/include
  )

  # Dependencies:
  # Add libflame as dependecie to deal.II
  list(APPEND dealii_dependencies "libflame")

  # Add libflame as dependecie to PETSc
  list(APPEND petsc_dependencies "libflame")

  # Add libflame as dependecie to trilinos
  list(APPEND trilinos_dependencies "libflame")

  # Add libflame as dependecie to ScaLAPACK
  list(APPEND scalapack_dependencies "libflame")

  # Add libflame as dependecie to MUMPS
  list(APPEND mumps_dependencies "libflame")

endif()

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
