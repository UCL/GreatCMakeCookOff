include(PythonModule)

function(pytest_name OUTVAR source prefix)
    get_filename_component(filename "${source}" NAME_WE)
    string(REGEX REPLACE "tests?_?(.*)" "\\1" testname "${filename}")
    if(NOT "${prefix}" STREQUAL "")
        set(testname "${prefix}.${testname}")
    endif()
    set(${OUTVAR} ${testname} PARENT_SCOPE)
endfunction()

function(_apt_module_name OUTVAR prefix)
    set(target "tests")
    if(NOT "${prefix}" STREQUAL "")
        set(target "${prefix}.${target}")
    endif()
    set(${OUTVAR} ${target} PARENT_SCOPE)
endfunction()

function(add_pytest)
    # Parses input arguments
    cmake_parse_arguments(pytests
        "CPP;INSTALL;NOINSTALL;FAKE_INIT"
        "WORKING_DIRECTORY;PREFIX;LOCATION;TARGETNAME;EXECUTABLE"
        "LABELS;CMDLINE;EXCLUDE;LIBRARIES"
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

    # Set some standard variables
    if(LOCAL_PYTHON_EXECUTABLE)
        set(exec "${LOCAL_PYTHON_EXECUTABLE}" PARENT_SCOPE)
    elseif(PYTHON_EXECUTABLE)
        set(exec "${PYTHON_EXECUTABLE}" PARENT_SCOPE)
    else()
        message(FATAL_ERROR "Python executable not set")
    endif()
    set(working_directory "${CMAKE_CURRENT_BINARY_DIR}")
    if(_pypy_WORKING_DIRECTORY)
        set(working_directory "${pytests_WORKING_DIRECTORY}")
    endif()
    set(executable "${pytests_EXECUTABLE}")
    if("${executable}" STREQUAL "")
        if(NOT "${LOCAL_PYTEST}" STREQUAL "")
            set(executable "${LOCAL_PYTEST}")
        else()
            message(FATAL_ERROR "Could not figure out py.test executable.\n"
                "Was setup_pytest called?")
        endif()
    endif()

    _apt_module_name(target "${pytests_PREFIX}")
    set(arguments INSTALL)
    if(pytests_NOINSTALL)
        set(arguments NOINSTALL)
    endif()
    if(pytests_FAKE_INIT)
        list(APPEND arguments FAKE_INIT)
    endif()
    add_python_module(${target}
        ${sources}
        ${arguments}
        LOCATION ${pytests_LOCATION}
        LIBRARIES ${pytests_LIBRARIES}
        TARGETNAME ${pytests_TARGETNAME}
        OUTPUT_PYTHON_SOURCES sources
    )

    # Gets location of python modules in build
    _pm_location_and_name(${target} "${pytests_LOCATION}")
    if(NOT IS_ABSOLUTE "${location}")
        set(location "${PYTHON_BINARY_DIR}/${location}")
    endif()

    unset(all_tests)
    foreach(source ${sources})
        get_filename_component(filename "${source}" NAME)
        if("${filename}" MATCHES "^tests?_.*\\.py")
            set(filename "${location}/${filename}")
            pytest_name(testname "${source}" "${pytests_PREFIX}")
            add_test(NAME ${testname}
                WORKING_DIRECTORY ${working_directory}
                COMMAND ${executable} ${filename} ${pytests_CMDLINE}
            )
            list(APPEND all_tests ${testname})
        endif()
    endforeach()

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
