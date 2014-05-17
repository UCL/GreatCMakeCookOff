# Adds a target which simply copies files from one place to another.
# See https://github.com/UCL/GreatCMakeCookOff/wiki for information
include(CMakeParseArguments)

function(add_copy_files FILECOPIER_TARGET)
    cmake_parse_arguments(
        FILECOPIER
        ""
        "DESTINATION;GLOB"
        "REPLACE;FILES"
        ${ARGN}
    )
 
    if(NOT TARGET ${FILECOPIER_TARGET})
        add_custom_target(${FILECOPIER_TARGET})
    endif()
    if(NOT FILECOPIER_DESTINATION)
        set(destination ${CMAKE_CURRENT_BINARY_DIR})
    else()
        get_filename_component(destination "${FILECOPIER_DESTINATION}" ABSOLUTE)
    endif()
    if(NOT FILECOPIER_GLOB AND NOT FILECOPIER_FILES)
        set(input_sources ${FILECOPIER_UNPARSED_ARGUMENTS})
    elseif(FILECOPIER_GLOB AND FILECOPIER_FILES)
        message(FATAL_ERROR "copy_files takes one of GLOB or FILES, not both")
    elseif(FILECOPIER_FILES)
        set(input_sources ${FILECOPIER_FILES})
    else()
        file(GLOB input_sources ${FILECOPIER_GLOB})
    endif()
 
    if(FILECOPIER_REPLACE)
        list(LENGTH FILECOPIER_REPLACE replace_length)
        if(NOT ${replace_length} EQUAL 2)
            message(FATAL_ERROR "copy_files argument REPLACE takes two inputs")
        endif()
        list(GET FILECOPIER_REPLACE 0 PATTERN)
        list(GET FILECOPIER_REPLACE 1 REPLACEMENT)
    endif()
 
    foreach(input ${input_sources})
        get_filename_component(output ${input} NAME)
        if(NOT "${FILECOPIER_REPLACE}" STREQUAL "")
            string(REGEX REPLACE "${PATTERN}" "${REPLACEMENT}" output ${output})
        endif()
        set(output ${destination}/${output})
        get_filename_component(input "${input}" ABSOLUTE)
       
        add_custom_command(
            TARGET ${FILECOPIER_TARGET}
            PRE_BUILD
            COMMAND ${CMAKE_COMMAND} -E copy ${input} ${output}
            DEPENDS ${input}
        )
    endforeach()
endfunction()

