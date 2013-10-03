# Adds funit ruby gem if it does not exist.
include(${CMAKE_CURRENT_LIST_DIR}/AddRubyGem.cmake)
AddRubyGem(funit REQUIRED)
if(NOT FOUND_funit)
  message(FATAL_ERROR "Could not install/find funit: ${FOUND_funit}")
endif()
execute_process(COMMAND ${GEM_EXECUTABLE} env gempath
                OUTPUT_VARIABLE _POSSIBLE_GEM_BINS
                OUTPUT_STRIP_TRAILING_WHITESPACE)
string(REPLACE ":" "/bin;" _POSSIBLE_GEM_BINS ${_POSSIBLE_GEM_BINS})
set(_POSSIBLE_GEM_BINS "${_POSSIBLE_GEM_BINS}/bin;${PROJECT_BINARY_DIR}/GEMS/bin")
find_program(FUNIT_EXECUTABLE funit PATHS ${_POSSIBLE_GEM_BINS} NO_DEFAULT_PATH)
if(NOT FUNIT_EXECUTABLE)
  set(FOUND_funit FALSE)
else()
  message("[funit] ${FUNIT_EXECUTABLE}")
endif()

function(add_fctest NAME SOURCE)
  execute_process(COMMAND ${GEM_EXECUTABLE} env gempath
                  OUTPUT_VARIABLE ALL_GEM_PATHS
                  OUTPUT_STRIP_TRAILING_WHITESPACE)
  set(ALL_GEM_PATHS "${ALL_GEM_PATHS}:${PROJECT_BINARY_DIR}/GEMS")

  if(${ARGN})
    set(OPTIONS "-s ${ARGN}")
  endif()
  get_filename_component(SOURCE_DIRECTORY ${SOURCE} PATH)
  file(RELATIVE_PATH RELATIVE_DIRECTORY ${PROJECT_SOURCE_DIR} ${SOURCE_DIRECTORY})
  get_filename_component(FILENAME ${SOURCE} NAME_WE)
  configure_file (
    "${SOURCE}"
    "${PROJECT_BINARY_DIR}/${RELATIVE_DIRECTORY}/${FILENAME}.fun"
  )
  add_test(NAME fc_${NAME}
           COMMAND ${FUNIT_EXECUTABLE} ${OPTIONS} ${FILENAME}
           WORKING_DIRECTORY ${PROJECT_BINARY_DIR}/${RELATIVE_DIRECTORY})
  if(MSVC OR MSYS) 
    STRING(REPLACE "\\;" ";" ALL_GEM_PATHS "${ALL_GEM_PATHS}")
    STRING(REPLACE ";" "\\;" ALL_GEM_PATHS "${ALL_GEM_PATHS}")
  endif(MSVC OR MSYS)
  set_tests_properties(fc_${NAME} PROPERTIES ENVIRONMENT "GEM_PATH=${ALL_GEM_PATHS} FSFLAG=-I")
endfunction()
