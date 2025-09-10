include(ExternalProject)

find_package(MUMPS)
if(NOT MUMPS_FOUND)
  message(STATUS "Building MUMPS")
  
  set(mumps_cmake_args
    -D BUILD_SINGLE:BOOL=ON
    -D BUILD_DOUBLE:BOOL=ON
    -D BUILD_COMPLEX:BOOL=${DEALII_WITH_COMPLEX}
    -D BUILD_COMPLEX16:BOOL=${DEALII_WITH_COMPLEX}
    -D BUILD_TESTING:BOOL=OFF
    ${mumps_cmake_args}
  )

  build_cmake_subproject("mumps")

  # Dependencies:
  list(APPEND petsc_dependencies "mumps")
  list(APPEND trilinos_dependencies "mumps")
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
