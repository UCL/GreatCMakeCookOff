# - Find the NumPy libraries
# This module finds if NumPy is installed, and sets the following variables
# indicating where it is.
#
# TODO: Update to provide the libraries and paths for linking npymath lib.
#
#  NUMPY_FOUND               - was NumPy found
#  NUMPY_VERSION             - the version of NumPy found as a string
#  NUMPY_VERSION_MAJOR       - the major version number of NumPy
#  NUMPY_VERSION_MINOR       - the minor version number of NumPy
#  NUMPY_VERSION_PATCH       - the patch version number of NumPy
#  NUMPY_VERSION_DECIMAL     - e.g. version 1.6.1 is 10601
#  NUMPY_INCLUDE_DIRS        - path to the NumPy include files

# Modified from script by Continuum Analytics, Inc.

# Finding NumPy involves calling the Python interpreter
if(NumPy_FIND_REQUIRED)
    find_package(PythonInterp REQUIRED)
else()
    find_package(PythonInterp)
endif()

if(NOT PYTHONINTERP_FOUND)
    set(NUMPY_FOUND FALSE)
    return()
endif()

execute_process(COMMAND "${PYTHON_EXECUTABLE}" "-c"
    "import numpy as n; print(n.__version__); print(n.get_include());"
    RESULT_VARIABLE _NUMPY_SEARCH_SUCCESS
    OUTPUT_VARIABLE _NUMPY_VALUES_OUTPUT
    ERROR_VARIABLE _NUMPY_ERROR_VALUE
    OUTPUT_STRIP_TRAILING_WHITESPACE)

if(NOT _NUMPY_SEARCH_SUCCESS MATCHES 0)
    if(NumPy_FIND_REQUIRED)
        message(FATAL_ERROR
            "NumPy import failure:\n${_NUMPY_ERROR_VALUE}")
    endif()
    set(NUMPY_FOUND FALSE)
    return()
endif()

# Convert the process output into a list
string(REGEX REPLACE ";" "\\\\;" _NUMPY_VALUES ${_NUMPY_VALUES_OUTPUT})
string(REGEX REPLACE "\n" ";" _NUMPY_VALUES ${_NUMPY_VALUES})
# Just in case there is unexpected output from the Python command.
list(GET _NUMPY_VALUES -2 NUMPY_VERSION)
list(GET _NUMPY_VALUES -1 NUMPY_INCLUDE_DIRS)

string(REGEX MATCH "^[0-9]+\\.[0-9]+\\.[0-9]+" _VER_CHECK "${NUMPY_VERSION}")
if("${_VER_CHECK}" STREQUAL "")
    # The output from Python was unexpected. Raise an error always
    # here, because we found NumPy, but it appears to be corrupted somehow.
    message(FATAL_ERROR
        "Requested version and include path from NumPy, got instead:\n${_NUMPY_VALUES_OUTPUT}\n")
    return()
endif()

# Make sure all directory separators are '/'
string(REGEX REPLACE "\\\\" "/" NUMPY_INCLUDE_DIRS ${NUMPY_INCLUDE_DIRS})

# Get the major and minor version numbers
string(REGEX REPLACE "\\." ";" _NUMPY_VERSION_LIST ${NUMPY_VERSION})
list(GET _NUMPY_VERSION_LIST 0 NUMPY_VERSION_MAJOR)
list(GET _NUMPY_VERSION_LIST 1 NUMPY_VERSION_MINOR)
list(GET _NUMPY_VERSION_LIST 2 NUMPY_VERSION_PATCH)
string(REGEX MATCH "[0-9]*" NUMPY_VERSION_PATCH ${NUMPY_VERSION_PATCH})
math(EXPR NUMPY_VERSION_DECIMAL
    "(${NUMPY_VERSION_MAJOR} * 10000) + (${NUMPY_VERSION_MINOR} * 100) + ${NUMPY_VERSION_PATCH}")

find_package_message(NUMPY
    "Found NumPy: version \"${NUMPY_VERSION}\" ${NUMPY_INCLUDE_DIRS}"
    "${NUMPY_INCLUDE_DIRS}${NUMPY_VERSION}")

set(NUMPY_FOUND TRUE)

## Now check some features of numpy c api
## This is RSDT stuff
function(numpy_feature_test OUTVARNAME testfilename testname)
  if (NUMPY_INCLUDES) # only if numpy found.

    ## try to compile and run
    ## Using Release flags because MSCrapware fails otherwise.
    try_compile(
      ${OUTVARNAME}
      ${CMAKE_BINARY_DIR}
      ${CMAKE_CURRENT_LIST_DIR}/numpy/${testfilename}
      COMPILE_DEFINITIONS -I${PYTHON_INCLUDE_DIRS}  -I${NUMPY_INCLUDES}
                          -DNPY_NO_DEPRECATED_API=NPY_1_7_API_VERSION
      CMAKE_FLAGS -DLINK_LIBRARIES:STRING=${PYTHON_LIBRARIES}
                  -DCMAKE_CXX_FLAGS_DEBUG:STRING="${CMAKE_CXX_FLAGS_RELEASE}"
                  -DCMAKE_C_FLAGS_DEBUG:STRING="${CMAKE_C_FLAGS_RELEASE}"
                  -DCMAKE_EXE_LINKER_FLAGS_DEBUG:STRING="${CMAKE_EXE_LINKER_FLAGS_RELEASE}"
      OUTPUT_VARIABLE NUMPY_TESTCOMPILE
    )
    ## display results
    if (NOT NUMPY_FIND_QUIETLY)
      message (STATUS "[NumPy] ${testname} = ${${OUTVARNAME}}")
    endif (NOT NUMPY_FIND_QUIETLY)
    set(${OUTVARNAME} ${${OUTVARNAME}} PARENT_SCOPE)
  endif()
endfunction()

numpy_feature_test(NUMPY_NPY_LONG_DOUBLE test_numpy_long_double.c "Long double exists")
numpy_feature_test(NUMPY_NPY_BOOL test_numpy_ubyte.c "Bool is a separate type")
numpy_feature_test(NUMPY_NPY_ARRAY test_numpy_is_noarray.c "NPY_ARRAY_* macros exist")
numpy_feature_test( NUMPY_NPY_ENABLEFLAGS test_numpy_has_enableflags.c
                    "PyArray_ENABLEFLAGS exists" )
