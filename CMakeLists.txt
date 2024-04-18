cmake_minimum_required(VERSION 3.10)
project(dcs)

# We do not allow in place builds:
if(CMAKE_SOURCE_DIR STREQUAL CMAKE_BINARY_DIR)
  message(FATAL_ERROR "Please use out of source build like:
  cmake -B build")
endif()

# Add the Find<PACKAGE>.cmake files from dcs to CMAKE_MODULE_PATH
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

#set(BOOST_DIR "/opt/cit/13.2.0-V1/lib64/boost-1.84.0/")

# Options
option(TPL_ENABLE_BLIS        "Enable or disable the use of BLIS as a third-party library"        ON)
set(BLIS_VERSION "0.9.0" CACHE STRING "Specify the version of BLIS to be used")

option(TPL_ENABLE_LIBFLAME    "Enable or disable the use of LIBFLAME as a third-party library"    ON)
set(LIBFLAME_VERSION "5.2.0" CACHE STRING "Specify the version of BLIS to be used")

option(TPL_ENABLE_SCALAPACK   "Enable or disable the use of ScaLAPACK as a third-party library"   ON)
set(SCALAPACK_VERSION "2.2.1" CACHE STRING "Specify the version of ScaLAPACK to be used")

option(TPL_ENABLE_MUMPS       "Enable or disable the use of MUMPS as a third-party library"       ON)
set(MUMPS_VERSION "5.6.2" CACHE STRING "Specify the version of MUMPS to be used")

option(TPL_ENABLE_GMP         "Enable or disable the use of GMP as a third-party library"         ON)
set(GMP_VERSION "6.2.1" CACHE STRING "Specify the version of GMP to be used")

option(TPL_ENABLE_MPFR        "Enable or disable the use of MMPFR as a third-party library"       ON)
set(MPFR_VERSION "4.2.1" CACHE STRING "Specify the version of MPFR to be used")

option(TPL_ENABLE_SUITESPARSE "Enable or disable the use of SuiteSparse as a third-party library" ON)
set(SUITESPARSE_VERSION "7.7.0" CACHE STRING "Specify the version of SuiteSparse to be used")

option(TPL_ENABLE_P4EST       "Enable or disable the use of P4EST as a third-party library"       ON)
set(P4EST_VERSION "2.8.5" CACHE STRING "Specify the version of P4EST to be used")

option(TPL_ENABLE_TRILINOS    "Enable or disable the use of Trilinos as a third-party library"    ON)
set(TRILINOS_VERSION "15.1.0" CACHE STRING "Specify the version of Trilinos to be used")

set(DEALII_VERSION "master" CACHE STRING "Specify the version of deal.II to be used")
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
set(AMD_VERSION "4.2.0" CACHE STRING "Specify the version of AOCL packages to be used")
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



if(TPL_ENABLE_GMP)
  include(cmake/gmp.cmake)
endif()

if(TPL_ENABLE_MPFR)
  include(cmake/mpfr.cmake)
endif()

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
  include(cmake/suitesparse.cmake)
endif()

if(TPL_ENABLE_TRILINOS)
  include(cmake/trilinos.cmake)
endif()

if(TPL_ENABLE_P4EST)
  include(cmake/p4est.cmake)
endif()

include(cmake/dealii.cmake)
