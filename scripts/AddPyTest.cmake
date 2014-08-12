include(PythonModule)

function(_apt_single_declare prefix)
    if(${prefix}_PREFIX)
        set(prefix ${${prefix}_PREFIX} PARENT_SCOPE)
    else()
        set(prefix "" PARENT_SCOPE)
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

endfunction()

function(_apt_add_single_test TESTNAME source)
    # Parses input arguments
    cmake_parse_arguments(_apt_single
        "" "PREFIX;WORKING_DIRECTORY" "CMDLINE"
        ${ARGN}
    )
    # Declares a number of variables
    _apt_single_declare("_apt_single")

    get_filename_component(abs_source "${source}" ABSOLUTE)
    string(REGEX REPLACE ".*/tests?_?(.*)\\.(py|so)" "\\1" testname
        "${abs_source}")
    if(NOT "${prefix}" STREQUAL "")
        set(testname "${prefix}${testname}")
    endif()
    if(NOT DEFINED LOCAL_PYTEST OR NOT LOCAL_PYTEST)
        message(FATAL_ERROR "LOCAL_PYTEST not defined. "
            "Was setup_pytest called?")
    endif()
    add_test(NAME ${testname}
        WORKING_DIRECTORY ${working_directory}
        COMMAND ${LOCAL_PYTEST} ${abs_source} ${_apt_single_CMDLINE}
    )
    set(${TESTNAME} ${testname} PARENT_SCOPE)
endfunction()

function(add_pytest)
    # Parses input arguments
    cmake_parse_arguments(pytests
        "" "WORKING_DIRECTORY;PREFIX" "LABELS;CMDLINE;EXCLUDE"
        ${ARGN}
    )
    # Compute sources
    file(GLOB sources RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}"
        ${pytests_UNPARSED_ARGUMENTS})
    file(GLOB excludes RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}"
        "${pytests_EXCLUDE}")
    if(NOT "${excludes}" STREQUAL "")
        list(REMOVE_ITEM sources ${excludes})
    endif()

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

function(setup_pytest python_path pytest_path)
    include(PythonPackageLookup)
    include(EnvironmentScript)

    lookup_python_package(pytest REQUIRED PATH "${python_path}")
    find_program(PYTEST_EXECUTABLE py.test HINTS "${python_path}")
    if(NOT PYTEST_EXECUTABLE)
        message(FATAL_ERROR "Could not locate py.test executable")
    endif()

    add_to_python_path("${python_path}")
    set(LOCAL_PYTEST "${pytest_path}" CACHE PATH "Path to a py.test script")
    create_environment_script(
        EXECUTABLE "${PYTEST_EXECUTABLE}"
        PATH "${pytest_path}"
        PYTHON
    )
endfunction()
