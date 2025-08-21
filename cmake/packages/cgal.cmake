include(ExternalProject)

find_package(CGAL)
if(NOT CGAL_FOUND)
  message(STATUS "Building CGAL")
  
  build_cmake_subproject("cgal")

  # Dependencies:
  list(APPEND dealii_dependencies "cgal")
endif()


# Add CGAL to deal.II
list(APPEND dealii_cmake_args "DEAL_II_WITH_CGAL:BOOL=ON")
list(APPEND dealii_cmake_args "-D CGAL_DIR:PATH=${CGAL_DIR}")
