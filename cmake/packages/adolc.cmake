include(ExternalProject)

find_package(ADOLC)

# Preperation: ADOL-C is in the process in migration, from the next release on, it will use CMake.
# This is cam be used to install the master
#if(NOT ADOLC_FOUND)
#  message(STATUS "Building ADOLC")
#  
#  set(adolc_cmake_args
#    -D ENABLE_ADVANCE_BRANCHING=1
#    -D ENABLE_TRACELESS_REFCOUNTING=1
#    -D ENABLE_STDCZERO=0
#    ${adolc_cmake_args}
#  )
#
#  build_cmake_subproject("adolc")
#
#  # Dependencies:
#  list(APPEND petsc_dependencies "adolc")
#  list(APPEND dealii_dependencies "adolc")
#endif()

# For the meantime we have to use an autotools build chain:
if(NOT ADOLC_FOUND)
  list(APPEND adolc_autotool_args "--prefix=${CMAKE_INSTALL_PREFIX}/adolc/${ADOLC_VERSION}")
  list(APPEND adolc_autotool_args "--enable-advanced-branching")
  list(APPEND adolc_autotool_args "--enable-atrig-erf")
  list(APPEND adolc_autotool_args "--enable-traceless_refcounting")
  list(APPEND adolc_autotool_args "--enable-stdczero")
  list(APPEND adolc_autotool_args "--with-boost=no")

  build_autotools_subproject("adolc")

  # Dependencies:
  #list(APPEND petsc_dependencies "adolc") (see Issue: #32)
  list(APPEND trilinos_dependencies "adolc")
  list(APPEND dealii_dependencies "adolc")
endif()

# add ADOLC to PETSc
# See Issue #32
#list(APPEND petsc_autotool_args "--with-adolc=true")
#list(APPEND petsc_autotool_args "--with-adolc-dir=${ADOLC_DIR}")

# add ADOLC to Trilinos
list(APPEND trilinos_cmake_args "-D TPL_ENABLE_ADOLC=ON")
list(APPEND trilinos_cmake_args "-D ADOLC_LIBRARY_DIRS:PATH=${ADOLC_DIR}/lib;${ADOLC_DIR}/lib64")
list(APPEND trilinos_cmake_args "-D ADOLC_INCLUDE_DIRS:PATH=${ADOLC_DIR}/include")

# Force deal.II to use ADOLC
list(APPEND dealii_cmake_args "-D ADOLC_DIR:PATH=${ADOLC_DIR}")
