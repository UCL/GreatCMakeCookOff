# - Try to find catch framework
# Catch_FOUND         if catch was found
# Catch_INCLUDE_DIR   the directory to catch.hpp
# Catch_HAS_THROWS_AS if the CHECK_THROWS_AS macro actually works
#                     It is known to fail for gcc@4.9 and Catch@:1.7

if(Catch_FOUND)
  set(CATCH_INCLUDE_DIRS ${CATCH_INCLUDE_DIR} )
  set(Catch_INCLUDE_DIR ${CATCH_INCLUDE_DIR} )
  if("${CATCH_RUNS}" STREQUAL "FAILED_TO_RUN" OR NOT CATCH_RUNS)
    set(CATCH_HAS_THROWS_AS FALSE)
  else()
    set(CATCH_HAS_THROWS_AS TRUE)
  endif()
  set(Catch_HAS_THROWS_AS ${CATCH_HAS_THROWS_AS} )
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
set(Catch_INCLUDE_DIRS ${CATCH_INCLUDE_DIR} )

if(CATCH_INCLUDE_DIR)
  try_run(CATCH_RUNS CATCH_COMPILES
    "${CMAKE_BINARY_DIR}/catch_try_compile"
    "${CMAKE_CURRENT_LIST_DIR}/catch_throw_as.cc"
    CMAKE_FLAGS -DINCLUDE_DIRECTORIES:PATH=${CATCH_INCLUDE_DIR}
    )
  if(NOT CATCH_COMPILES)
    unset(CATCH_INCLUDE_DIR)
  elseif("${CATCH_RUNS}" STREQUAL "FAILED_TO_RUN" OR NOT CATCH_RUNS)
    set(CATCH_HAS_THROWS_AS FALSE)
  else()
    set(CATCH_HAS_THROWS_AS TRUE)
  endif()
  set(Catch_HAS_THROWS_AS ${Catch_HAS_THROWS_AS})
endif()


include(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(
  Catch
  REQUIRED_VARS CATCH_INCLUDE_DIR
  VERSION_VAR CATCH_VERSION_STRING
)
