include(ExternalProject)

find_package(GMSH)
if(NOT GMSH_FOUND)
  message(STATUS "Building GMSH")
  
  set(gmsh_cmake_args
    -D ENABLE_GRAPHICS:BOOL=ON 
    -D ENABLE_MPI:BOOL=ON 
    -D ENABLE_BUILD_LIB:BOOL=ON 
    -D ENABLE_BUILD_SHARED:BOOL=ON 
    -D ENABLE_BUILD_DYNAMIC:BOOL=ON 
    -D ENABLE_FLTK:BOOL=ON
    -D CMAKE_POLICY_VERSION_MINIMUM=3.5
    ${gmsh_cmake_args}
  )
 
  build_cmake_subproject("gmsh")
 
  # Begin extra part for GMSH
  # Work arround, this seems to be necessary...
  ExternalProject_Get_Property(gmsh source_dir)

  ExternalProject_Add_Step(gmsh workarround
    COMMAND sed -i "15i#define _XOPEN_SOURCE" string.c
    WORKING_DIRECTORY ${source_dir}/contrib/metis/GKlib/
    DEPENDEES download
    DEPENDERS configure
  )

  ExternalProject_Add_Step(
    gmsh gmsh_symlink_env
    COMMAND ln -s ${GMSH_DIR}/bin/gmsh ${BIN_DIR}/gmsh
    COMMAND ln -s ${GMSH_DIR}/lib64/libgmsh${CMAKE_SHARED_LIBRARY_SUFFIX} ${LIB64_DIR}/libgmsh${CMAKE_SHARED_LIBRARY_SUFFIX}
    WORKING_DIRECTORY ${GMSH_DIR}
    DEPENDEES install
  )
  # End extra part for GMSH
  
  set(GMP_LIBRARY "${GMSH_DIR}/lib64")
  set(GMP_INCLUDE_DIRS "${GMSH_DIR}/include")

  # Dependencies:
  list(APPEND dealii_dependencies "gmsh")
  list(APPEND petsc_dependencies "gmsh")
endif()

# add GMSH to deal.II
list(APPEND dealii_cmake_args "-D GMSH_DIR=${GMSH_DIR}")

# add GMSH to PETSc
list(APPEND petsc_autotool_args "--with-gmsh=true")
list(APPEND petsc_autotool_args "--with-gmsh-dir=${GMSH_DIR}")
