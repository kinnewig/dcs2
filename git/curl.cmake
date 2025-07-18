include(ExternalProject)

# Check if curl-development header are installed
find_program(CURL_EXECUTABLE curl)
find_path(CURL_INCLUDE_DIR curl/curl.h)

if(CURL_EXECUTABLE AND CURL_INCLUDE_DIR)
  #message(STATUS "curl development header are present.")
else()
  message(STATUS "curl development header are missing. Install curl.")

  set(curl_tag "curl-8_15_0")
  string(REPLACE "_" "." curl_tag_dotted "${curl_tag}")
  set(curl_url "https://github.com/curl/curl/releases/download")

  ExternalProject_Add(curl
    URL ${curl_url}/${curl_tag}/${curl_tag_dotted}.tar.gz
    PREFIX ${CMAKE_BINARY_DIR}
    CONFIGURE_COMMAND ./configure --prefix=${CMAKE_INSTALL_PREFIX}/curl/${CURL_VERSION}
    BUILD_COMMAND make --with-openssl
    INSTALL_COMMAND make install
    BUILD_IN_SOURCE ON
    DOWNLOAD_EXTRACT_TIMESTAMP TRUE
  )

  set(CURL_DIR ${CMAKE_INSTALL_PREFIX}/curl/${CURL_VERSION})
endif()

