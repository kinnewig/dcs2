cmake_minimum_required(VERSION 3.10)

if(POLICY CMP0167)
  cmake_policy(SET CMP0167 NEW)
endif()

if(POLICY CMP0074)
  cmake_policy(SET CMP0074 NEW)
endif()

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

option(TPL_ENABLE_ARBORX      "Enable or disable the use of ARBORX as a third-party library"      OFF)
set(ARBORX_VERSION "2.0.1" CACHE STRING "Specify the version of ARBORX to be used")

option(TPL_ENABLE_ARPACK-NG   "Enable or disable the use of ADOL-C as a third-party library"      OFF)
set(ARPACK-NG_VERSION "3.9.1" CACHE STRING "Specify the version of ARPACK-NG to be used")

option(TPL_ENABLE_ASSIMP   "Enable or disable the use of Assimp as a third-party library"         OFF)
set(ASSIMP_VERSION "6.0.2" CACHE STRING "Specify the version of ASSIMP to be used")

option(TPL_ENABLE_BOOST       "Enable or disable the use of BOOST as a third-party library"       ON)
set(BOOST_VERSION "1.89.0" CACHE STRING "Specify the version of BOOST to be used")

option(TPL_ENABLE_CGAL       "Enable or disable the use of CGAL as a third-party library"         OFF)
set(CGAL_VERSION "6.1" CACHE STRING "Specify the version of CGAL to be used")

option(TPL_ENABLE_BLIS        "Enable or disable the use of BLIS as a third-party library"        ON)
set(BLIS_VERSION "2.0" CACHE STRING "Specify the version of BLIS to be used")

option(TPL_ENABLE_FLTK   "Enable or disable the use of FLTK as a third-party library"             OFF)
set(FLTK_VERSION "1.4.4" CACHE STRING "Specify the version of FLTK to be used")

option(TPL_ENABLE_GINKGO   "Enable or disable the use of ginkgo as a third-party library"         OFF)
set(GINKGO_VERSION "1.10.0" CACHE STRING "Specify the version of GINKGO to be used")

option(TPL_ENABLE_GSL   "Enable or disable the use of GSL as a third-party library"               OFF)
set(GSL_VERSION "2.8" CACHE STRING "Specify the version of GSL to be used")

option(TPL_ENABLE_HDF5        "Enable or disable the use of HDF5 as a third-party library"        ON)
set(HDF5_VERSION "1.14.6" CACHE STRING "Specify the version of HDF5 to be used")

option(TPL_ENABLE_HYPRE        "Enable or disable the use of hypre as a third-party library"      OFF)
set(HYPRE_VERSION "3.0.0" CACHE STRING "Specify the version of HYPRE to be used")

option(TPL_ENABLE_LIBFLAME    "Enable or disable the use of LIBFLAME as a third-party library"    ON)
set(LIBFLAME_VERSION "5.2.0" CACHE STRING "Specify the version of LIBFLAME to be used")

option(TPL_ENABLE_SCALAPACK   "Enable or disable the use of SCALAPACK as a third-party library"   ON)
set(SCALAPACK_VERSION "2.2.2.2" CACHE STRING "Specify the version of SCALAPACK to be used")

option(TPL_ENABLE_MUMPS       "Enable or disable the use of MUMPS as a third-party library"       ON)
set(MUMPS_VERSION "5.8.1.0" CACHE STRING "Specify the version of MUMPS to be used")

option(TPL_ENABLE_MUPARSER    "Enable or disable the use of MUMPS as a third-party library"       OFF)
set(MUPARSER_VERSION "2.3.5" CACHE STRING "Specify the version of MUPARSER to be used")

option(TPL_ENABLE_NETCDF   "Enable or disable the use of NETCDF as a third-party library"         OFF)
set(NETCDF_VERSION "4.9.3" CACHE STRING "Specify the version of NETCDF to be used")

option(TPL_ENABLE_NUMDIFF       "Enable or disable the use of NUMDIFF as a third-party library"   ON)
set(NUMDIFF_VERSION "5.9.0" CACHE STRING "Specify the version of NUMDIFF to be used")

option(TPL_ENABLE_GMP         "Enable or disable the use of GMP as a third-party library"         ON)
set(GMP_VERSION "6.2.1" CACHE STRING "Specify the version of GMP to be used")

option(TPL_ENABLE_MPFR        "Enable or disable the use of MPFR as a third-party library"        ON)
set(MPFR_VERSION "4.2.2" CACHE STRING "Specify the version of MPFR to be used")

option(TPL_ENABLE_SUITESPARSE "Enable or disable the use of SuiteSparse as a third-party library" ON)
set(SUITESPARSE_VERSION "7.11.0" CACHE STRING "Specify the version of SUITESPARSE to be used")

option(TPL_ENABLE_SUNDIALS   "Enable or disable the use of SUNDIALS as a third-party library"     OFF)
set(SUNDIALS_VERSION "7.5.0" CACHE STRING "Specify the version of SUNDIALS to be used")

option(TPL_ENABLE_SYMENGINE   "Enable or disable the use of SYMENGINE as a third-party library"   OFF)
set(SYMENGINE_VERSION "0.14.0" CACHE STRING "Specify the version of SYMENGINE to be used")

option(TPL_ENABLE_P4EST       "Enable or disable the use of P4EST as a third-party library"       ON)
set(P4EST_VERSION "2.8.7" CACHE STRING "Specify the version of P4EST to be used")
set(LIBSC_VERSION "2.8.7" CACHE STRING "Specify the version of LIBSC to be used")

option(TPL_ENABLE_PARMETIS       "Enable or disable the use of PARMETIS as a third-party library" ON)
set(PARMETIS_VERSION "4.0.3" CACHE STRING "Specify the version of PARMETIS to be used")

option(TPL_ENABLE_PETSC       "Enable or disable the use of PETSc as a third-party library"       ON)
set(PETSC_VERSION "3.24.0" CACHE STRING "Specify the version of PETSC to be used")

option(TPL_ENABLE_SLEPC       "Enable or disable the use of SLEPc as a third-party library"       ON)
set(SLEPC_VERSION "3.24.0" CACHE STRING "Specify the version of SLEPC to be used")

option(TPL_ENABLE_SUPERLU_DIST "Enable or disable the use of superlu_dist as a third-party library" ON)
set(SUPERLU_DIST_VERSION "9.1.0" CACHE STRING "Specify the version of SUPERLU_DIST to be used")

option(TPL_ENABLE_TRILINOS    "Enable or disable the use of Trilinos as a third-party library"    ON)
set(TRILINOS_VERSION "16.1.0" CACHE STRING "Specify the version of TRILINOS to be used")

option(TPL_ENABLE_TBB       "Enable or disable the use of oneTBB as a third-party library"        ON)
set(TBB_VERSION "2022.2.0" CACHE STRING "Specify the version of TBB to be used")

option(TPL_ENABLE_GMSH       "Enable or disable the use of GMSH as a third-party library"         OFF)
set(GMSH_VERSION "4.14.1" CACHE STRING "Specify the version of GMSH to be used")

option(TPL_ENABLE_VTK        "Enable or disable the use of VTK as a third-party library"          OFF)
set(VTK_VERSION "9.5.2" CACHE STRING "Specify the version of VTK to be used")

option(TPL_ENABLE_OCCT       "Enable or disable the use of OpenCascade as a third-party library"  OFF)
set(OCCT_VERSION "7.9.1" CACHE STRING "Specify the version of OCCT to be used")

option(TPL_ENABLE_TCL        "Enable or disable the use of TCL as a third-party library"          OFF)
set(TCL_VERSION "1.5.0" CACHE STRING "Specify the version of TCL to be used")

option(TPL_ENABLE_TK        "Enable or disable the use of TK as a third-party library"            OFF)
set(TK_VERSION "1.5.0" CACHE STRING "Specify the version of TK to be used")

option(TPL_ENABLE_ZLIB-NG   "Enable or disable the use of ZLIB-NG as a third-party library"       OFF)
set(ZLIB-NG_VERSION "2.2.5" CACHE STRING "Specify the version of ZLIB-NG to be used")

set(DEALII_VERSION "9.7.1" CACHE STRING "Specify the version of DEALII to be used")
option(DEALII_WITH_64BIT      "Build deal.II with support for 64bit long numbers"                 OFF)
option(DEALII_WITH_COMPLEX    "Build deal.II with support for complex numbers"                    OFF)



# Additional path to search pre-installed tools:
list(APPEND SEARCH_DEFAULTS "/usr")
list(APPEND SEARCH_DEFAULTS "/usr/local")
list(APPEND SEARCH_DEFAULTS "/opt")



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



# Set the compilier
set(C_COMPILIER $ENV{CC})
set(CXX_COMPILIER $ENV{CXX})
set(Fortran_COMPILIER $ENV{FC})

# Set the MPI compilier
find_package(MPI REQUIRED)

# Sometimes the MPI fortran compilier is not detected by the find_package MPI module
if(NOT DEFINED MPI_Fortran_COMPILER)
  get_filename_component(MPI_COMPILER_DIR "${MPI_C_COMPILER}" DIRECTORY)
  set(MPI_Fortran_COMPILER "${MPI_COMPILER_DIR}/$ENV{MPI_FC}")
endif()



# Strong dependencies: (must be available:)
# BOOST
list(APPEND TPLS_TO_INCLUDE "${CMAKE_SOURCE_DIR}/cmake/packages/boost.cmake")


# BLAS Stack:
# Capitalize the input
string(TOUPPER "${BLAS_STACK}" BLAS_STACK_UPPER)
set(BLAS_STACK ${BLAS_STACK_UPPER})

# Check if the BLAS STACK is valid
set(VALID_BLAS "AMD" "MKL" "DEFAULT" "FLAME" "SYSTEM")
list(FIND VALID_BLAS "${BLAS_STACK}" INDEX)
if(NOT INDEX EQUAL -1)
  message(STATUS "Build BLAS Stack: ${BLAS_STACK}")
else()
  string(JOIN ", " VALID_BLAS_STRING ${VALID_BLAS})
  message(FATAL_ERROR 
          "Unkown BLAS Stack: ${BLAS_STACK}.\n" 
          "Valid Options are: ${VALID_BLAS_STRING}")
endif()

# Set default
if (NOT DEFINED BLAS_STACK)
  set(BLAS_STACK "DEFAULT")
endif()

# Build the selected BLAS stack
# AMD - AOCL
if("${BLAS_STACK}" STREQUAL "AMD")
  set(AMD-BLIS_VERSION "5.1" CACHE STRING "Specify the version of AMD-BLIS to be used")
  set(AMD-LIBFLAME_VERSION "5.1" CACHE STRING "Specify the version of AMD-LIBFLAME to be used")
  set(AMD-SCALAPACK_VERSION "5.1" CACHE STRING "Specify the version of AMD-SCALAPACK to be used")
  set(AMD-AOCL-UTILS_VERSION "5.1" CACHE STRING "Specify the version of AMD-AOCL-UTILS to be used")
  set(AMD-MUMPS_VERSION "5.1" CACHE STRING "Specify the version of AMD-MUMPS to be used")

  list(APPEND TPLS_TO_INCLUDE "${CMAKE_SOURCE_DIR}/cmake/packages/amd-aocl-utils.cmake")
  list(APPEND TPLS_TO_INCLUDE "${CMAKE_SOURCE_DIR}/cmake/packages/amd-blis.cmake")
  list(APPEND TPLS_TO_INCLUDE "${CMAKE_SOURCE_DIR}/cmake/packages/amd-libflame.cmake")
  list(APPEND TPLS_TO_INCLUDE "${CMAKE_SOURCE_DIR}/cmake/packages/amd-scalapack.cmake")
endif()

# Default - FLAME
if( ("${BLAS_STACK}" STREQUAL "DEFAULT") OR ("${BLAS_STACK}" STREQUAL "FLAME") )
  list(APPEND TPLS_TO_INCLUDE "${CMAKE_SOURCE_DIR}/cmake/packages/blis.cmake")
  list(APPEND TPLS_TO_INCLUDE "${CMAKE_SOURCE_DIR}/cmake/packages/libflame.cmake")
  list(APPEND TPLS_TO_INCLUDE "${CMAKE_SOURCE_DIR}/cmake/packages/scalapack.cmake")
endif()

# Intel - One MKL
if("${BLAS_STACK}" STREQUAL "MKL")
  include(${CMAKE_SOURCE_DIR}/cmake/packages/mkl-blas.cmake) # Includes BLAS, LAPACK and ScaLAPACK
endif()

# System 
if("${BLAS_STACK}" STREQUAL "SYSTEM")
  include(${CMAKE_SOURCE_DIR}/cmake/packages/system-blas.cmake) # Includes BLAS, LAPACK
  list(APPEND TPLS_TO_INCLUDE "${CMAKE_SOURCE_DIR}/cmake/packages/scalapack.cmake")
endif()


# Optional Dependencies:
set(package_list
  "ADOLC"
  "ARBOX"
  "ARPACK-NG"
  "ASSIMP"
  "CGAL"
  "FLTK"
  "GINKGO"
  "GMP"
  "GMSH"
  "GSL"
  "HDF5"
  "HYPRE"
  "MPFR"
  "MUPARSER"
  "NETCDF"
  "NUMDIFF"
  "P4EST"
  "PARMETIS"
  "SUNDIALS"
  "SUPERLU_DIST"
  "SYMENGINE"
  "TBB"
  "TCL"
  "TK"
  "TRILINOS"
  "VTK"
  "ZLIB-NG"
)

foreach(package IN LISTS package_list)
  string(TOLOWER "${package}" package_lower)
  if(TPL_ENABLE_${package})
    list(APPEND TPLS_TO_INCLUDE "${CMAKE_SOURCE_DIR}/cmake/packages/${package_lower}.cmake")
  endif()
endforeach()

# Dependencies, where we need to run some additional checks:
if(TPL_ENABLE_MUMPS)
  if("${BLAS_STACK}" STREQUAL "AMD")
    list(APPEND TPLS_TO_INCLUDE "${CMAKE_SOURCE_DIR}/cmake/packages/amd-mumps.cmake")
  else()
    list(APPEND TPLS_TO_INCLUDE "${CMAKE_SOURCE_DIR}/cmake/packages/mumps.cmake")
  endif()
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

if("${BLAS_STACK}" STREQUAL "AMD")
  message(WARNING 
    "PETSc support has been deactivated.
     PETSc is not compatible with the AMD-BLAS stack. 
     To enable PETSc functionality, please configure 
     your environment with a different BLAS stack
     (e.g., \"--blas_stack system\" or \"--blas_stack mkl\").
    ")
else()
  if(TPL_ENABLE_PETSC)
    list(APPEND TPLS_TO_INCLUDE "${CMAKE_SOURCE_DIR}/cmake/packages/petsc.cmake")
  endif()

  if(TPL_ENABLE_SLEPC)
    if(TPL_ENABLE_PETSC)
      list(APPEND TPLS_TO_INCLUDE "${CMAKE_SOURCE_DIR}/cmake/packages/slepc.cmake")
    else()
      message(WARNING "SLEPc requires PETSc. Disabling SLEPc")
    endif()
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



# Bring the dependencies into the correct order:
execute_process(
  COMMAND python3 ${CMAKE_SOURCE_DIR}/scripts/resolve_dependencies.py ${TPLS_TO_INCLUDE}
  OUTPUT_VARIABLE sorted_packages_raw
  OUTPUT_STRIP_TRAILING_WHITESPACE
)
string(REPLACE ";" ";" sorted_packages "${sorted_packages_raw}")
foreach(pkg ${sorted_packages})
  include("${CMAKE_SOURCE_DIR}/cmake/packages/${pkg}.cmake")
endforeach()



# Finally deal.II itself!
include(${CMAKE_SOURCE_DIR}/cmake/packages/dealii.cmake)
