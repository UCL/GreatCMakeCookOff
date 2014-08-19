find_package(GreatCMakeCookOff NO_MODULE PATHS ${cookoff_path} REQUIRED)
initialize_cookoff()

# install and build paths for fake projects
set(PYTHON_BINARY_DIR "${PROJECT_BINARY_DIR}/python_binary"
    CACHE PATH "" FORCE)
set(PYTHON_PKG_DIR "${PROJECT_BINARY_DIR}/python_install"
    CACHE PATH "" FORCE)

find_package(CoherentPython)
include(PythonModule)
include(PythonPackageLookup)
include(EnvironmentScript)

set(LOCAL_PYTHON_EXECUTABLE "@CMAKE_CURRENT_BINARY_DIR@/mako_tester.sh")
create_environment_script(
    EXECUTABLE "${PYTHON_EXECUTABLE}"
    PATH "${LOCAL_PYTHON_EXECUTABLE}"
    PYTHON
)
add_to_python_path("@EXTERNAL_ROOT@/python")
add_to_python_path("${PYTHON_BINARY_DIR}")

lookup_python_package(mako REQUIRED PATH "@EXTERNAL_ROOT@/python")
find_program(mako_SCRIPT mako-render HINT "@EXTERNAL_ROOT@/python")

file(WRITE "${CMAKE_CURRENT_SOURCE_DIR}/__init__.mako.py"
    "import other\n"
    "i = 0\n"
    "% for a in ['hello', 'world']:\n"
    "assert '\${a}' == 'hello world'.split()[\${loop.index}]\n"
    "i += 1\n"
    "% endfor\n"
    "assert i == 2\n"
    "assert other.i == 8\n"
)
file(WRITE "${CMAKE_CURRENT_SOURCE_DIR}/other.mako.py"
    "i = 5\n"
    "% for a in ['hello', 'despicable', 'world']:\n"
    "assert '\${a}' == 'hello despicable world'.split()[\${loop.index}]\n"
    "i += 1\n"
    "% endfor\n"
    "assert i == 8\n"
)

add_python_module("makoed" *.mako.py)
