include(ExternalProject)

find_package(METIS)
if(METIS_FOUND)
  
else()
  message(STATUS "Building METIS")

  list(APPEND metis_autotool_args "prefix=${CMAKE_INSTALL_PREFIX}/metis/${METIS_VERSION}")
  list(APPEND metis_autotool_args "shared=1")

  build_autotools_subproject_with_custom_configure("metis" "make")

  # Dependencies:
  list(APPEND dealii_dependencies "metis")
  list(APPEND trilinos_dependencies "metis")
  list(APPEND petsc_dependencies "metis")
  list(APPEND superlu_dist_dependencies "metis")
endif()

# Add metis to deal.II
list(APPEND dealii_cmake_args "-D DEAL_II_WITH_METIS:BOOL=ON")
list(APPEND dealii_cmake_args "-D METIS_DIR=${METIS_DIR}")
