include(ExternalProject)

#find_package(AOCL-UTILS)
set(AOCL-UTILS_FOUND FALSE)
if(AOCL-UTILS_FOUND)

else()
  message(STATUS "Building AOCL-UTILS")
  
  set(aocl-utils_cmake_args
    -D CMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}/aocl-utils/${AOCL-UTILS_VERSION}
    -D CMAKE_C_COMPILER:PATH=${CMAKE_C_COMPILER}
    -D CMAKE_Fortran_COMPILER:PATH=${CMAKE_Fortran_COMPILER}
    ${aocl-utils_cmake_args}
  )

  # get the download url for aocl-utils:
  file(READ ${CMAKE_CURRENT_LIST_DIR}/libraries.json json)
  string(JSON aocl-utils_url GET ${json} amd aocl-utils git)
  string(JSON aocl-utils_tag GET ${json} amd aocl-utils ${AMD_VERSION} tag)
  if (NOT aocl-utils_tag)
    message(FATAL_ERROR "Git tag for AOCL-UTILS version ${AOCL-UTILS_VERSION} not found in ${CMAKE_CURRENT_LIST_DIR}/libraries.json.")
  endif()
  
  # If a custom URL for aocl-utils is defined, use it.
  if (DEFINED AOCL-UTILS_CUSTOM_URL)
    set(aocl-utils_url ${AOCL-UTILS_CUSTOM_URL})
    message("Using custom download URL for AOCL-UTILS: ${AOCL-UTILS_CUSTOM_URL}")
  endif()
  
  # If a custom tag for aocl-utils is defined, use it.
  if (DEFINED AOCL-UTILS_CUSTOM_TAG)
    set(aocl-utils_tag ${AOCL-UTILS_CUSTOM_TAG})
    message("Using custom git tag for AOCL-UTILS: ${AOCL-UTILS_CUSTOM_TAG}")
  endif()
  
  ExternalProject_Add(aocl-utils
    GIT_REPOSITORY ${aocl-utils_url}
    GIT_TAG ${aocl-utils_tag}
    GIT_SHALLOW true
    CMAKE_ARGS ${aocl-utils_cmake_args}
    INSTALL_DIR ${CMAKE_INSTALL_PREFIX}/aocl-utils/${AOCL-UTILS_VERSION}
    BUILD_BYPRODUCTS ${AOCL-UTILS_LIBRARIES}
    CONFIGURE_HANDLED_BY_BUILD true
    CMAKE_GENERATOR ${DEFAULT_GENERATOR}
    DEPENDS ${aocl-utils_dependencies}
  )
  
  ExternalProject_Get_Property(aocl-utils INSTALL_DIR)
  
  # Populate the path
  set(AOCL-UTILS_DIR ${INSTALL_DIR})
  list(APPEND CMAKE_PREFIX_PATH "${AOCL-UTILS_DIR}")
  
  # Linking
  add_library(AOCL-UTILS::AOCL-UTILS INTERFACE IMPORTED GLOBAL)
  set_target_properties(AOCL-UTILS::AOCL-UTILS PROPERTIES
    IMPORTED_LOCATION ${AOCL-UTILS_DIR}/lib64/libsaocl-utils.so
    INTERFACE_INCLUDE_DIRECTORIES ${AOCL-UTILS_DIR}/include
  )

  # Dependencies:
  # add AOCL-UTILS as dependencie to trilinos
  list(APPEND libflame_dependencies "aocl-utils")
endif()

# add AOCL-UTILS to trilinos
#list(APPEND libflame_cmake_args "-D AOCL-UTILS_INCLUDE_DIRS:PATH=${AOCL-UTILS_DIR}/include")
