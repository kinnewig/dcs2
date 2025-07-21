include(ExternalProject)

find_package(HDF5)
if(NOT HDF5_FOUND)
  message(STATUS "Building HDF5")
  
  set(hdf5_cmake_args
    -D CMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}/hdf5/${HDF5_VERSION}
    -D CMAKE_C_COMPILER:PATH=${CMAKE_MPI_C_COMPILER}
    -D CMAKE_C_COMPILER:PATH=${CMAKE_MPI_CXX_COMPILER}
    -D CMAKE_Fortran_COMPILER:PATH=${CMAKE_MPI_Fortran_COMPILER}
    -D CMAKE_BUILD_TYPE:STRING=Release
    ${hdf5_cmake_args}
  )

  # get the download url for hdf5:
  file(READ ${CMAKE_CURRENT_LIST_DIR}/libraries.json json)
  string(JSON hdf5_url GET ${json} hdf5 git)
  string(JSON hdf5_tag GET ${json} hdf5 ${HDF5_VERSION} tag)
  if (NOT hdf5_tag)
    message(FATAL_ERROR "Git tag for HDF5 version ${HDF5_VERSION} not found in ${CMAKE_CURRENT_LIST_DIR}/libraries.json.")
  endif()
  
  # If a custom URL for hdf5 is defined, use it.
  if (DEFINED HDF5_CUSTOM_URL)
    set(hdf5_url ${HDF5_CUSTOM_URL})
    message("Using custom download URL for HDF5: ${HDF5_CUSTOM_URL}")
  endif()
  
  # If a custom tag for hdf5 is defined, use it.
  if (DEFINED HDF5_CUSTOM_TAG)
    set(hdf5_tag ${HDF5_CUSTOM_TAG})
    message("Using custom git tag for HDF5: ${HDF5_CUSTOM_TAG}")
  endif()

  if (DEFINED HDF5_SOURCE_DIR)
    ExternalProject_Add(hdf5
      URL ${HDF5_SOURCE_DIR}
      GIT_SHALLOW true
      CMAKE_ARGS ${hdf5_cmake_args}
      INSTALL_DIR ${CMAKE_INSTALL_PREFIX}/hdf5/${HDF5_VERSION}
      BUILD_BYPRODUCTS ${HDF5_LIBRARIES}
      CONFIGURE_HANDLED_BY_BUILD true
      CMAKE_GENERATOR ${DEFAULT_GENERATOR}
      DEPENDS ${hdf5_dependencies}
    ) 
  else()
    ExternalProject_Add(hdf5
      GIT_REPOSITORY ${hdf5_url}
      GIT_TAG ${hdf5_tag}
      GIT_SHALLOW true
      CMAKE_ARGS ${hdf5_cmake_args}
      INSTALL_DIR ${CMAKE_INSTALL_PREFIX}/hdf5/${HDF5_VERSION}
      BUILD_BYPRODUCTS ${HDF5_LIBRARIES}
      CONFIGURE_HANDLED_BY_BUILD true
      CMAKE_GENERATOR ${DEFAULT_GENERATOR}
      DEPENDS ${hdf5_dependencies}
    )
  endif()
  
  ExternalProject_Get_Property(hdf5 INSTALL_DIR)

  # Populate the path
  set(HDF5_DIR ${INSTALL_DIR})
  list(APPEND CMAKE_PREFIX_PATH "${HDF5_DIR}")

  # Check if lib64 exists, if it does not, create a symlink
  ExternalProject_Add_Step(
    hdf5 hdf5_symlink
    COMMAND bash -c "[ -d  ${HDF5_DIR}/lib64 ] || ln -s ${HDF5_DIR}/lib ${HDF5_DIR}/lib64"
    WORKING_DIRECTORY ${HDF5_DIR}
    DEPENDEES install
  )

  # Dependencies:
  # add HDF5 as dependencie to PETSc
  list(APPEND petsc_dependencies "hdf5")

  # add HDF5 as dependencie to trilinos
  list(APPEND trilinos_dependencies "hdf5")

  # add HDF5 as dependencie to deal.II
  list(APPEND dealii_dependencies "hdf5")
endif()

# add HDF5 to PETSc
list(APPEND petsc_autotool_args "--with-hdf5=true")
list(APPEND petsc_autotool_args "--with-hdf5-dir=${HDF5_DIR}")

# add HDF5 to trilinos
list(APPEND trilinos_cmake_args "-D TPL_ENABLE_HDF5=ON")
list(APPEND trilinos_cmake_args "-D HDF5_LIBRARY_DIRS:PATH=${HDF5_DIR}/lib64")
list(APPEND trilinos_cmake_args "-D HDF5_INCLUDE_DIRS:PATH=${HDF5_DIR}/include")

# Force deal.II to use HDF5
list(APPEND dealii_cmake_args "-D HDF5_DIR:PATH=${HDF5_DIR}")
