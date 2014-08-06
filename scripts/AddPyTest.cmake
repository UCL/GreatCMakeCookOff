include(PythonModule)

function(_apt_single_declare prefix)
    if(${prefix}_PREFIX)
        set(prefix ${${prefix}_PREFIX} PARENT_SCOPE)
    elseif(${prefix}_INSTALL)
        set(prefix ${${prefix}_INSTALL} PARENT_SCOPE)
    else()
        set(prefix "")
    endif()
    if(LOCAL_PYTHON_EXECUTABLE)
        set(exec "${LOCAL_PYTHON_EXECUTABLE}" PARENT_SCOPE)
    elseif(PYTHON_EXECUTABLE)
        set(exec "${PYTHON_EXECUTABLE}" PARENT_SCOPE)
    else()
        message(FATAL_ERROR "Python executable not  set")
    endif()
    if(${prefix}_WORKING_DIRECTORY)
        set(working_directory "${${prefix}_WORKING_DIRECTORY}" PARENT_SCOPE)
    else()
        set(working_directory "${CMAKE_CURRENT_BINARY_DIR}")
    endif()
    set(cmdline ${${prefix}_CMDLINE} PARENT_SCOPE)
endfunction()

function(_apt_add_single_test TESTNAME source)
    # Parses input arguments
    cmake_parse_arguments(_apt_single
        "" "PREFIX;WORKING_DIRECTORY" "CMDLINE"
        ${ARGN}
    )
    # Declares a number of variables
    _apt_single_declare(_apt_single)

    get_filename_component(abs_source "${source}" ABSOLUTE)
    string(REGEX REPLACE ".*/tests?_?(.*)\\.(py|so)" "\\1" testname "${abs_source}")
    if(NOT "${prefix}" STREQUAL "")
        set(testname "${prefix}${testname}")
    endif()
    set(expression
       "from py.test import main"
       "from sys import exit, argv"
       "exit(main(argv[argv.index('--args')+1:]))"
    )
    add_test(NAME ${testname}
        WORKING_DIRECTORY ${working_directory}
        COMMAND ${exec} -c "${expression}" --args ${abs_source} ${cmdline}
    )
    set(${TESTNAME} ${testname} PARENT_SCOPE)
endfunction()

function(add_pytest)
    # Parses input arguments
    cmake_parse_arguments(pytests
        "" "WORKING_DIRECTORY;PREFIX" "LABELS;CMDLINE"
        ${ARGN}
    )
    # Compute sources
    file(GLOB sources RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}"
        ${pytests_UNPARSED_ARGUMENTS})

    unset(all_tests)
    foreach(source ${sources})
        _apt_add_single_test(testname "${source}"
            PREFIX ${pytests_PREFIX}
            WORKING_DIRECTORY "${pytests_WORKING_DIRECTORY}"
            CMDLINE ${pytests_CMDLINE}
        )
        list(APPEND all_tests ${testname})
    endforeach()

    # Add labels to tests
    set(labels python py.test)
    if(pytests_LABELS)
        list(APPEND labels ${pytests_LABELS})
        list(REMOVE_DUPLICATES labels)
    endif()
    set_tests_properties(${all_tests} PROPERTIES LABELS "${labels}")
endfunction()
