include(ExternalProject)

find_package(TRILINOS)
if(TRILINOS_FOUND)

else()
  message(STATUS "Build TRILINOS")

  set(trilinos_cmake_args
    -D CMAKE_C_FLAGS="${CMAKE_C_FLAGS}-Wno-error=implicit-function-declaration"
    -D CMAKE_CXX_FLAGS="${CMAKE_CXX_FLAGS}-Wno-error=implicit-function-declaration"
    -D CMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}/trilinos/${TRILINOS_VERSION}
    -D CMAKE_POSITION_INDEPENDENT_CODE:BOOL=ON 
    -D CMAKE_VERBOSE_MAKEFILE:BOOL=OFF 
    -D TPL_ENABLE_Boost:BOOL=ON 
    -D TPL_ENABLE_MPI:BOOL=ON 
    -D TPL_ENABLE_BLAS:BOOL=ON 
    -D Trilinos_VERBOSE_CONFIGURE:BOOL=OFF 
    -D Trilinos_ENABLE_EXPLICIT_INSTANTIATION:BOOL=ON 
    -D Trilinos_ENABLE_ALL_PACKAGES:BOOL=OFF 
    -D Trilinos_ENABLE_ALL_OPTIONAL_PACKAGES:BOOL=OFF 
    -D Trilinos_ENABLE_Amesos:BOOL=ON 
    -D Trilinos_ENABLE_Amesos2:BOOL=ON 
    -D Trilinos_ENABLE_AztecOO:BOOL=ON 
    -D Trilinos_ENABLE_Belos:BOOL=ON 
    -D Trilinos_ENABLE_Epetra:BOOL=ON 
    -D Trilinos_ENABLE_EpetraExt:BOOL=ON 
    -D Trilinos_ENABLE_Fortran:BOOL=ON 
    -D Trilinos_ENABLE_Ifpack:BOOL=ON  
    -D Trilinos_ENABLE_Ifpack2:BOOL=ON 
    -D Trilinos_ENABLE_ML:BOOL=ON 
    -D Trilinos_ENABLE_MueLu:BOOL=ON 
    -D Trilinos_ENABLE_OpenMP:BOOL=ON
    -D Trilinos_ENABLE_Sacado:BOOL=ON 
    -D Trilinos_ENABLE_Sacado:BOOL=ON 
    -D Trilinos_ENABLE_ShyLU_DD:BOOL=ON 
    -D   ShyLU_DD_ENABLE_TESTS:BOOL=OFF 
    -D Trilinos_ENABLE_Stratimikos:BOOL=ON 
    -D Trilinos_ENABLE_Thyra:BOOL=ON 
    -D Trilinos_ENABLE_Tpetra:BOOL=ON 
    -D   Tpetra_ENABLE_DEPRECATED_CODE:BOOL=ON 
    -D Trilinos_ENABLE_ROL:BOOL=ON 
    -D Trilinos_ENABLE_Xpetra:BOOL=ON 
    -D   Xpetra_ENABLE_DEPRECATED_CODE:BOOL=ON 
    -D Trilinos_ENABLE_Zoltan:BOOL=ON 
    -D Kokkos_ENABLE_SERIAL:BOOL=ON 
    -D Kokkos_ENABLE_OPENMP:BOOL=ON
    -D Kokkos_ENABLE_TESTS:BOOL=OFF
    ${trilinos_cmake_args}
  )

  # TODO: The Epetra-stack is deprecated.
  # At the moment deal.II requires Epetra. So for the moment, we disable the warnings.
  list(APPEND trilinos_cmake_args "-D Trilinos_SHOW_DEPRECATED_WARNINGS:BOOL=OFF")

  # Trilinos index
  if(${DEALII_WITH_64BIT})
    list(APPEND trilinos_cmake_args "-D Tpetra_INST_INT_LONG_LONG:BOOL=ON")

    # TODO: ML and METIS/ParMETIS 64-bit do not play nicely together. 
    # As ML is deprecated and will be removed in the next Trilinos version no patch can be expected.
    list(APPEND trilinos_cmake_args "-D ML_ENABLE_METIS:BOOL=OFF")
    list(APPEND trilinos_cmake_args "-D ML_ENABLE_ParMETIS:BOOL=OFF")
  else()
    list(APPEND trilinos_cmake_args "-D TPETRA_INST_INT_INT:BOOL=ON")
  endif()
  
  # Complex number support
  if ( DEALII_WITH_COMPLEX )
    list(APPEND trilinos_cmake_args "-D Trilinos_ENABLE_COMPLEX_DOUBLE:BOOL=ON")
    list(APPEND trilinos_cmake_args "-D Trilinos_ENABLE_COMPLEX_FLOAT:BOOL=ON")
    list(APPEND trilinos_cmake_args "-D Teuchos_ENABLE_COMPLEX:BOOL=ON")
  endif()
 
  build_cmake_subproject("trilinos")

  # Fix
  if(${DEALII_WITH_64BIT} AND TPL_ENABLE_SUPERLU_DIST)
  ExternalProject_Add_Step(
    trilinos trilinos_superlu_dist_64bit
    COMMAND sed -i "s/pdgsequ(A, r, c, rowcnd, colcnd, amax, info, grid)/pdgsequ(A, r, c, rowcnd, colcnd, amax, (int*)info, grid)/g" packages/amesos2/src/Amesos2_Superludist_FunctionMap.hpp
    COMMAND sed -i "s/dgsequ_dist(A, r, c, rowcnd, colcnd, amax, info)/dgsequ_dist(A, r, c, rowcnd, colcnd, amax, (int*)info)/g" packages/amesos2/src/Amesos2_Superludist_FunctionMap.hpp
    COMMAND sed -i "s/\\&Aval_\\[0\\], \\&Ai_\\[0\\], \\&Ap_\\[0\\]/\\&Aval_\\[0\\], (long int*)\\&Ai_\\[0\\], (long int*)\\&Ap_\\[0\\]/g" packages/amesos/src/Amesos_Superludist.cpp
    COMMAND sed -i "s/PrivateSuperluData_->ScalePermstruct_.perm_c = perm_c_/PrivateSuperluData_->ScalePermstruct_.perm_c = (long int*)perm_c_/g" packages/amesos/src/Amesos_Superludist.cpp
    COMMAND sed -i "s/PrivateSuperluData_->ScalePermstruct_.perm_r = perm_r_/PrivateSuperluData_->ScalePermstruct_.perm_r = (long int*)perm_r_/g" packages/amesos/src/Amesos_Superludist.cpp
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/trilinos-prefix/src/trilinos
    DEPENDEES configure
    DEPENDERS build
  )
  endif()

  # Dependencies:
  list(APPEND dealii_dependencies "trilinos")
  list(APPEND arborx_dependencies "trilinos")
endif()

# Add trilinos to arborx
list(APPEND arborx_cmake_args "-D Kokkos_ROOT:PATH=${TRILINOS_DIR}")

# Add trilinos to deal.II
list(APPEND dealii_cmake_args "-D DEAL_II_WITH_TRILINOS:BOOL=ON")
list(APPEND dealii_cmake_args "-D TRILINOS_DIR=${TRILINOS_DIR}")
