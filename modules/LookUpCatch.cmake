# Installs catchorg/Catch2 into build directory
#
# - URL: defaults to latest single_include
# - VERSION: defaults to latest

if(Catch_ARGUMENTS)
  cmake_parse_arguments(Catch "" "URL;VERSION" ""
    ${Catch_ARGUMENTS})
endif()

if(NOT Catch_VERSION)
  set(Catch_URL_VERSION master)
else()
  set (Catch_URL_VERSION "v${Catch_VERSION}")
endif()

if(NOT Catch_URL)
  set(Catch_URL https://raw.githubusercontent.com/catchorg/Catch2/${Catch_URL_VERSION}/single_include/catch2/catch.hpp)
endif()

set(Catch_FILE "${EXTERNAL_ROOT}/include/catch.hpp")
file(MAKE_DIRECTORY "${EXTERNAL_ROOT}/include")
file(DOWNLOAD ${Catch_URL} "${Catch_FILE}")

file(READ "${Catch_FILE}" CATCHSTRING LIMIT 1000)
string(LENGTH "${CATCHSTRING}" CATCHLENGTH)


if(NOT CATCHLENGTH GREATER 500)
    find_package(Wget)
    if(WGET_FOUND)
        execute_process(COMMAND ${WGET_EXECUTABLE}
          ${Catch_URL}
          -O ${Catch_FILE}
        )
    else()
        find_program(CURL_EXECUTABLE curl)
        execute_process(COMMAND ${CURL_EXECUTABLE}
          -L ${Catch_URL}
          -o ${Catch_FILE}
        )
    endif()
endif()

file(READ "${Catch_FILE}" CATCHSTRING LIMIT 1000)
string(LENGTH "${CATCHSTRING}" CATCHLENGTH)
if(NOT CATCHLENGTH GREATER 500)
  file(REMOVE "${Catch_FILE}")
  message(FATAL_ERROR "Failed to download Catch ${CATCHSTRING} ${CATCHLENGTH}")
endif()


ExternalProject_Add(
    Lookup-Catch
    PREFIX "${EXTERNAL_ROOT}"
    DOWNLOAD_COMMAND ""
    # ARGUMENTS
    # identification of correct lib in subsequent TARGET_LINK_LIBRARIES commands
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ""
    # Wrap download, configure and build steps in a script to log output
    UPDATE_COMMAND ""
    LOG_DOWNLOAD ON LOG_CONFIGURE ON LOG_BUILD ON LOG_INSTALL ON
)

