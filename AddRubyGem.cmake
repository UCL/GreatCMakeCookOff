# AddRubyGem(PACKAGE_NAME)
#    Checks for a given gem. If the gem does not exist, it installs it in the
#    build directory.
#    Sets the variable FOUND_${PACKAGE_NAME} on success.
#
# execute_ruby(...)
#    Execute ruby with given arguments, after setting GEM_PATH so newly
#    installed packages are found. Arguments are those of execute_process,
#    including ${RUBY_EXECUTABLE}.

find_package(Ruby)
if(NOT RUBY_EXECUTABLE)
  if(IS_REQUIRED)
    message(FATAL_ERROR "[${PACKAGE_NAME}] required, but ruby not found.")
  endif(IS_REQUIRED)
  return()
endif(NOT RUBY_EXECUTABLE)

# Look for gem
if(NOT GEM_EXECUTABLE)
  find_program(GEM_EXECUTABLE gem)
endif(NOT GEM_EXECUTABLE)
set(GEM_EXECUTABLE ${GEM_EXECUTABLE} CACHE PATH "gem executable")

macro(execute_ruby)
  execute_process(COMMAND ${GEM_EXECUTABLE} env gempath
                  OUTPUT_VARIABLE ALL_GEM_PATHS
                  OUTPUT_STRIP_TRAILING_WHITESPACE)
  set(ENV{GEM_PATH} "${ALL_GEM_PATHS}:${PROJECT_BINARY_DIR}/GEMS")
  execute_process(${ARGN})
  set(ENV{GEM_PATH} ${ALL_GEM_PATHS})
endmacro()

function(AddRubyGem PACKAGE_NAME)
  list(FIND ${ARGN} REQUIRED IS_REQUIRED)

  if(NOT GEM_EXECUTABLE)
    if(IS_REQUIRED)
      message(FATAL_ERROR "[${PACKAGE_NAME}] required, but gem executable not found.")
    endif(IS_REQUIRED)
    message(STATUS "[${PACKAGE_NAME}] gem executable not found.")
    return()
  endif(NOT GEM_EXECUTABLE)

  execute_ruby(COMMAND ${GEM_EXECUTABLE} list -i ${PACKAGE_NAME}
               RESULT_VARIABLE FOUND_${PACKAGE_NAME} ERROR_QUIET OUTPUT_QUIET)
                  
  if(FOUND_${PACKAGE_NAME} EQUAL 0)
    set(FOUND_${PACKAGE_NAME} True PARENT_SCOPE)
    message(STATUS "[${PACKAGE_NAME}] found.")
    return()
  endif()
  message(STATUS "[${PACKAGE_NAME}] Not found. Trying to install to ${PROJECT_BINARY_DIR}.")

  execute_ruby(COMMAND ${GEM_EXECUTABLE} install -i ${PROJECT_BINARY_DIR}/GEMS funit
               RESULT_VARIABLE FOUND_${PACKAGE_NAME})

  if(NOT FOUND_${PACKAGE_NAME} EQUAL 0)
    message(FATAL_ERROR "[${PACKAGE_NAME}] could not be installed ${FOUND_${PACKAGE_NAME}}.")
  endif(NOT FOUND_${PACKAGE_NAME} EQUAL 0)

  execute_ruby(COMMAND ${GEM_EXECUTABLE} list -i ${PACKAGE_NAME}
               RESULT_VARIABLE FOUND_${PACKAGE_NAME})

  if(NOT FOUND_${PACKAGE_NAME} EQUAL 0)
    message(FATAL_ERROR "[${PACKAGE_NAME}] ${FOUND_${PACKAGE_NAME}} could not be installed.")
  endif(NOT FOUND_${PACKAGE_NAME} EQUAL 0)
                  
  set(FOUND_${PACKAGE_NAME} True PARENT_SCOPE)
  message(STATUS "[${PACKAGE_NAME}] installed.")
endfunction()
