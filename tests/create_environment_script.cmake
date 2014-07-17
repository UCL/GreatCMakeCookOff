find_package(GreatCMakeCookOff NO_MODULE PATHS ${cookoff_path} REQUIRED)
initialize_cookoff()

include(CMakeParseArguments)
include(EnvironmentScript)

function(try_execute script)
    cmake_parse_arguments(try_execute "" "OUTPUT" "ARGS" ${ARGN})

    execute_process(
        COMMAND "${PROJECT_BINARY_DIR}/${script}.sh" ${try_execute_ARGS}
        RESULT_VARIABLE result
        OUTPUT_VARIABLE output
        ERROR_VARIABLE error
        OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_STRIP_TRAILING_WHITESPACE
    )
    if(NOT result EQUAL 0)
        message(FATAL_ERROR "environment script failed with "
            "${result}: ${error}")
    endif()
    if(NOT output STREQUAL try_execute_OUTPUT)
        message(FATAL_ERROR "environment script did not output expected"
            " result\n"
            "expected: ${try_execute_OUTPUT}\n"
            "actual: ${output}"
        )
    endif()
endfunction()

# Without executable
create_environment_script(PATH "${PROJECT_BINARY_DIR}/noexec.sh")
try_execute(noexec ARGS echo "hello" OUTPUT "hello")

# With an executable/command
create_environment_script(PATH "${PROJECT_BINARY_DIR}/with_exec.sh" 
    EXECUTABLE echo)
try_execute(with_exec ARGS "hello, world" OUTPUT "hello, world")

# Changing work directory
get_filename_component(directory "${PROJECT_BINARY_DIR}/CMakeFiles" ABSOLUTE)
create_environment_script(PATH "${PROJECT_BINARY_DIR}/ch_dir.sh" 
    EXECUTABLE pwd WORKING_DIRECTORY "${directory}"
)
try_execute(ch_dir  OUTPUT "${directory}")
