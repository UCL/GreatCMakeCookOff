# Creates a python virtual environment in the build directory
# This python environment can be accessed via `LOCAL_PYTHON_EXECUTABLE`
# Furthermore, invoking pip_install(something LOCAL) will make sure to install in the local
# environment, leaving the system untouched.
# Finally, a special function `add_to_python_path` can be used to add paths to the local
# environment. In practice, it creates a file "pypaths" in the build directory, where each line is
# an additional directory.
# Similarly, a `add_to_ld_path` will add paths to an "ldpaths" file. These paths will be added to
# `LD_LIBRARY_PATH` (and `DYLD_LIBRARY_PATH`) when executing the local python script.
# For debugging ease on unixes, a link to the virtual environment is created in the main build
# directory, called `localpython`.
find_package(PythonInterp)
include(utilities)
include(PythonPackage)

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
function(add_to_python_path PATH)
    _add_to_a_path("${PROJECT_BINARY_DIR}/pypaths" "${PATH}")
endfunction()
function(add_to_ld_path PATH)
    _add_to_a_path("${PROJECT_BINARY_DIR}/ldpaths" "${PATH}")
endfunction()

function(_create_virtualenv)
    execute_process(
        COMMAND ${PYTHON_EXECUTABLE} -m virtualenv
            --system-site-packages ${VIRTUALENV_DIRECTORY}
        RESULT_VARIABLE RESULT
        ERROR_VARIABLE ERROR
        OUTPUT_VARIABLE OUTPUT
    )
    if(NOT RESULT EQUAL 0)
        message(STATUS "${OUTPUT}")
        message(STATUS "${ERROR}")
        message(FATAL_ERROR "Could not create virtual environment")
    endif()
endfunction()

find_python_package(virtualenv REQUIRED)
set(VIRTUALENV_DIRECTORY ${CMAKE_BINARY_DIR}/external/virtualenv
    CACHE INTERNAL "Path to virtualenv" )

_create_virtualenv()

set(_LOCAL_PYTHON_EXECUTABLE "${VIRTUALENV_DIRECTORY}/bin/python")
# Adds a bash script to call python with all the right paths set
# Makes it easy to debug and test
if(UNIX)
    set(LOCAL_PYTHON_EXECUTABLE "${PROJECT_BINARY_DIR}/localpython.sh")
    find_program(BASH_EXECUTABLE bash)
    find_program(ENV_EXECUTABLE env)
    set(EXECUTABLE "${_LOCAL_PYTHON_EXECUTABLE}")
    configure_file("${CMAKE_CURRENT_LIST_DIR}/localbash.in.sh"
        "${PROJECT_BINARY_DIR}/CMakeFiles/localpython.sh"
        @ONLY
    )
    file(COPY "${PROJECT_BINARY_DIR}/CMakeFiles/localpython.sh"
        DESTINATION ${PROJECT_BINARY_DIR}
        FILE_PERMISSIONS OWNER_EXECUTE OWNER_WRITE OWNER_READ
    )
endif()

function(add_package_to_virtualenv PACKAGE)
    find_python_package(${PACKAGE} LOCAL)
    if(NOT ${PACKAGE}_FOUND)
       execute_process(
           COMMAND ${PROJECT_BINARY_DIR}/localpython -m pip install --upgrade ${PACKAGE}
       )
       find_python_package(${PACKAGE} LOCAL)
   endif()
endfunction()
