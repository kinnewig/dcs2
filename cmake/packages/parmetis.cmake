include(ExternalProject)

find_package(PARMETIS)

if(NOT PARMETIS_FOUND)
  message(STATUS "Building PARMETIS")
  
  # The toolchain of METIS/ParMETIS is... special...

  file(READ ${CMAKE_CURRENT_LIST_DIR}/../libraries.json json)

  string(JSON parmetis_url GET ${json} parmetis git)
  string(JSON parmetis_tag GET ${json} parmetis ${PARMETIS_VERSION})

  # build ParMETIS
  ExternalProject_Add(parmetis
    URL ${parmetis_url}/${parmetis_tag}
    CONFIGURE_COMMAND make config prefix=${CMAKE_INSTALL_PREFIX}/parmetis/${PARMETIS_VERSION} shared=1 cc=${MPI_C_COMPILER} cxx=${MPI_CXX_COMPILER}
    BUILD_COMMAND cmake --build ${CMAKE_BINARY_DIR}/parmetis-prefix/src/parmetis/build/Linux-x86_64
    INSTALL_COMMAND cmake --install ${CMAKE_BINARY_DIR}/parmetis-prefix/src/parmetis/build/Linux-x86_64
    INSTALL_DIR ${CMAKE_INSTALL_PREFIX}/parmetis/${PARMETIS_VERSION}
    BUILD_IN_SOURCE ON
    DOWNLOAD_EXTRACT_TIMESTAMP true
    CMAKE_GENERATOR ${DEFAULT_GENERATOR}
    DEPENDS ${parmetis_dependencies}
  )

  # patch ParMETIS
  ExternalProject_Add_Step(
    parmetis parmetis_patch
    COMMAND sed -i "s/VERSION 2.8/VERSION 3.10/g" CMakeLists.txt
    COMMAND sed -i "/set(ParMETIS_LIBRARY_TYPE SHARED)/a\  set(METIS_LIBRARY_TYPE SHARED)" CMakeLists.txt
    COMMAND sed -i "/set(ParMETIS_LIBRARY_TYPE STATIC)/a\  set(METIS_LIBRARY_TYPE STATIC)" CMakeLists.txt
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/parmetis-prefix/src/parmetis
    DEPENDEES download
    DEPENDERS update
  )


  # but before we build ParMETIS, we have to build METIS
  ExternalProject_Add_Step(
    parmetis metis
    COMMAND make config prefix=${CMAKE_INSTALL_PREFIX}/parmetis/${PARMETIS_VERSION} shared=1
    COMMAND cmake --build ${CMAKE_BINARY_DIR}/parmetis-prefix/src/parmetis/metis/build/Linux-x86_64
    COMMAND cmake --install ${CMAKE_BINARY_DIR}/parmetis-prefix/src/parmetis/metis/build/Linux-x86_64
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/parmetis-prefix/src/parmetis/metis
    DEPENDEES update
    DEPENDERS build
  )

  # patch METIS
  ExternalProject_Add_Step(
    parmetis metis_patch
    COMMAND sed -i "s/VERSION 2.8/VERSION 3.10/g" CMakeLists.txt
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/parmetis-prefix/src/parmetis/metis
    DEPENDEES download
    DEPENDERS update
  )

  if(${DEALII_WITH_64BIT})
    ExternalProject_Add_Step(
      parmetis parmetis_64bit
      COMMAND sed -i "s/#define IDXTYPEWIDTH 32/#define IDXTYPEWIDTH 64/g" metis/include/metis.h
      WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/parmetis-prefix/src/parmetis
      DEPENDEES download
      DEPENDERS update
    )
  endif()

  ExternalProject_Get_Property(parmetis INSTALL_DIR)
  set("PARMETIS_DIR" "${INSTALL_DIR}" CACHE INTERNAL "")

  # Dependencies:
  list(APPEND dealii_dependencies "parmetis")
  list(APPEND trilinos_dependencies "parmetis")
  list(APPEND petsc_dependencies "parmetis")
  list(APPEND superlu_dist_dependencies "parmetis")
endif()

# Add parmetis to deal.II
list(APPEND dealii_cmake_args "-D DEAL_II_WITH_PARMETIS:BOOL=ON")
list(APPEND dealii_cmake_args "-D PARMETIS_DIR=${PARMETIS_DIR}")

# add parmetis to trilinos
list(APPEND trilinos_cmake_args "-D TPL_ENABLE_METIS:BOOL=ON")
list(APPEND trilinos_cmake_args "-D METIS_LIBRARY_DIRS:PATH=${PARMETIS_DIR}/lib")
list(APPEND trilinos_cmake_args "-D METIS_INCLUDE_DIRS:PATH=${PARMETIS_DIR}/include")
list(APPEND trilinos_cmake_args "-D TPL_ENABLE_ParMETIS:BOOL=ON")
list(APPEND trilinos_cmake_args "-D ParMETIS_LIBRARY_DIRS:PATH=${PARMETIS_DIR}/lib")
list(APPEND trilinos_cmake_args "-D ParMETIS_INCLUDE_DIRS:PATH=${PARMETIS_DIR}/include")

# add parmetis to PETSc
list(APPEND petsc_autotool_args "--with-metis=true")
list(APPEND petsc_autotool_args "--with-metis-dir=${PARMETIS_DIR}")
list(APPEND petsc_autotool_args "--with-parmetis=true")
list(APPEND petsc_autotool_args "--with-parmetis-dir=${PARMETIS_DIR}")

# add parmetis to superlu_dist 
list(APPEND superlu_dist_cmake_args "-D TPL_PARMETIS_INCLUDE_DIRS:PATH=${PARMETIS_DIR}/include")
list(APPEND superlu_dist_cmake_args "-D TPL_PARMETIS_LIBRARIES:PATH=${PARMETIS_DIR}/lib/libparmetis.so")
