find_package(GreatCMakeCookOff NO_MODULE PATHS ${cookoff_path} REQUIRED)
initialize_cookoff()
include(PythonModule)

# install and build paths for fake projects
set(PYTHON_BINARY_DIR "${PROJECT_BINARY_DIR}/python_binary"
    CACHE PATH "" FORCE)
set(PYTHON_PKG_DIR "${PROJECT_BINARY_DIR}/python_install"
    CACHE PATH "" FORCE)

# Create fake sources first
if(NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/confed")
    file(MAKE_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/confed")
endif()
file(WRITE "${CMAKE_CURRENT_SOURCE_DIR}/confed/__init__.in.py"
    "if '\@MEANING_OF_LIFE\@' == '\@%s\@' % 'MEANING_OF_LIFE':\n"
    "   raise RuntimeError('did not configure file')\n"
    "if \@MEANING_OF_LIFE\@ != 42:\n"
    "   raise RuntimeError('did not configure file')\n"
)
file(WRITE "${CMAKE_CURRENT_SOURCE_DIR}/confed/unconfed.py"
    "if '\@MEANING_OF_LIFE\@' != '\@%s\@' % 'MEANING_OF_LIFE':\n"
    "   raise RuntimeError('Should not configure file')\n"
    "if '\@MEANING_OF_LIFE\@' == '42':\n"
    "   raise RuntimeError('Should not configure file')\n"
)

set(MEANING_OF_LIFE 42)
add_python_module("confed" "${CMAKE_CURRENT_SOURCE_DIR}/confed/*.py")

if(NOT EXISTS "${CMAKE_CURRENT_BINARY_DIR}/confed/__init__.py")
    message(FATAL_ERROR "Did not configure file")
endif()
if(EXISTS "${CMAKE_CURRENT_BINARY_DIR}/confed/unconfed.py")
    message(FATAL_ERROR "Normal file should not have been configured")
endif()
