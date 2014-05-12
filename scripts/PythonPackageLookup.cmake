# Checks if a python package exists, otherwise installs it

# Adds packages to a python directory
include(CMakeParseArguments)
include(PythonPackage)
include(PackageLookup)

function(lookup_python_package package)
    cmake_parse_arguments(lpp "QUIET;REQUIRED" "VERSION;PATH" "" ${ARGN})
    if(NOT lpp_PATH)
        set(lpp_PATH "${EXTERNAL_ROOT}/python")
    endif()
    set(arguments "")
    if(lpp_VERSION)
        set(arguments "${arguments} VERSION ${lpp_VERSION}")
    endif()
    if(lpp_QUIET)
        set(arguments "${arguments} QUIET")
    endif()
    find_python_package(${package} ${arguments})
    if(${package}_FOUND)
        return()
    elseif(NOT lpp_QUIET)
        message(STATUS "Will now attempt to install ${package} locally")
    endif()

    # check we have setuptools
    find_python_package(setuptools QUIET)
    if(NOT setuptools_FOUND)
        if(lpp_REQUIRED)
            message(FATAL_ERROR "setuptools not available, cannot install ${package}")
        elseif(NOT lpp_QUIET)
            message(STATUS "setuptools not available, cannot install ${package}")
        endif()
        return()
    endif()

    if(NOT EXISTS "${lpp_PATH}")
        file(MAKE_DIRECTORY "${lpp_PATH}")
    endif()
    file(WRITE "${EXTERNAL_ROOT}/install_${package}.py"
        "from os import environ\n"
        "if 'PYTHONPATH' not in environ:\n"
        "    environ['PYTHONPATH'] = '${lpp_PATH}'\n"
        "elif len(environ['PYTHONPATH']) == 0:\n"
        "    environ['PYTHONPATH'] = '${lpp_PATH}'\n"
        "else:\n"
        "    environ['PYTHONPATH'] += ':${lpp_PATH}'\n"
        "from sys import path, exit\n"
        "path.append('${lpp_PATH}')\n"
        "from setuptools.command.easy_install import main as install\n"
        "result = install(['--install-dir', path[-1], '${package}'])\n"
        "exit(0 if result == True else 1)\n"
    )
    execute_process(
        COMMAND ${PYTHON_EXECUTABLE} "${EXTERNAL_ROOT}/install_${package}.py"
        RESULT_VARIABLE result
        ERROR_VARIABLE error
        OUTPUT_VARIABLE output
    )
    if(lpp_REQUIRED)
        set(arguments "${arguments} REQUIRED")
    endif()
    find_python_package(${package} REQUIRED)
endfunction()
