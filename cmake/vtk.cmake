include(ExternalProject)

if(NOT VTK_FOUND)
  message(STATUS "Building VTK")
  
  set(vtk_cmake_args
    -D CMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}/vtk/${VTK_VERSION}
    -D CMAKE_C_COMPILER:PATH=${CMAKE_C_COMPILER}
    -D CMAKE_CXX_COMPILER:PATH=${CMAKE_CXX_COMPILER}
    -D CMAKE_Fortran_COMPILER:PATH=${CMAKE_Fortran_COMPILER}
    -D CMAKE_BUILD_TYPE:STRING=Release
    ${vtk_cmake_args}
  )
  
  # get the download url for VTK:
  file(READ ${CMAKE_CURRENT_LIST_DIR}/libraries.json json)
  string(JSON vtk_url GET ${json} vtk git)
  string(JSON vtk_tag GET ${json} vtk ${VTK_VERSION} tag)
  if (NOT vtk_tag)
    message(FATAL_ERROR "Git tag for VTK version ${VTK_VERSION} not found in ${CMAKE_CURRENT_LIST_DIR}/libraries.json.")
  endif()
  
  # If a custom URL for VTK is defined, use it.
  if (DEFINED VTK_CUSTOM_URL)
    set(vtk_url ${VTK_CUSTOM_URL})
    message("Using custom download URL for VTK: ${VTK_CUSTOM_URL}")
  endif()
  
  # If a custom tag for VTK is defined, use it.
  if (DEFINED VTK_CUSTOM_TAG)
    set(vtk_tag ${VTK_CUSTOM_TAG})
    message("Using custom git tag for VTK: ${VTK_CUSTOM_TAG}")
  endif()
  
  if (DEFINED VTK_SOURCE_DIR)
    ExternalProject_Add(vtk
      URL ${VTK_SOURCE_DIR}
      GIT_SHALLOW true
      CMAKE_ARGS ${vtk_cmake_args}
      INSTALL_DIR ${CMAKE_INSTALL_PREFIX}/vtk/${VTK_VERSION}
      BUILD_BYPRODUCTS ${VTK_LIBRARIES}
      CONFIGURE_HANDLED_BY_BUILD true
      CMAKE_GENERATOR ${DEFAULT_GENERATOR}
      DEPENDS ${vtk_dependencies}
    ) 
  else()
    ExternalProject_Add(vtk
      GIT_REPOSITORY ${vtk_url}
      GIT_TAG ${vtk_tag}
      GIT_SHALLOW true
      CMAKE_ARGS ${vtk_cmake_args}
      INSTALL_DIR ${CMAKE_INSTALL_PREFIX}/vtk/${VTK_VERSION}
      BUILD_BYPRODUCTS ${VTK_LIBRARIES}
      CONFIGURE_HANDLED_BY_BUILD true
      CMAKE_GENERATOR ${DEFAULT_GENERATOR}
      DEPENDS ${vtk_dependencies}
    )
  endif()

  ExternalProject_Get_Property(vtk source_dir)
  ExternalProject_Add_Step(vtk update_submodules
    COMMAND ${GIT_EXECUTABLE} submodule update --init --recursive
    DEPENDEES update
    WORKING_DIRECTORY ${source_dir}
  )
  
  ExternalProject_Get_Property(vtk INSTALL_DIR)
  
  # Populate the path
  set(VTK_DIR ${INSTALL_DIR})
  list(APPEND CMAKE_PREFIX_PATH "${VTK_DIR}")
  
  # Linking
  add_library(VTK::VTK INTERFACE IMPORTED GLOBAL)
  
  set(VTK_LIBRARY "${VTK_DIR}/lib64")
  set(VTK_INCLUDE_DIRS "${VTK_DIR}/include")

  # Dependencies:
  # add VTK as dependencie to OpenCascade
  list(APPEND occt_dependencies "vtk")

  # add VTK as dependencie to deal.II
  list(APPEND dealii_dependencies "vtk")

endif()

# add VTK to OpenCascade
list(APPEND occt_cmake_args "-D 3RDPARTY_VTK_LIBRARY_DIR=${VTK_DIR}/lib;${VTK_DIR}/lib64")

# add VTK to deal.II
list(APPEND dealii_cmake_args "-D VTK_DIR=${VTK_DIR}")
