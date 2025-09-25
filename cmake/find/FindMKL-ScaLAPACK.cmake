# FindMKL-ScaLAPACK.cmake
# -------------------
# Locates MKL Scalapack .
# This will define the following variables:
# MKL-ScaLAPACK_FOUND - System has MKL ScaLAPACK
# MKL-ScaLAPACK_LIBRARIES - The libraries needed to use MKL ScaLAPACK 

find_package(PkgConfig)
pkg_check_modules(PC_MKL-ScaLAPACK QUIET MKL-ScaLAPACK)

set(MKL-ScaLAPACK_DIR "" CACHE PATH "The directory of the LIBFLAME installation")

find_library(MKL-ScaLAPACK_LIBRARY NAMES libmkl_scalapack_${MKL_LP_TYPE}${CMAKE_SHARED_LIBRARY_SUFFIX}
             HINTS ${MKL_DIR} ${MKL_ROOT}
             PATH_SUFFIXES mkl/latest/lib lib
           )

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(MKL-ScaLAPACK DEFAULT_MSG MKL-ScaLAPACK_LIBRARY)

if(MKL-ScaLAPACK_FOUND)
  set(MKL-ScaLAPACK_LIBRARIES ${MKL-ScaLAPACK_LIBRARY})
endif()

mark_as_advanced(MKL-ScaLAPACK_LIBRARY)
