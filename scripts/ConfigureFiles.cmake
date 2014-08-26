include(CMakeParseArguments)
function(output_filename filename OUTPUT)
    list(LENGTH ARGN remaining_args)
    if(remaining_args EQUAL 0)
        set(destination "${CMAKE_CURRENT_BINARY_DIR}")
    elseif(remaining_args EQUAL 1)
        set(destination "${ARGN}")
    else()
        message(FATAL_ERROR "Too many arguments to output_filename: ${ARGN}")
    endif()

    get_filename_component(filename "${filename}" ABSOLUTE)
    file(RELATIVE_PATH relfile "${CMAKE_CURRENT_SOURCE_DIR}" "${filename}")

    if("${relfile}" MATCHES "\\.\\./")
        file(RELATIVE_PATH relfile "${destination}" "${filename}")
        if("${relfile}" MATCHES "\\.\\./")
            message(FATAL_ERROR "File ${filename} is not in "
                "destination or source directory or subdirectory.")
        endif()
    endif()
    set(${OUTPUT} "${destination}/${relfile}" PARENT_SCOPE)
endfunction()

function(configure_files)
    # Parses arguments
    cmake_parse_arguments(_cf
        "" "OUTPUT_FILES;DESTINATION" ""
        ${ARGN}
    )
    file(GLOB sources ${_cf_UNPARSED_ARGUMENTS})
    if("${sources}" STREQUAL "")
        return()
    endif()
    set(destination "${_cf_DESTINATION}")
    if("${destination}")
        set(destination "${CMAKE_CURRENT_BINARY_DIR}")
    endif()

    unset(configured_files)
    foreach(filename ${sources})
        output_filename("${filename}" output "${destination}")
        string(REGEX REPLACE "(.*)\\.in(\\..*)" "\\1\\2" output "${output}")

        configure_file("${filename}" "${output}" @ONLY)
        list(APPEND configured_files "${output}")
    endforeach()

    if(_cf_OUTPUT_FILES)
        set(${_cf_OUTPUT_FILES} ${all_sources} PARENT_SCOPE)
    endif()
endfunction()

