# - Try to find catch framework
if(Catch_FOUND)
  return()
endif()
find_path(CATCH_INCLUDE_DIR catch.hpp PATHS ${EXTERNAL_ROOT}/include)
if(CATCH_INCLUDE_DIR)
  file(
    STRINGS ${CATCH_INCLUDE_DIR}/Catch.hpp
    CATCH_VERSION_STRING
    REGEX "[ ]+Catch[ ]+v([0-9]*\\.[0-9]*\\.[0-9]*)"
  )
  string(
    REGEX REPLACE
    ".*[ ]+Catch[ ]+v([0-9]*\\.[0-9]*\\.[0-9]*)"
    "\\1"
    CATCH_VERSION_STRING
    "${CATCH_VERSION_STRING}"
  )
endif()

set(CATCH_INCLUDE_DIRS ${CATCH_INCLUDE_DIR} )

include(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(
  Catch
  REQUIRED_VARS CATCH_INCLUDE_DIR
  VERSION_VAR CATCH_VERSION_STRING
)
