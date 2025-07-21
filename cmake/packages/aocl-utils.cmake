include(ExternalProject)

#find_package(AOCL-UTILS)
set(AOCL-UTILS_FOUND FALSE)
if(NOT AOCL-UTILS_FOUND)
  message(STATUS "Building AOCL-UTILS")
  
  set(aocl-utils_cmake_args
    -D CMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}/aocl-utils/${AOCL-UTILS_VERSION}
    -D CMAKE_C_COMPILER:PATH=${CMAKE_C_COMPILER}
    -D CMAKE_Fortran_COMPILER:PATH=${CMAKE_Fortran_COMPILER}
    ${aocl-utils_cmake_args}
  )

  if (DEFINED AOCL-UTILS_CUSTOM_URL)
    set(AMD-AOCL-UTILS_CUSTOM_URL ${AOCL-UTILS_CUSTOM_URL})
  endif()
  if (DEFINED AOCL-UTILS_CUSTOM_TAG)
    set(AMD-AOCL-UTILS_CUSTOM_TAG ${AOCL-UTILS_CUSTOM_TAG})
  endif()
  set(amd-aocl-utils_cmake_args ${aocl-utils_cmake_args})
  set(amd-aocl-utils_dependencies ${aocl-utils_dependencies})

  build_cmake_subproject(amd-aocl-utils)

  # Dependencies:
  list(APPEND libflame_dependencies "aocl-utils")
endif()
