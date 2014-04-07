# Checks for python package
#
# find_python_package(<NAME>
#   [REQUIRED] -- will fail build if package not found
#   [VERSION version] -- minimum version
#   [EXACT] -- must find exact version
#   [QUIET] -- silence is golden
# )
#
# Sets ${NAME}_FOUND, as well as ${NAME}_LOCATION containing
# the directory where the module resides, and ${NAME}_VERSION_STRING
# the version of the package.


# First check for python executable
include(FindPackageHandleStandardArgs)
include(utilities)
find_package(PythonInterp REQUIRED)
include(CMakeParseArguments)

function(_python_executable OUTVAR)
    cmake_parse_arguments(PYEXEC "LOCAL" "PYTHON_EXECUTABLE" "" ${ARGN})
    if(PYEXEC_LOCAL AND PYEXEC_PYTHON_EXECUTABLE)
        message(FATAL_ERROR "Cannot use LOCAL and PYTHON arguments together")
    endif()
    if(PYEXEC_LOCAL AND NOT LOCAL_PYTHON_EXECUTABLE)
        message(FATAL_ERROR "PythonVirtualEnv not included yet.")
    endif()
    if(PYEXEC_LOCAL)
        set(${OUTVAR} ${LOCAL_PYTHON_EXECUTABLE} PARENT_SCOPE)
    elseif(PYEXEC_PYTHON_EXECUTABLE)
        set(${OUTVAR} ${PYEXEC_PYTHON_EXECUTABLE} PARENT_SCOPE)
    else()
        set(${OUTVAR} ${PYTHON_EXECUTABLE} PARENT_SCOPE)
    endif()
    set(${OUTVAR}_UNPARSED_ARGUMENTS ${PYEXEC_UNPARSED_ARGUMENTS} PARENT_SCOPE)
endfunction()

function(find_python_package PACKAGE)
    string(TOUPPER "${PACKAGE}" PACKAGE_UPPER)
    cmake_parse_arguments(${PACKAGE}_FIND
        "REQUIRED;EXACT" "VERSION" "" ${ARGN})
    cmake_parse_arguments(PYPACK
        "QUIET" "WORKING_DIRECTORY" ""
        ${${PACKAGE}_FIND_UNPARSED_ARGUMENTS})
    _python_executable(LOCALPYTHON ${PYPACK_UNPARSED_ARGUMENTS})
    if(NOT PYPACK_WORKING_DIRECTORY)
        set(PYPACK_WORKING_DIRECTORY "${PROJECT_BINARY_DIR}")
    endif()
    if(PYPACK_QUIET)
        set(${PACKAGE}_FIND_QUIETLY TRUE)
    else()
        set(${PACKAGE}_FIND_QUIETLY FALSE)
    endif()

    execute_process(
        COMMAND ${LOCALPYTHON} -c
            "import ${PACKAGE};print(${PACKAGE}.__version__)"
        WORKING_DIRECTORY "${PYPACK_WORKING_DIRECTORY}"
        RESULT_VARIABLE PACKAGE_WAS_FOUND
        ERROR_VARIABLE ERROR
        OUTPUT_VARIABLE OUTPUT
    )
    if(PACKAGE_WAS_FOUND EQUAL 0)
        string(STRIP "${OUTPUT}" string_version)
        set(arguments
            "import ${PACKAGE}"
            "from os.path import dirname"
            "print(dirname(${PACKAGE}.__file__))"
        )
        execute_process(
            COMMAND ${LOCALPYTHON} -c "${arguments}"
            WORKING_DIRECTORY "${PYPACK_WORKING_DIRECTORY}"
            RESULT_VARIABLE LOCATION_WAS_FOUND
            ERROR_VARIABLE ERROR
            OUTPUT_VARIABLE OUTPUT
        )
        if(LOCATION_WAS_FOUND EQUAL 0)
            set(${PACKAGE}_LOCATION ${OUTPUT})
        endif()
    endif()
    find_package_handle_standard_args(${PACKAGE}
        REQUIRED_VARS ${PACKAGE}_LOCATION
        VERSION_VAR string_version
        FAIL_MESSAGE "Python module ${PACKAGE} could not be found."
    )
    if(NOT "${PACKAGE}" STREQUAL "${PACKAGE_UPPER}")
        set(${PACKAGE}_FOUND ${${PACKAGE_UPPER}_FOUND} PARENT_SCOPE)
    endif()
    if(${PACKAGE_UPPER}_FOUND)
        set(${PACKAGE}_LOCATION "${${PACKAGE}_LOCATION}" PARENT_SCOPE)
        set(${PACKAGE}_VERSION_STRING "${string_version}" PARENT_SCOPE)
    else()
        set(${PACKAGE}_LOCATION "${PACKAGE}_LOCATION-NOTFOUND" PARENT_SCOPE)
    endif()
endfunction()
