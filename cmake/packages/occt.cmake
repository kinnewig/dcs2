include(ExternalProject)

find_package(OCCT)
if(OCCT_FOUND)


else()
  message(STATUS "Building OCCT")
  
  set(occt_cmake_args
    -D OCE_TESTING=OFF
    -D OCE_VISUALISATION=OFF
    -D OCE_DISABLE_X11=ON
    ${occt_cmake_args}
  )

  build_cmake_subproject("occt")
  
  # Dependencies:
  list(APPEND gmsh_dependencies "occt")
  list(APPEND petsc_dependencies "occt")
  list(APPEND dealii_dependencies "occt")
endif()

# add OCCT to GMSH
list(APPEND gmsh_cmake_args "-D ENABLE_OCC:BOOL=ON")
list(APPEND gmsh_cmake_args "-D OPENCASCADE_ROOT:PATH=${OCCT_DIR}")

# add OCCT to PETSc
# TODO: This leads to an linking issue (petsc does not find tk)
#list(APPEND petsc_autotool_args "--with-opencascade=true")
#list(APPEND petsc_autotool_args "--with-opencascade-dir=${OCCT_DIR}")

# add OCCT to deal.II
list(APPEND dealii_cmake_args "-D OPENCASCADE_DIR=${OCCT_DIR}")
