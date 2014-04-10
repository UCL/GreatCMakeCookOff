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
include(Utilities)
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

function(_create_virtualenv call)
    execute_process(
	COMMAND ${call} --system-site-packages ${VIRTUALENV_DIRECTORY}
        RESULT_VARIABLE RESULT
        ERROR_VARIABLE ERROR
        OUTPUT_VARIABLE OUTPUT
    )
    if(NOT "${RESULT}" STREQUAL "0")
        message(STATUS "${RESULT}")
        message(STATUS "${OUTPUT}")
        message(STATUS "${ERROR}")
        message(FATAL_ERROR "Could not create virtual environment")
    endif()
endfunction()

# First check if we have venv in the same directory as python.
# Canopy makes things more difficult.
get_filename_component(python_bin "${PYTHON_EXECUTABLE}" PATH)
find_program(venv_EXECUTABLE venv PATHS "${python_bin}" NO_DEFAULT_PATH)
find_python_package(venv)
find_python_package(virtualenv)

set(VIRTUALENV_DIRECTORY ${CMAKE_BINARY_DIR}/external/virtualenv
    CACHE INTERNAL "Path to virtualenv" )
if(venv_EXECUTABLE)
  _create_virtualenv("${venv_EXECUTABLE}")
elseif(venv_FOUND)
  _create_virtualenv("${PYTHON_EXECUTABLE} -m venv")
elseif(virtualenv_FOUND)
  _create_virtualenv("${PYTHON_EXECUTABLE} -m virtualenv")
else()
  message(FATAL_ERROR "Could find neither venv nor virtualenv")
endif()

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
        # First check if we have venv in the same directory as python.
        # Canopy makes things more difficult.
        get_filename_component(python_bin "${_LOCAL_PYTHON_EXECUTABLE}" PATH)
        find_program(local_pip_EXECUTABLE pip PATHS "${python_bin}" NO_DEFAULT_PATH)
        if(local_pip_EXECUTABLE)
            execute_process(
                COMMAND
                    ${local_pip_EXECUTABLE} install --upgrade ${PACKAGE}
                RESULT_VARIABLE result
                OUTPUT_VARIABLE output
                ERROR_VARIABLE error
            )
        else()
            execute_process(
                COMMAND ${_LOCAL_PYTHON_EXECUTABLE} -m pip install --upgrade ${PACKAGE}
                RESULT_VARIABLE result
                OUTPUT_VARIABLE output
                ERROR_VARIABLE error
            )
        endif()
        if("${result}" STREQUAL "0")
            find_python_package(${PACKAGE} LOCAL)
        else()
            message("${error}")
            message("${output}")
            message(FATAL_ERROR "Could not install ${PACKAGE} -- ${result}")
        endif()
    endif()
endfunction()
