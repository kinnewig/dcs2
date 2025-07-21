cmake_minimum_required(VERSION 3.10)
project(dcs)

# We do not allow in place builds:
if(CMAKE_SOURCE_DIR STREQUAL CMAKE_BINARY_DIR)
  message(FATAL_ERROR "Please use out of source build like:
  cmake -B build")
endif()

# Add the Find<PACKAGE>.cmake files from dcs to CMAKE_MODULE_PATH
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

# Options
option(TPL_ENABLE_BOOST       "Enable or disable the use of BOOST as a third-party library"       ON)
set(BOOST_VERSION "1.88.0" CACHE STRING "Specify the version of BOOST to be used")

option(TPL_ENABLE_BLIS        "Enable or disable the use of BLIS as a third-party library"        ON)
set(BLIS_VERSION "2.0.0" CACHE STRING "Specify the version of BLIS to be used")

option(TPL_ENABLE_LIBFLAME    "Enable or disable the use of LIBFLAME as a third-party library"    ON)
set(LIBFLAME_VERSION "master" CACHE STRING "Specify the version of LIBFLAME to be used")

option(TPL_ENABLE_SCALAPACK   "Enable or disable the use of SCALAPACK as a third-party library"   ON)
set(SCALAPACK_VERSION "2.2.2.1" CACHE STRING "Specify the version of SCALAPACK to be used")

option(TPL_ENABLE_MUMPS       "Enable or disable the use of MUMPS as a third-party library"       ON)
set(MUMPS_VERSION "5.8.0.3" CACHE STRING "Specify the version of MUMPS to be used")

option(TPL_ENABLE_GMP         "Enable or disable the use of GMP as a third-party library"         ON)
set(GMP_VERSION "6.2.1" CACHE STRING "Specify the version of GMP to be used")

option(TPL_ENABLE_MPFR        "Enable or disable the use of MMPFR as a third-party library"       ON)
set(MPFR_VERSION "4.2.2" CACHE STRING "Specify the version of MPFR to be used")

option(TPL_ENABLE_SUITESPARSE "Enable or disable the use of SuiteSparse as a third-party library" ON)
set(SUITESPARSE_VERSION "7.10.3" CACHE STRING "Specify the version of SuiteSparse to be used")

option(TPL_ENABLE_P4EST       "Enable or disable the use of P4EST as a third-party library"       ON)
set(P4EST_VERSION "2.8.7" CACHE STRING "Specify the version of P4EST to be used")
set(LIBSC_VERSION "2.8.7" CACHE STRING "Specify the version of LIBSC to be used")

option(TPL_ENABLE_PETSC       "Enable or disable the use of PETSc as a third-party library"       ON)
set(PETSC_VERSION "3.23.4" CACHE STRING "Specify the version of PETSC to be used")

option(TPL_ENABLE_SLEPSC       "Enable or disable the use of SLEPSc as a third-party library"       ON)
set(SLEPSC_VERSION "3.23.2" CACHE STRING "Specify the version of SLEPSC to be used")

option(TPL_ENABLE_TRILINOS    "Enable or disable the use of Trilinos as a third-party library"    ON)
set(TRILINOS_VERSION "16.1.0" CACHE STRING "Specify the version of Trilinos to be used")

option(TPL_ENABLE_TBB       "Enable or disable the use of oneTBB as a third-party library"        ON)
set(TBB_VERSION "2021.13.0" CACHE STRING "Specify the version of TBB to be used")

option(TPL_ENABLE_GMSH       "Enable or disable the use of GMSH as a third-party library"         OFF)
set(GMSH_VERSION "4.14.0" CACHE STRING "Specify the version of GMSH to be used")

option(TPL_ENABLE_VTK        "Enable or disable the use of VTK as a third-party library"          OFF)
set(VTK_VERSION "9.5.0" CACHE STRING "Specify the version of VTK to be used")

option(TPL_ENABLE_OCCT       "Enable or disable the use of OpenCascade as a third-party library"  OFF)
set(OCCT_VERSION "7.9.1" CACHE STRING "Specify the version of OCCT to be used")

option(TPL_ENABLE_TCL        "Enable or disable the use of TCL as a third-party library"          OFF)
set(TCL_VERSION "8.6.15" CACHE STRING "Specify the version of TCL to be used")

option(TPL_ENABLE_TK        "Enable or disable the use of TK as a third-party library"            OFF)
set(TK_VERSION "8.6.15" CACHE STRING "Specify the version of TK to be used")

set(DEALII_VERSION "9.6.2" CACHE STRING "Specify the version of DEALII to be used")
option(DEALII_WITH_64BIT      "Build deal.II with support for complex numbers"                    ON)
option(DEALII_WITH_COMPLEX    "Build deal.II with support for 64bit long numbers"                 OFF)

#Compiler
set(CMAKE_Fortran_COMPILER "mpifort")
set(CMAKE_C_COMPILER "mpicc")
set(CMAKE_CXX_COMPILER "mpicxx")

set(CMAKE_MPI_Fortran_COMPILER "mpifort")
set(CMAKE_MPI_C_COMPILER "mpicc")
set(CMAKE_MPI_CXX_COMPILER "mpicxx")


# AMD - AOCL
set(AMD_BLIS_VERSION "5.1" CACHE STRING "Specify the version of BLIS to be used")
set(AMD_LIBFLAME_VERSION "5.1" CACHE STRING "Specify the version of LIBFLAME to be used")
set(AMD_AOCL-UTILS_VERSION "5.1" CACHE STRING "Specify the version of AOCL-UTILS to be used")

if (AMD)
  include(cmake/aocl-utils.cmake)

  set(CMAKE_Fortran_COMPILER "flang")
  set(CMAKE_C_COMPILER "clang")
  set(CMAKE_CXX_COMPILER "clang++")
endif()



# Build Tool: Ninja
# Check if Ninja is installed
find_program(NINJA ninja)
if(NINJA)
  set(DEFAULT_GENERATOR "Ninja")
endif()

# Linker: mold
# Check if mold is installed
find_program(MOLD mold)
if(MOLD)
  set(CMAKE_LINKER ${MOLD_FOUND})
endif()

# Dependencies:
include(cmake/boost.cmake)

if(TPL_ENABLE_GMP)
  include(cmake/gmp.cmake)
endif()

if(TPL_ENABLE_MPFR)
  include(cmake/mpfr.cmake)
endif()

if(TPL_ENABLE_TCL)
  include(cmake/tcl.cmake)
endif()

if(TPL_ENABLE_TK)
  include(cmake/tk.cmake)
endif()

# Main TPL's
if(TPL_ENABLE_BLIS)
  include(cmake/blis.cmake)
endif()

if(TPL_ENABLE_LIBFLAME)
  include(cmake/libflame.cmake)
endif()

if(TPL_ENABLE_SCALAPACK)
  include(cmake/scalapack.cmake)
endif()

if(TPL_ENABLE_MUMPS)
  include(cmake/mumps.cmake)
endif()

if(TPL_ENABLE_SUITESPARSE)
  if(NOT TPL_ENABLE_GMP)
    message(STATUS "Building SuiteSparse set TPL_ENABLE_GMP to TRUE")
    set(TPL_ENABLE_GMP  "ON")
    include(cmake/gmp.cmake)
  endif()
  if(NOT TPL_ENABLE_MPFR)
    message(STATUS "Building SuiteSparse set TPL_ENABLE_MPFR to TRUE")
    set(TPL_ENABLE_MPFR "ON")
    include(cmake/mpfr.cmake)
  endif()
  include(cmake/suitesparse.cmake)
endif()

if(TPL_ENABLE_TRILINOS)
  include(cmake/trilinos.cmake)
endif()

if(TPL_ENABLE_PETSC)
  include(cmake/petsc.cmake)
endif()

if(TPL_ENABLE_SLEPSC)
  include(cmake/petsc.cmake)
  if(NOT TPL_ENABLE_PETSC)
    message(STATUS "SLEPSc requires PETSc; therefore TPL_ENABLE_TCL is set to TRUE")
    set(TPL_ENABLE_PETSC "ON")
    include(cmake/petsc.cmake)
  endif()
endif()

if(TPL_ENABLE_P4EST)
  include(cmake/p4est.cmake)
endif()

if(TPL_ENABLE_GMSH)
  include(cmake/gmsh.cmake)
endif()

if(TPL_ENABLE_TBB)
  include(cmake/tbb.cmake)
endif()

if(TPL_ENABLE_VTK)
  include(cmake/vtk.cmake)
endif()

if(TPL_ENABLE_OCCT)
  if(NOT TPL_ENABLE_TBB)
    message(STATUS "Building OpenCascade set TPL_ENABLE_TBB to TRUE")
    set(TPL_ENABLE_TBB "ON")
    include(cmake/tbb.cmake)
  endif()
  if(NOT TPL_ENABLE_TCL)
    message(STATUS "Building OpenCascade set TPL_ENABLE_TCL to TRUE")
    set(TPL_ENABLE_TCL "ON")
    include(cmake/tcl.cmake)
  endif()
  if(NOT TPL_ENABLE_TK)
    message(STATUS "Building OpenCascade set TPL_ENABLE_TK to TRUE")
    set(TPL_ENABLE_TK  "ON")
    include(cmake/tk.cmake)
  endif()
  include(cmake/occt.cmake)
endif()




include(cmake/dealii.cmake)
