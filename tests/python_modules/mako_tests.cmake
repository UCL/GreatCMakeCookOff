# Check location of binaries in build
set(origin "${PROJECT_BINARY_DIR}/../mako_build")
set(paths_exist
    "${origin}/python_binary/makoed"
    "${origin}/python_binary/makoed/__init__.py"
    "${origin}/python_binary/makoed/other.py"
)
foreach(pathname ${paths_exist})
    if(NOT EXISTS "${pathname}")
        message(FATAL_ERROR "Path ${pathname} not in build")
    endif()
endforeach()

# Check location does not exist
set(LOCAL_PYTHON_EXECUTABLE "@CMAKE_CURRENT_BINARY_DIR@/mako_tester.sh")
execute_process(
    COMMAND ${LOCAL_PYTHON_EXECUTABLE} __init__.py
    WORKING_DIRECTORY "${origin}/python_binary/makoed"
    RESULT_VARIABLE result
    OUTPUT_VARIABLE output
    ERROR_VARIABLE error
)
if(NOT result EQUAL 0)
    message("output: ${output}\n")
    message("error: ${error}\n")
    message("result: ${result}\n")
    message(FATAL_ERROR "Could not run mako")
endif()
