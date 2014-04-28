# A script to write cache variables to file
# Makes it easy to include a subset of cached variables in external projects
function(passon_variables PACKAGE)
    include(CMakeParseArguments)
    cmake_parse_arguments(passon "APPEND;PUBLIC" "FILENAME" "" ${ARGN})
    if(NOT passon_FILENAME AND EXTERNAL_ROOT)
        set(passon_FILENAME "${EXTERNAL_ROOT}/src/${PACKAGE}.cmake")
    elseif()
        set(passon_FILENAME "${CMAKE_BINARY_DIR}/CMakeFiles/${PACKAGE}.cmake")
    endif()
    if(NOT passon_APPEND)
      file(WRITE "${passon_FILENAME}" "# pre-cached variables for ${PACKAGE}")
    endif()
    get_cmake_property(all_cached_variables CACHE_VARIABLES)
    foreach(pattern ${passon_UNPARSED_ARGUMENTS})
        foreach(variable ${all_cached_variables})
            if(variable MATCHES "${pattern}")
                get_property(type CACHE ${variable} PROPERTY TYPE)
                get_property(help CACHE ${variable} PROPERTY HELPSTRING)
                get_property(advanced CACHE ${variable} PROPERTY ADVANCED)
                if(NOT passon_PUBLIC OR NOT "${type}" STREQUAL "INTERNAL")
                    file(APPEND "${passon_FILENAME}"
                        "\nset(${variable} \"${${variable}}\" CACHE ${type} \"${help}\")"
                    )
                    if(ADVANCED)
                        file(APPEND "${passon_FILENAME}"
                            "\nset(${variable} \"${${variable}}\" CACHE ${type} \"${help}\")\n"
                        )
                    endif()
               endif()
            endif()
        endforeach()
    endforeach()
endfunction()
