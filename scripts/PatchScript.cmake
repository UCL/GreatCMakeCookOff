# Creates a script that applies patches
# This script does not fail on errors. It ensures that we can "apply" patches over and over again.
include(CMakeParseArguments)
find_program(PATCH_EXECUTABLE patch)
function(create_patch_script NAME OUTVAR)
    if(NOT PATCH_EXECUTABLE)
        message(FATAL_ERROR "Could not find the patch program")
    endif()
    cmake_parse_arguments(patcher
        ""
        "CMDLINE;WORKING_DIRECTORY"
        ""
        ${ARGN}
    )
    if(NOT patcher_CMDLINE)
        set(patcher_CMDLINE "")
    endif()
    if(NOT patcher_WORKING_DIRECTORY)
        set(patcher_WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}")
    endif()

    # Create patcher script
    file(WRITE "${PROJECT_BINARY_DIR}/patches/${NAME}.cmake"
        "execute_process(\n"
    )
    foreach(filename ${patcher_UNPARSED_ARGUMENTS})
        get_filename_component(filename "${filename}" ABSOLUTE)
        file(APPEND "${PROJECT_BINARY_DIR}/patches/${NAME}.cmake"
            "   COMMAND ${PATCH_EXECUTABLE} -N ${patcher_CMDLINE} < ${filename}\n"
        )
    endforeach()
    file(APPEND "${PROJECT_BINARY_DIR}/patches/${NAME}.cmake"
        "   WORKING_DIRECTORY ${patcher_WORKING_DIRECTORY}\n"
        ")\n"
    )

    set(${OUTVAR} "${PROJECT_BINARY_DIR}/patches/${NAME}.cmake" PARENT_SCOPE)
endfunction()
