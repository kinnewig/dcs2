function(build_cmake_subproject name)
  string(TOUPPER "${name}" name_upper)

  # get the download url for ${name}:
  file(READ ${CMAKE_CURRENT_LIST_DIR}/../libraries.json json)
  string(JSON ${name}_url GET ${json} ${name} git)
  string(JSON ${name}_tag GET ${json} ${name} ${${name_upper}_VERSION})

  if (NOT ${name}_tag)
    message(FATAL_ERROR "Git tag for ${name_upper} version ${${name_upper}_VERSION} not found in ${CMAKE_CURRENT_LIST_DIR}/libraries.json.")
  endif()
  
  # If a custom URL is defined, use it.
  if (DEFINED ${name_upper}_CUSTOM_URL)
    set(${name}_url ${${name_upper}_CUSTOM_URL})
    message("Using custom download URL for ${name_upper}: ${${name_upper}_CUSTOM_URL}")
  endif()
  
  # If a custom tag is defined, use it.
  if (DEFINED ${name_upper}_CUSTOM_TAG)
    set(${name}_tag ${${name_upper}_CUSTOM_TAG})
    message("Using custom git tag for ${name_upper}: ${${name_upper}_CUSTOM_TAG}")
  endif()

  if (DEFINED ${name_upper}_SOURCE_DIR)
    ExternalProject_Add(${name}
      URL ${${name_upper}_SOURCE_DIR}
      GIT_SHALLOW true
      CMAKE_ARGS ${${name}_cmake_args}
      INSTALL_DIR ${CMAKE_INSTALL_PREFIX}/${name}/${${name_upper}_VERSION}
      BUILD_COMMAND cmake --build . --parallel ${THREADS}
      BUILD_BYPRODUCTS ${${name_upper}_LIBRARIES}
      CONFIGURE_HANDLED_BY_BUILD true
      CMAKE_GENERATOR ${DEFAULT_GENERATOR}
      DEPENDS ${${name}_dependencies}
    ) 
  else()
    ExternalProject_Add(${name}
      GIT_REPOSITORY ${${name}_url}
      GIT_TAG ${${name}_tag}
      GIT_SHALLOW true
      CMAKE_ARGS ${${name}_cmake_args}
      INSTALL_DIR ${CMAKE_INSTALL_PREFIX}/${name}/${${name_upper}_VERSION}
      BUILD_COMMAND cmake --build . --parallel ${THREADS}
      BUILD_BYPRODUCTS ${${name_upper}_LIBRARIES}
      CONFIGURE_HANDLED_BY_BUILD true
      CMAKE_GENERATOR ${DEFAULT_GENERATOR}
      DEPENDS ${${name}_dependencies}
    )
  endif()
  
  ExternalProject_Get_Property(${name} INSTALL_DIR)

  # Populate the path
  set(${name_upper}_DIR ${INSTALL_DIR} CACHE INTERNAL "")

  set(cmake_prefix_path_local "${CMAKE_PREFIX_PATH}")
  list(APPEND cmake_prefix_path_local "${${name_upper}_DIR}")
  set(CMAKE_PREFIX_PATH ${cmake_prefix_path_local} CACHE INTERNAL "")

  # Check if lib exists, if it does not, create a symlink
  ExternalProject_Add_Step(
    ${name} ${name}_symlink
    COMMAND bash -c "[ -d \"${${name_upper}_DIR}/lib\" ] || ( [ -d \"${${name_upper}_DIR}/lib64\" ] && ln -s \"${${name_upper}_DIR}/lib64\" \"${${name_upper}_DIR}/lib\" )"
    WORKING_DIRECTORY ${${name_upper}_DIR}
    DEPENDEES install
  )

  # Check if lib64 exists, if it does not, create a symlink
  ExternalProject_Add_Step(
    ${name} ${name}_symlink64
    COMMAND bash -c "[ -d \"${${name_upper}_DIR}/lib64\" ] || ( [ -d \"${${name_upper}_DIR}/lib\" ] && ln -s \"${${name_upper}_DIR}/lib\" \"${${name_upper}_DIR}/lib64\" )"
    WORKING_DIRECTORY ${${name_upper}_DIR}
    DEPENDEES install
  )
endfunction()
