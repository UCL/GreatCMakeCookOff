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
endif()
file(WRITE "${PROJECT_SOURCE_DIR}/package/test_this.py"
    "def test_something():\n"
    "   assert True"
)
file(WRITE "${PROJECT_SOURCE_DIR}/package/test_that.py"
    "def test_that():\n"
    "   assert False"
)
file(WRITE "${PROJECT_SOURCE_DIR}/package/conftest.py"
    "from py.test import fixture\n"
    "def pytest_addoption(parser):\n"
    "    parser.addoption('--cmdl', action='store')\n\n\n"
    "@fixture\n"
    "def cmdl(request):\n"
    "    return request.config.getoption('--cmdl')\n"
)
file(WRITE "${PROJECT_SOURCE_DIR}/package/test_cmdl.py"
    "def test_that(cmdl):\n"
    "   assert cmdl == 'an option'"
)

setup_pytest("@EXTERNAL_ROOT@/python" "@PROJECT_BINARY_DIR@/py.test.sh")

add_pytest(package/test_*.py
    EXCLUDE package/test_cmdl.py
    PREFIX "package."
)
add_pytest(package/test_cmdl.py PREFIX "package." CMDLINE "--cmdl=an option")
add_pytest(package/test_cmdl.py PREFIX "package.fails." CMDLINE "--cmdl=nope")
