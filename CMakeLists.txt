cmake_minimum_required(VERSION 3.10)

cmake_policy(SET CMP0167 NEW)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/cmake/modules")
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/cmake/find")

include(build_cmake_subproject)
include(build_autotools_subproject)

project(dcs)

# We do not allow in place builds:
if(CMAKE_SOURCE_DIR STREQUAL CMAKE_BINARY_DIR)
  message(FATAL_ERROR "Please use out of source build like:
  cmake -B build")
endif()

# Add the Find<PACKAGE>.cmake files from dcs to CMAKE_MODULE_PATH
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

# Options
option(TPL_ENABLE_ADOLC       "Enable or disable the use of ADOL-C as a third-party library"      OFF)
set(ADOLC_VERSION "2.7.2" CACHE STRING "Specify the version of ADOLC to be used")

option(TPL_ENABLE_ARPACK-NG   "Enable or disable the use of ADOL-C as a third-party library"      OFF)
set(ARPACK-NG_VERSION "3.9.1" CACHE STRING "Specify the version of ADOLC to be used")

option(TPL_ENABLE_ASSIMP   "Enable or disable the use of Assimp as a third-party library"         ON)
set(ASSIMP_VERSION "6.0.2" CACHE STRING "Specify the version of ASSIMP to be used")

option(TPL_ENABLE_BOOST       "Enable or disable the use of BOOST as a third-party library"       ON)
set(BOOST_VERSION "1.88.0" CACHE STRING "Specify the version of BOOST to be used")

option(TPL_ENABLE_BLIS        "Enable or disable the use of BLIS as a third-party library"        ON)
set(BLIS_VERSION "2.0.0" CACHE STRING "Specify the version of BLIS to be used")

option(TPL_ENABLE_GINKGO   "Enable or disable the use of ginkgo as a third-party library"         OFF)
set(GINKGO_VERSION "1.10.0" CACHE STRING "Specify the version of GINKGO to be used")

option(TPL_ENABLE_GSL   "Enable or disable the use of GSL as a third-party library"               OFF)
set(GSL_VERSION "2.8" CACHE STRING "Specify the version of GSL to be used")

option(TPL_ENABLE_HDF5        "Enable or disable the use of HDF5 as a third-party library"        ON)
set(HDF5_VERSION "1.14.6" CACHE STRING "Specify the version of HDF5 to be used")

option(TPL_ENABLE_HYPRE        "Enable or disable the use of hypre as a third-party library"      OFF)
set(HYPRE_VERSION "2.33.0" CACHE STRING "Specify the version of HYPRE to be used")

option(TPL_ENABLE_LIBFLAME    "Enable or disable the use of LIBFLAME as a third-party library"    ON)
set(LIBFLAME_VERSION "master" CACHE STRING "Specify the version of LIBFLAME to be used")

option(TPL_ENABLE_SCALAPACK   "Enable or disable the use of SCALAPACK as a third-party library"   ON)
set(SCALAPACK_VERSION "2.2.2.1" CACHE STRING "Specify the version of SCALAPACK to be used")

option(TPL_ENABLE_MUMPS       "Enable or disable the use of MUMPS as a third-party library"       ON)
set(MUMPS_VERSION "5.8.0.3" CACHE STRING "Specify the version of MUMPS to be used")

option(TPL_ENABLE_NUMDIFF       "Enable or disable the use of NUMDIFF as a third-party library"   ON)
set(NUMDIFF_VERSION "5.9.0" CACHE STRING "Specify the version of NUMDIFF to be used")

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
set(PETSC_VERSION "3.23.2" CACHE STRING "Specify the version of PETSC to be used")

option(TPL_ENABLE_SLEPC       "Enable or disable the use of SLEPc as a third-party library"       ON)
set(SLEPC_VERSION "3.23.2" CACHE STRING "Specify the version of SLEPC to be used")

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



# AMD - AOCL
if (AMD)
  set(AMD-BLIS_VERSION "5.1" CACHE STRING "Specify the version of BLIS to be used")
  set(AMD-LIBFLAME_VERSION "5.1" CACHE STRING "Specify the version of LIBFLAME to be used")
  set(AMD-AOCL-UTILS_VERSION "5.1" CACHE STRING "Specify the version of AOCL-UTILS to be used")

  list(APPEND TPLS_TO_INCLUDE "${CMAKE_SOURCE_DIR}/cmake/packages/aocl-utils.cmake")
else()
  option(TPL_ENABLE_AMD-SCALAPACK "Enable or disable the use of TK as a third-party library" OFF)
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

# First identify MPI, as MPI is required.
find_package(MPI REQUIRED)

# Dependencies:
if(TPL_ENABLE_ADOLC)
  list(APPEND TPLS_TO_INCLUDE "${CMAKE_SOURCE_DIR}/cmake/packages/adolc.cmake")
endif()

if(TPL_ENABLE_ARPACK-NG)
  list(APPEND TPLS_TO_INCLUDE "${CMAKE_SOURCE_DIR}/cmake/packages/arpack-ng.cmake")
endif()

if(TPL_ENABLE_ASSIMP)
  list(APPEND TPLS_TO_INCLUDE "${CMAKE_SOURCE_DIR}/cmake/packages/assimp.cmake")
endif()

list(APPEND TPLS_TO_INCLUDE "${CMAKE_SOURCE_DIR}/cmake/packages/boost.cmake")

if(TPL_ENABLE_BLIS)
  list(APPEND TPLS_TO_INCLUDE "${CMAKE_SOURCE_DIR}/cmake/packages/blis.cmake")
endif()

if(TPL_ENABLE_GINKGO)
  list(APPEND TPLS_TO_INCLUDE "${CMAKE_SOURCE_DIR}/cmake/packages/ginkgo.cmake")
endif()

if(TPL_ENABLE_GMP)
  list(APPEND TPLS_TO_INCLUDE "${CMAKE_SOURCE_DIR}/cmake/packages/gmp.cmake")
endif()

if(TPL_ENABLE_GMSH)
  list(APPEND TPLS_TO_INCLUDE "${CMAKE_SOURCE_DIR}/cmake/packages/gmsh.cmake")
endif()

if(TPL_ENABLE_GSL)
  list(APPEND TPLS_TO_INCLUDE "${CMAKE_SOURCE_DIR}/cmake/packages/gsl.cmake")
endif()

if(TPL_ENABLE_HDF5)
  list(APPEND TPLS_TO_INCLUDE "${CMAKE_SOURCE_DIR}/cmake/packages/hdf5.cmake")
endif()

if(TPL_ENABLE_HYPRE)
  list(APPEND TPLS_TO_INCLUDE "${CMAKE_SOURCE_DIR}/cmake/packages/hypre.cmake")
endif()

if(TPL_ENABLE_LIBFLAME)
  list(APPEND TPLS_TO_INCLUDE "${CMAKE_SOURCE_DIR}/cmake/packages/libflame.cmake")
endif()

if(TPL_ENABLE_MPFR)
  list(APPEND TPLS_TO_INCLUDE "${CMAKE_SOURCE_DIR}/cmake/packages/mpfr.cmake")
endif()

if(TPL_ENABLE_MUMPS)
  list(APPEND TPLS_TO_INCLUDE "${CMAKE_SOURCE_DIR}/cmake/packages/mumps.cmake")
endif()

if(TPL_ENABLE_NUMDIFF)
  list(APPEND TPLS_TO_INCLUDE "${CMAKE_SOURCE_DIR}/cmake/packages/numdiff.cmake")
endif()

if(TPL_ENABLE_OCCT)
  if(NOT TPL_ENABLE_TBB)
    message(STATUS "Building OpenCascade set TPL_ENABLE_TBB to TRUE")
    set(TPL_ENABLE_TBB "ON")
    list(APPEND TPLS_TO_INCLUDE "${CMAKE_SOURCE_DIR}/cmake/packages/tbb.cmake")
  endif()
  if(NOT TPL_ENABLE_TCL)
    message(STATUS "Building OpenCascade set TPL_ENABLE_TCL to TRUE")
    set(TPL_ENABLE_TCL "ON")
    list(APPEND TPLS_TO_INCLUDE "${CMAKE_SOURCE_DIR}/cmake/packages/tcl.cmake")
  endif()
  if(NOT TPL_ENABLE_TK)
    message(STATUS "Building OpenCascade set TPL_ENABLE_TK to TRUE")
    set(TPL_ENABLE_TK  "ON")
    list(APPEND TPLS_TO_INCLUDE "${CMAKE_SOURCE_DIR}/cmake/packages/tk.cmake")
  endif()
  list(APPEND TPLS_TO_INCLUDE "${CMAKE_SOURCE_DIR}/cmake/packages/occt.cmake")
endif()

if(TPL_ENABLE_P4EST)
  list(APPEND TPLS_TO_INCLUDE "${CMAKE_SOURCE_DIR}/cmake/packages/p4est.cmake")
endif()

if(TPL_ENABLE_PETSC)
  list(APPEND TPLS_TO_INCLUDE "${CMAKE_SOURCE_DIR}/cmake/packages/petsc.cmake")
  if(NOT TPL_ENABLE_HYPRE)
    message(STATUS "Building PERSC set TPL_ENABLE_HYPRE to TRUE")
    set(TPL_ENABLE_HYPRE  "ON")
  endif()
endif()

if(TPL_ENABLE_SCALAPACK)
  list(APPEND TPLS_TO_INCLUDE "${CMAKE_SOURCE_DIR}/cmake/packages/scalapack.cmake")
endif()

if(TPL_ENABLE_SLEPC)
  list(APPEND TPLS_TO_INCLUDE "${CMAKE_SOURCE_DIR}/cmake/packages/slepc.cmake")
  if(NOT TPL_ENABLE_PETSC)
    message(STATUS "SLEPc requires PETSc; therefore TPL_ENABLE_TCL is set to TRUE")
    set(TPL_ENABLE_PETSC "ON")
    list(APPEND TPLS_TO_INCLUDE "${CMAKE_SOURCE_DIR}/cmake/packages/petsc.cmake")
  endif()
endif()

if(TPL_ENABLE_SUITESPARSE)
  if(NOT TPL_ENABLE_GMP)
    message(STATUS "Building SuiteSparse set TPL_ENABLE_GMP to TRUE")
    set(TPL_ENABLE_GMP  "ON")
    list(APPEND TPLS_TO_INCLUDE "${CMAKE_SOURCE_DIR}/cmake/packages/gmp.cmake")
  endif()
  if(NOT TPL_ENABLE_MPFR)
    message(STATUS "Building SuiteSparse set TPL_ENABLE_MPFR to TRUE")
    set(TPL_ENABLE_MPFR "ON")
    list(APPEND TPLS_TO_INCLUDE "${CMAKE_SOURCE_DIR}/cmake/packages/mpfr.cmake")
  endif()
  list(APPEND TPLS_TO_INCLUDE "${CMAKE_SOURCE_DIR}/cmake/packages/suitesparse.cmake")
endif()

if(TPL_ENABLE_TBB)
  list(APPEND TPLS_TO_INCLUDE "${CMAKE_SOURCE_DIR}/cmake/packages/tbb.cmake")
endif()

if(TPL_ENABLE_TCL)
  list(APPEND TPLS_TO_INCLUDE "${CMAKE_SOURCE_DIR}/cmake/packages/tcl.cmake")
endif()

if(TPL_ENABLE_TK)
  list(APPEND TPLS_TO_INCLUDE "${CMAKE_SOURCE_DIR}/cmake/packages/tk.cmake")
endif()

if(TPL_ENABLE_TRILINOS)
  list(APPEND TPLS_TO_INCLUDE "${CMAKE_SOURCE_DIR}/cmake/packages/trilinos.cmake")
endif()

if(TPL_ENABLE_VTK)
  list(APPEND TPLS_TO_INCLUDE "${CMAKE_SOURCE_DIR}/cmake/packages/vtk.cmake")
endif()


execute_process(
  COMMAND python3 ${CMAKE_SOURCE_DIR}/scripts/resolve_dependencies.py ${TPLS_TO_INCLUDE}
  OUTPUT_VARIABLE sorted_packages_raw
  OUTPUT_STRIP_TRAILING_WHITESPACE
)

# Convert back to CMake list
string(REPLACE ";" ";" sorted_packages "${sorted_packages_raw}")

# Include in sorted order
foreach(pkg ${sorted_packages})
  include("${CMAKE_SOURCE_DIR}/cmake/packages/${pkg}.cmake")
endforeach()

# Finally deal.II itself!
include(${CMAKE_SOURCE_DIR}/cmake/packages/dealii.cmake)
