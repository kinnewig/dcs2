# This module finds ScaLAPACK

if(TRILINOS_INCLUDE_DIR AND TRILINOS_LIBRARY)
  # ScaLAPACK already found in cache, be silent
  set(TRILINOS_FOUND TRUE)
else()
  find_path(TRILINOS_INCLUDE_DIR NAMES trilinos.h HINTS ${TRILINOS_DIR} ${INSTALL_PREFIX}/trilinos/${TRILINOS_VERSION})
  find_library(TRILINOS_LIBRARY NAMES trilinos HINTS ${TRILINOS_DIR} ${INSTALL_PREFIX}/trilinos/${TRILINOS_VERSION})

  if(TRILINOS_INCLUDE_DIR AND TRILINOS_LIBRARY)
    # Derive TRILINOS_DIR from ScaLAPACK_LIBRARY
    get_filename_component(TRILINOS_DIR "${TRILINOS_LIBRARY}" DIRECTORY)

    set(TRILINOS_FOUND TRUE)
  else()
    set(TRILINOS_FOUND FALSE)
  endif()
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(TRILINOS DEFAULT_MSG TRILINOS_LIBRARY TRILINOS_INCLUDE_DIR)

mark_as_advanced(TRILINOS_INCLUDE_DIR TRILINOS_LIBRARY)
