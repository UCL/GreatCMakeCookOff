# Scripts that modify LD_LIBRARY_PATH and such

function(_add_to_a_path THISFILE PATH)
    if(NOT EXISTS "${THISFILE}")
        file(WRITE "${THISFILE}" "${PATH}\n")
        return()
    endif()
    file(STRINGS "${THISFILE}" ALLPATHS)
    list(FIND ALLPATHS "${PATH}" INDEX)
    if(INDEX EQUAL -1)
        file(APPEND "${THISFILE}" "${PATH}\n")
    endif()
endfunction()
function(add_to_ld_path PATH)
    _add_to_a_path("${PROJECT_BINARY_DIR}/paths/ldpaths" "${PATH}")
endfunction()
function(add_to_python_path PATH)
    _add_to_a_path("${PROJECT_BINARY_DIR}/paths/pypaths.pth" "${PATH}")
endfunction()

if(NOT UNIX)
    function(create_environment_script caller location)
        message(FATAL_ERROR "Environment scripts not implemented "
            "on non-UNIX systems")
    endfunction()
    return()
endif()

set(_PATH_TO_LOCALBASH_IN
    "${CMAKE_CURRENT_LIST_DIR}/localbash.in.sh"
    CACHE INTERNAL "Path to a template bash script"
)
find_program(BASH_EXECUTABLE bash)
find_program(ENV_EXECUTABLE env)
include(CMakeParseArguments)

function(create_environment_script)
    cmake_parse_arguments(env "PYTHON" "PATH;EXECUTABLE;WORKING_DIRECTORY"
        "" ${ARGN})
    if(NOT env_PATH)
        set(env_PATH "${CMAKE_CURRENT_BINARY_DIR}/envscript.sh")
    endif()
    if(NOT env_EXECUTABLE)
        set(env_EXECUTABLE "")
    endif()
    # used in the configured script: if set, modifies python path
    if(NOT env_PYTHON)
        set(env_PYTHON "")
    endif()

    get_filename_component(filename "${env_PATH}" NAME)
    get_filename_component(directory "${env_PATH}" PATH)
    configure_file("${_PATH_TO_LOCALBASH_IN}"
        "${PROJECT_BINARY_DIR}/CMakeFiles/${filename}"
        @ONLY
    )
    file(COPY "${PROJECT_BINARY_DIR}/CMakeFiles/${filename}"
        DESTINATION "${directory}"
        FILE_PERMISSIONS OWNER_EXECUTE OWNER_WRITE OWNER_READ
    )
endfunction()
