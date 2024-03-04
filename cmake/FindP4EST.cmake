# This module finds ScaLAPACK

if(P4EST_INCLUDE_DIR AND P4EST_LIBRARY)
  # P4EST already found in cache, be silent
  set(P4EST_FOUND TRUE)
else()
  find_path(P4EST_INCLUDE_DIR NAMES p4est.h HINTS ${P4EST_DIR} ${INSTALL_PREFIX}/p4est/${P4EST_VERSION})
  find_library(P4EST_LIBRARY NAMES p4est HINTS ${P4EST_DIR} ${INSTALL_PREFIX}/p4est/${P4EST_VERSION})

  if(P4EST_INCLUDE_DIR AND P4EST_LIBRARY)
    # Derive P4EST_DIR from P4EST_LIBRARY
    get_filename_component(P4EST_DIR "${P4EST_LIBRARY}" DIRECTORY)

    set(P4EST_FOUND TRUE)
  else()
    set(P4EST_FOUND FALSE)
  endif()
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(P4EST DEFAULT_MSG P4EST_LIBRARY P4EST_INCLUDE_DIR)

mark_as_advanced(P4EST_INCLUDE_DIR P4EST_LIBRARY)
