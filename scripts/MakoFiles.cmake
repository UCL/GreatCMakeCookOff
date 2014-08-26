include(ConfigureFiles)

function(mako_files targetname)
    # Parses arguments
    cmake_parse_arguments(_mako
        ""
        "MAKO_SCRIPT;OUTPUT_FILES;DESTINATION"
        "MAKO_CMDLINE;DEPENDENCIES"
        ${ARGN}
    )
    file(GLOB sources ${_mako_UNPARSED_ARGUMENTS})
    if("${sources}" STREQUAL "")
        return()
    endif()
    set(destination "${_mako_DESTINATION}")
    if("${destination}" STREQUAL "")
        set(destination "${CMAKE_CURRENT_BINARY_DIR}")
    else()
        file(MAKE_DIRECTORY "${destination}")
    endif()

    set(local_python "${LOCAL_PYTHON_EXECUTABLE}")
    if(NOT "${local_python}")
        set(local_python ${PYTHON_EXECUTABLE})
    endif()
    set(mako_script "${_mako_MAKO_SCRIPT}")
    if("${mako_script}" STREQUAL "")
        if("${mako_SCRIPT}" STREQUAL "")
            message(FATAL_ERROR "Mako render script not defined")
        endif()
        set(mako_script "${mako_SCRIPT}")
    endif()

    if(NOT TARGET ${targetname})
        add_custom_target(${targetname})
    endif()

    unset(makoed_files)
    foreach(filename ${sources})
        output_filename("${filename}" output "${destination}")
        string(REGEX REPLACE "(.*)\\.mako(\\..*)" "\\1\\2" output "${output}")
        get_filename_component(abspath "${filename}" ABSOLUTE)

        add_custom_command(
            TARGET ${targetname}
            COMMAND ${local_python} -B ${mako_SCRIPT} ${abspath} > ${output}
            DEPENDS ${abspath}
            COMMENT "Mako-ing file ${filename}"
        )
        list(APPEND makoed_files "${output}")
    endforeach()

    set(${_mako_OUTPUT_FILES} ${makoed_files} PARENT_SCOPE)
endfunction()

