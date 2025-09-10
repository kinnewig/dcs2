include(ExternalProject)

find_program(NUMDIFF_EXECUTABLE numdiff)

if(NUMDIFF_EXECUTABLE)
  message(STATUS "Found NUMDIFF: ${NUMDIFF_EXECUTABLE}")
else()
  message(STATUS "Building NUMDIFF")
  
  list(APPEND numdiff_autotool_args "--prefix=${CMAKE_INSTALL_PREFIX}/numdiff/${NUMDIFF_VERSION}")
  list(APPEND numdiff_autotool_args "--disable-nls")
  list(APPEND numdiff_autotool_args "--disable-gmp") # GMP leads to linking issues on modern systems
  list(APPEND numdiff_autotool_args "CFLAGS=-std=c17")
  list(APPEND numdiff_autotool_args "CXXFLAGS=-std=c17")

  # NUMDIFF does not exist as Git repository, so we have to fall back to an archive...
  file(READ ${CMAKE_CURRENT_LIST_DIR}/../libraries.json json)

  string(JSON numdiff_url GET ${json} numdiff git)
  string(JSON numdiff_tag GET ${json} numdiff ${NUMDIFF_VERSION})

  ExternalProject_Add(numdiff
    URL ${numdiff_url}/${numdiff_tag}
    BUILD_COMMAND make -j ${THREADS}
    INSTALL_COMMAND make install
    CONFIGURE_COMMAND 
     ${CMAKE_COMMAND} -E env
       CC=gcc
       CXX=g++
       ./configure ${numdiff_autotool_args}
    INSTALL_DIR ${CMAKE_INSTALL_PREFIX}/numdiff/${NUMDIFF_VERSION}
    BUILD_IN_SOURCE ON
    DOWNLOAD_EXTRACT_TIMESTAMP true
    CMAKE_GENERATOR ${DEFAULT_GENERATOR}
    DEPENDS ${numdiff_dependencies}
  )

  ExternalProject_Get_Property(numdiff INSTALL_DIR)
  set("NUMDIFF_DIR" "${INSTALL_DIR}" CACHE INTERNAL "")

  # Link the binary to the BIN_DIR
  ExternalProject_Add_Step(
    numdiff numdiff_symlink_env
    COMMAND bash -c "[ -L \"${BIN_DIR}/numdiff\" ] || ln -s ${NUMDIFF_DIR}/bin/numdiff ${BIN_DIR}/numdiff"
    COMMAND bash -c "[ -L \"${BIN_DIR}/ndselect\" ] || ln -s ${NUMDIFF_DIR}/bin/ndselect ${BIN_DIR}/ndselect"
    WORKING_DIRECTORY ${NUMDIFF_DIR}
    DEPENDEES install
  )

  # Dependencies:
  list(APPEND dealii_dependencies "numdiff")
endif()
