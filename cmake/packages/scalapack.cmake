include(ExternalProject)

find_package(SCALAPACK)
if(NOT SCALAPACK_FOUND)
  message(STATUS "Building SCALAPACK")

  set(scalapack_cmake_args
    -D BUILD_SINGLE:BOOL=ON
    -D BUILD_DOUBLE:BOOL=ON
    -D BUILD_COMPLEX:BOOL=${DEALII_WITH_COMPLEX}
    -D BUILD_COMPLEX16:BOOL=${DEALII_WITH_COMPLEX}
    -D BUILD_SHARED_LIBS:BOOL=ON
    -D BUILD_TESTING:BOOL=OFF
    -D CMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}/scalapack/${SCALAPACK_VERSION}
    -D CMAKE_C_COMPILER:PATH=${CMAKE_C_COMPILER}
    -D CMAKE_Fortran_COMPILER:PATH=${CMAKE_Fortran_COMPILER}
    -D CMAKE_BUILD_TYPE:STRING=Release
    -D CMAKE_TLS_VERIFY:BOOL=${CMAKE_TLS_VERIFY}
    ${scalapack_cmake_args}
  )

  if (AMD)
    list(APPEND scalapack_cmake_args -D CMAKE_C_FLAGS="-openmp")
    list(APPEND scalapack_cmake_args -D CMAKE_Fortran_FLAGS="-openmp")
    list(APPEND scalapack_cmake_args -D MPI_Fortran_WORKS:BOOL=ON)
  endif()
  
  if (AMD)
    # update the names:
    if(DEFINED SCALAPACK_CUSTOM_URL)
      set(AMD-SCALAPACK_CUSTOM_URL ${SCALAPACK_CUSTOM_URL})
    endif()
    if(DEFINED SCALAPACK_CUSTOM_TAG)
      set(AMD-SCALAPACK_CUSTOM_TAG ${SCALAPACK_CUSTOM_TAG})
    endif()
    set(amd-scalapack_autotool_args ${scalapack_autotool_args})
    set(amd-scalapack_dependencies ${scalapack_dependencies})
    set(package_name "amd-scalapack")
  else()
    set(package_name "scalapack")
  endif()

  build_cmake_subproject(${package_name})

  if (AMD)
    # update the resulting dir name:
    set(SCALAPACK_DIR ${AMD-SCALAPACK_DIR})
  endif()

  # Dependecies
  if (AMD)
    list(APPEND dealii_dependencies   "amd-scalapack")
    list(APPEND petsc_dependencies    "amd-scalapack")
    list(APPEND trilinos_dependencies "amd-scalapack")
    list(APPEND mumps_dependencies    "amd-scalapack")
  else ()
    list(APPEND dealii_dependencies   "scalapack")
    list(APPEND petsc_dependencies    "scalapack")
    list(APPEND trilinos_dependencies "scalapack")
    list(APPEND mumps_dependencies    "scalapack")
  endif()
endif()
  
# Add scalapack to deal.II
list(APPEND dealii_cmake_args "-D DEAL_II_WITH_SCALAPACK:BOOL=ON")
list(APPEND dealii_cmake_args "-D SCALAPACK_DIR=${SCALAPACK_DIR}")

# Add scalapack as dependecie to PETSc
list(APPEND petsc_autotool_args "--with-scalapack=true")
list(APPEND petsc_autotool_args "--with-scalapack-lib=${SCALAPACK_DIR}/lib64/libscalapack${CMAKE_SHARED_LIBRARY_SUFFIX}")

# Add scalapack to trilinos
list(APPEND trilinos_cmake_args "-D TPL_ENABLE_SCALAPACK:BOOL=ON")
list(APPEND trilinos_cmake_args "-D SCALAPACK_LIBRARY_NAMES='scalapack'")
list(APPEND trilinos_cmake_args "-D SCALAPACK_LIBRARY_DIRS:PATH=${SCALAPACK_DIR}/lib;${SCALAPACK_DIR}/lib64")
list(APPEND trilinos_cmake_args "-D Amesos_ENABLE_SCALAPACK:BOOL=ON")

# Add scalapack to mumps
list(APPEND mumps_cmake_args -D SCALAPACK_ROOT=${SCALAPACK_DIR})
