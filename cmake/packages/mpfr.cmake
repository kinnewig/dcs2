include(ExternalProject)

find_package(MPFR "4.0.2")
if(MPFR_FOUND)

  # add MPFR to SuiteSparse
  list(APPEND suitesparse_cmake_args "-D MPFR_INCLUDE_DIR:PATH=${MPFR_INCLUDE_DIR}")
  list(APPEND suitesparse_cmake_args "-D MPFR_LIBRARY:PATH=${MPFR_LIBRARY}")

  # add MPFR to PETSc
  list(APPEND petsc_autotool_args "--with-mpfr=true")
  list(APPEND petsc_autotool_args "--with-mpfr-dir=${MPFR_DIR}")

else()
  message(STATUS "Building MPFR")
  
  list(APPEND mpfr_autotool_args "--prefix=${CMAKE_INSTALL_PREFIX}/mpfr/${MPFR_VERSION}")
  list(APPEND mpfr_autotool_args "CFLAGS=-std=c11")
  list(APPEND mpfr_autotool_args "CXXFLAGS=-std=c11")
  
  build_autotools_subproject_with_custom_configure_and_update("mpfr" "./configure" "./autogen.sh")

  set(MPFR_LIBRARY "${MPFR_DIR}/lib")
  set(MPFR_INCLUDE_DIR "${MPFR_DIR}/include")

  # Dependencies:
  list(APPEND suitesparse_dependencies "mpfr")
  list(APPEND petsc_dependencies "mpfr")
endif()

# add MPFR to PETSc
list(APPEND petsc_autotool_args "--with-mpfr=true")
list(APPEND petsc_autotool_args "--with-mpfr-dir=${MPFR_DIR}")

# add MPFR to SuiteSparse
list(APPEND suitesparse_cmake_args "-D MPFR_INCLUDE_DIR:PATH=${MPFR_INCLUDE_DIR}")
list(APPEND suitesparse_cmake_args "-D MPFR_LIBRARY:PATH=${MPFR_LIBRARY}")
#list(APPEND suitesparse_cmake_args "-D MPFR_LIBRARY:PATH=${MPFR_LIBRARY}/libmpfr${CMAKE_SHARED_LIBRARY_SUFFIX}")
#list(APPEND suitesparse_cmake_args "-D MPFR_STATIC:PATH=${MPFR_LIBRARY}/libmpfr.a")

