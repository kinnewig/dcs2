include(ExternalProject)

find_package(GMP "6.1.2")
if(GMP_FOUND)

  # Add GMP to SuiteSparse (how to link GMP depends on wether we build GMP ourself or if we use the system package)
  list(APPEND suitesparse_cmake_args "-D GMP_INCLUDE_DIR=${GMP_INCLUDE_DIR}")
  list(APPEND suitesparse_cmake_args "-D GMP_LIBRARIES=${GMP_DIR}/lib")

else()
  message(STATUS "Building GMP")
  
  list(APPEND gmp_autotool_args "--prefix=${CMAKE_INSTALL_PREFIX}/gmp/${GMP_VERSION}")

  build_autotools_subproject("gmp")
  
  set(GMP_INCLUDE_DIR "${GMP_DIR}/include")
  set(GMP_LIBRARY "${GMP_DIR}/lib")

  # Dependencies:
  list(APPEND mpfr_dependencies "gmp")
  list(APPEND petsc_dependencies "gmp")
  list(APPEND suitesparse_dependencies "gmp")
  list(APPEND libflame_dependencies "gmp")

  # Add GMP to SuiteSparse (how to link GMP depends on wether we build GMP ourself or if we use the system package)
  list(APPEND suitesparse_cmake_args "-D GMP_INCLUDE_DIR:PATH=${GMP_INCLUDE_DIR}")
  list(APPEND suitesparse_cmake_args "-D GMP_LIBRARY:PATH=${GMP_LIBRARY}/libgmp${CMAKE_SHARED_LIBRARY_SUFFIX}")
  list(APPEND suitesparse_cmake_args "-D GMP_STATIC:PATH=${GMP_LIBRARY}/libgmp.a")
endif()

# add GMP to MPFR
list(APPEND mpfr_autotool_args "--with-gmp=${GMP_DIR}")

# add GMP to PETSc
list(APPEND petsc_autotool_args "--with-gmp=true")
list(APPEND petsc_autotool_args "--with-gmp-dir=${GMP_DIR}")

# add GMP to LibFLAME
list(APPEND libflame_autotools_args "--with-gmp=${GMP_DIR}/lib")
