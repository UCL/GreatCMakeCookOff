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
    function(call_python OUTPUT)
       # First tries adding prefix
       execute_process(
         COMMAND ${PYTHON_EXECUTABLE} -c "${ARGN}"
         RESULT_VARIABLE result
         OUTPUT_VARIABLE output
       )
       if(result EQUAL 0)
           string(STRIP "${output}" output)
           set(${OUTPUT} "${output}" PARENT_SCOPE)
       else()
           unset(${OUTPUT} PARENT_SCOPE)
       endif()
    endfunction()
    # First tries adding prefix
    call_python(PYTHON_INTERP_PREFIX "import sys; print(sys.prefix)")
    if(DEFINED PYTHON_INTERP_PREFIX)
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
    # Then tries adding sysconfig.get_python_inc output
    call_python(python_include
	"from distutils.sysconfig import get_python_inc"
        "print(get_python_inc())"
    )
    if(DEFINED python_include)
        set(PYTHON_INCLUDE_DIR "${python_include}" PATH)
    endif()
    # And tries adding sysconfig.get_python_lib output
    call_python(python_lib
	"from distutils.sysconfig import get_python_lib"
        "print(get_python_lib())"
    )
    if(DEFINED python_lib)
        list(INSERT 0 CMAKE_LIBRARY_PATH "${python_lib}")
    endif()
endif()

find_package(PythonLibs ${PYTHON_VERSION_STRING} EXACT ${required} ${quiet})
