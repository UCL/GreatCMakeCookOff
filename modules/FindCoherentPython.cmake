# Finds python interpreter and library.
# Tries to make sure one fits the other
unset(required)
if(CoherentPython_FIND_REQUIRED)
    set(required REQUIRED)
endif()
unset(quietly)
if(CoherentPython_FIND_QUIETLY)
    set(quietly QUIET)
endif()
unset(version)
if(CoherentPython_FIND_VERSION)
    set(version ${CoherentPython_FIND_VERSION})
endif()
unset(exact)
if(CoherentPython_FIND_VERSION_EXACT)
    set(exact EXACT)
endif()

# Finds python interpreter first
find_package(PythonInterp ${version} ${exact} ${required} ${qietly})
if(NOT PYTHONINTERP_FOUND)
    return()
endif()

# Finds prefix from python executable itself, then adds
# relevant paths to relevant cmake variables so that
# find_package(PythonLibs) actually works
if(NOT CMAKE_CROSS_COMPILING)
    execute_process(
      COMMAND ${PYTHON_EXECUTABLE} -c "import sys; print(sys.prefix)"
      OUTPUT_VARIABLE PYTHON_INTERP_PREFIX
    )
    string(STRIP "${PYTHON_INTERP_PREFIX}" PYTHON_INTERP_PREFIX)
    list(INSERT CMAKE_PREFIX_PATH 0 ${PYTHON_INTERP_PREFIX})
    if("${PYTHON_INTERP_PREFIX}" MATCHES ".*/Frameworks/.*")
        string(REGEX REPLACE
            "(.*/Frameworks)/.*" "\\1"
            framework_path
            "${PYTHON_INTERP_PREFIX}"
        )
        list(INSERT CMAKE_FRAMEWORK_PATH 0 "${framework_path}")
    endif()
endif()

find_package(PythonLibs ${PYTHON_VERSION_STRING} EXACT ${required} ${quiet})
