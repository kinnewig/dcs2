include(ExternalProject)

find_package(SCALAPACK)
if(NOT SCALAPACK_FOUND)
  message(STATUS "Building SCALAPACK")

  set(scalapack_cmake_args
    -D BUILD_SINGLE:BOOL=ON
    -D BUILD_DOUBLE:BOOL=ON
    -D BUILD_COMPLEX:BOOL=${DEALII_WITH_COMPLEX}
    -D BUILD_COMPLEX16:BOOL=${DEALII_WITH_COMPLEX}
    -D BUILD_TESTING:BOOL=OFF
    -D CMAKE_TLS_VERIFY:BOOL=${CMAKE_TLS_VERIFY}
    ${scalapack_cmake_args}
  )

  list(APPEND scalapack_cmake_args -D CMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}/scalapack/${SCALAPACK_VERSION})
  
  set(package_name "scalapack")

  build_cmake_subproject(scalapack)

  list(APPEND dealii_dependencies   "scalapack")
  list(APPEND petsc_dependencies    "scalapack")
  list(APPEND trilinos_dependencies "scalapack")
  list(APPEND mumps_dependencies    "scalapack")
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
list(APPEND mumps_cmake_args -D SCALAPACK_ROOT=${SCALAPACK_DIR})
