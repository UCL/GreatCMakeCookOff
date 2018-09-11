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

find_path(CATCH_INCLUDE_DIR catch.hpp PATHS /usr/include ${EXTERNAL_ROOT}/include PATH_SUFFIXES catch2)
# <package>_FIND_VERSION var dessapears after the first time this runs
set(Catch_WANTED_VERSION ${Catch_FIND_VERSION})

if(CATCH_INCLUDE_DIR)
  file(
    STRINGS ${CATCH_INCLUDE_DIR}/catch.hpp
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

if(Catch_FIND_VERSION AND (NOT "${CATCH_VERSION_STRING}" STREQUAL "${Catch_FIND_VERSION}"))
  set(CATCH_INCLUDE_DIR "")
else()
  set(CATCH_INCLUDE_DIRS ${CATCH_INCLUDE_DIR} )
  set(Catch_INCLUDE_DIRS ${CATCH_INCLUDE_DIR} )
endif()

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
