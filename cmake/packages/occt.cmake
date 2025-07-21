include(ExternalProject)

find_package(OCCT)
if(OCCT_FOUND)


else()
  message(STATUS "Building OCCT")
  
  set(occt_cmake_args
    -D OCE_TESTING=OFF
    -D OCE_VISUALISATION=OFF
    -D OCE_DISABLE_X11=ON
    -D CMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}/occt/${OCCT_VERSION}
    -D CMAKE_C_COMPILER:PATH=${CMAKE_MPI_C_COMPILER}
    -D CMAKE_Fortran_COMPILER:PATH=${CMAKE_MPI_Fortran_COMPILER}
    -D CMAKE_BUILD_TYPE:STRING=Release
    ${occt_cmake_args}
  )

  build_cmake_subproject("occt")
  
  # Dependencies:
  list(APPEND dealii_dependencies "occt")
  list(APPEND petsc_dependencies "occt")
endif()

# Force deal.II to use OCCT
list(APPEND dealii_cmake_args "-D OPENCASCADE_DIR=${OCCT_DIR}")

# add OCCT to PETSc
list(APPEND petsc_autotool_args "--with-opencascade=true")
list(APPEND petsc_autotool_args "--with-opencascade-dir=${OCCT_DIR}")
