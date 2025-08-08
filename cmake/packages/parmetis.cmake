include(ExternalProject)

find_package(PARMETIS)
if(PARMETIS_FOUND)
  
else()
  message(STATUS "Building PARMETIS")


  list(APPEND parmetis_autotool_args "prefix=${CMAKE_INSTALL_PREFIX}/metis/${METIS_VERSION}")
  list(APPEND parmetis_autotool_args "shared=1")
  list(APPEND parmetis_autotool_args "cc=${${CMAKE_MPI_C_COMPILER}}")

  build_autotools_subproject_with_custom_configure("parmetis" "make")

  # Dependencies:
  list(APPEND dealii_dependencies "parmetis")
  list(APPEND trilinos_dependencies "parmetis")
  list(APPEND petsc_dependencies "parmetis")
  list(APPEND superlu_dist_dependencies "parmetis")
endif()

# Add parmetis to deal.II
list(APPEND dealii_cmake_args "-D DEAL_II_WITH_PARMETIS:BOOL=ON")
list(APPEND dealii_cmake_args "-D PARMETIS_DIR=${PARMETIS_DIR}")
