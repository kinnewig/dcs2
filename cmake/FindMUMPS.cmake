# This module finds ScaLAPACK

if(MUMPS_INCLUDE_DIR AND MUMPS_LIBRARY)
  # ScaLAPACK already found in cache, be silent
  set(MUMPS_FOUND TRUE)
else()
  find_path(MUMPS_INCLUDE_DIR NAMES mumps.h HINTS ${MUMPS_DIR} ${INSTALL_PREFIX}/mumps/${MUMPS_VERSION})
  find_library(MUMPS_LIBRARY NAMES mumps HINTS ${MUMPS_DIR} ${INSTALL_PREFIX}/mumps/${MUMPS_VERSION})

  if(MUMPS_INCLUDE_DIR AND MUMPS_LIBRARY)
    # Derive MUMPS_DIR from ScaLAPACK_LIBRARY
    get_filename_component(MUMPS_DIR "${MUMPS_LIBRARY}" DIRECTORY)

    set(MUMPS_FOUND TRUE)
  else()
    set(MUMPS_FOUND FALSE)
  endif()
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(MUMPS DEFAULT_MSG MUMPS_LIBRARY MUMPS_INCLUDE_DIR)

mark_as_advanced(MUMPS_INCLUDE_DIR MUMPS_LIBRARY)
