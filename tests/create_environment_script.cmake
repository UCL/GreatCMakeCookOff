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

function(check_ldpaths msg)
    if(NOT EXISTS "${PROJECT_BINARY_DIR}/paths/ldpaths")
        message(FATAL_ERROR "${msg}: file ldpaths does not exist")
    endif()

    file(READ "${PROJECT_BINARY_DIR}/paths/ldpaths" actual)
    unset(expected)
    foreach(directory ${ARGN})
        set(expected "${expected}${directory}\n")
    endforeach()
    if(NOT expected STREQUAL actual)
        message(FATAL_ERROR "${msg}\n" 
            "expected: ${expected}\n"
            "actual: ${actual}"
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


# Check dyldpath modifications
create_environment_script(PATH "${PROJECT_BINARY_DIR}/dyld.sh" 
    EXECUTABLE "echo $DYLD_LIBRARY_PATH")
file(REMOVE "${PROJECT_BINARY_DIR}/paths/ldpaths"
    "${PROJECT_BINARY_DIR}/lib"
    "${PROJECT_BINARY_DIR}/lib64"
    "${PROJECT_BINARY_DIR}/lib32"
)
set(expected "$ENV{DYLD_LIBRARY_PATH}")
try_execute(dyld OUTPUT "${expected}")

# add a system environment path -- should not be added to ldpaths
# for simplicity, do this first: the file ldpaths should not be created by call
list(GET CMAKE_PLATFORM_IMPLICIT_LINK_DIRECTORIES 0 directory)
add_to_ld_path("${directory}" "/System/Library/")
if(EXISTS "${PROJECT_BINARY_DIR}/paths/ldpaths")
    message(FATAL_ERROR "Path should not have made it through")
endif()
# Path should be unchanged
try_execute(dyld OUTPUT "${expected}")

# add a system environment path -- should not be added to ldpaths
# now the file will be created and have one entry
add_to_ld_path("${PROJECT_BINARY_DIR}/lib")
if(NOT EXISTS "${PROJECT_BINARY_DIR}/paths/ldpaths")
    message(FATAL_ERROR "Valid path not written to file")
endif()
check_ldpaths("Paths not found in ldpaths file" "${PROJECT_BINARY_DIR}/lib")
# Path should be unchanged because directory does not yet exist
try_execute(dyld OUTPUT "${expected}")
# Now create path
file(MAKE_DIRECTORY "${PROJECT_BINARY_DIR}/lib")
set(expected "${expected}:${PROJECT_BINARY_DIR}/lib")
try_execute(dyld OUTPUT "${expected}")

# Add a second path and re-add the first
add_to_ld_path("${PROJECT_BINARY_DIR}/lib64" "${PROJECT_BINARY_DIR}/lib")
check_ldpaths("Paths not found in ldpaths file"
    "${PROJECT_BINARY_DIR}/lib"
    "${PROJECT_BINARY_DIR}/lib64"
)
file(MAKE_DIRECTORY "${PROJECT_BINARY_DIR}/lib64")
set(expected "${expected}:${PROJECT_BINARY_DIR}/lib64")
try_execute(dyld OUTPUT "${expected}")

# Now add system paths and check again for good measure
add_to_ld_path(${CMAKE_PLATFORM_IMPLICIT_LINK_DIRECTORIES}
    "${PROJECT_BINARY_DIR}/lib32" "/System/fakey")
check_ldpaths("Paths not found in ldpaths file"
    "${PROJECT_BINARY_DIR}/lib"
    "${PROJECT_BINARY_DIR}/lib64"
    "${PROJECT_BINARY_DIR}/lib32"
)
file(MAKE_DIRECTORY "${PROJECT_BINARY_DIR}/lib32")
set(expected "${expected}:${PROJECT_BINARY_DIR}/lib32")
try_execute(dyld OUTPUT "${expected}")
