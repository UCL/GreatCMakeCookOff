find_package(GreatCMakeCookOff NO_MODULE PATHS ${cookoff_path} REQUIRED)
initialize_cookoff()
include(AddPyTest)
enable_testing()

# install and build paths for fake projects
set(PYTHON_BINARY_DIR "${PROJECT_BINARY_DIR}/python_binary"
    CACHE PATH "" FORCE)
set(PYTHON_PKG_DIR "${PROJECT_BINARY_DIR}/python_install"
    CACHE PATH "" FORCE)
set(LOCAL_PYTHON_EXECUTABLE "@PROJECT_BINARY_DIR@/localpython.sh")

# Create fake sources first
if(NOT EXISTS "${PROJECT_SOURCE_DIR}/package")
    file(MAKE_DIRECTORY "${PROJECT_SOURCE_DIR}/package")
    file(WRITE "${PROJECT_SOURCE_DIR}/package/test_this.py"
        "# Fake dummy package\n"
        "def test_something():\n"
        "   assert True"
    )
    file(WRITE "${PROJECT_SOURCE_DIR}/package/test_that.py"
        "# Fake dummy package\n"
        "def test_that():\n"
        "   assert False"
    )
endif()

add_pytest(package/test_*.py PREFIX "package." CMDLINE --verbose)
