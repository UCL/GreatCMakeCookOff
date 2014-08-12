# Check location of binaries in build
set(origin "${PROJECT_BINARY_DIR}/../confed_build")
get_filename_component(origin "${origin}" ABSOLUTE)

set(paths_exist
    "${origin}/python_binary/confed/__init__.py"
    "${origin}/python_binary/confed/unconfed.py"
)
foreach(pathname ${paths_exist})
    if(NOT EXISTS "${pathname}")
        message(FATAL_ERROR "Path ${pathname} not in build")
    endif()
endforeach()

# Check location of installs
set(paths_exist
    "${origin}/python_install/confed/__init__.py"
    "${origin}/python_install/confed/unconfed.py"
)
foreach(pathname ${paths_exist})
    if(NOT EXISTS "${pathname}")
        message(FATAL_ERROR "Path ${pathname} not in install")
    endif()
endforeach()



add_custom_target(tests ALL)
add_custom_command(TARGET tests PRE_BUILD
    COMMAND @PYTHON_EXECUTABLE@ -c "import confed"
    COMMAND @PYTHON_EXECUTABLE@ -c "import confed.unconfed"
    WORKING_DIRECTORY "${origin}/python_binary"
)
