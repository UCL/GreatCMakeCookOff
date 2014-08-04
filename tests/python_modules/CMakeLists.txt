include(EnvironmentScript)
include(PythonPackageLookup)

# Make it possible to run tests.
set(LOCAL_PYTHON_EXECUTABLE "${PROJECT_BINARY_DIR}/localpython.sh")
create_environment_script(
    EXECUTABLE "${PYTHON_EXECUTABLE}"
    PATH "${LOCAL_PYTHON_EXECUTABLE}"
    PYTHON
)
add_to_python_path("${EXTERNAL_ROOT}/python")
add_to_python_path(
    "${CMAKE_CURRENT_BINARY_DIR}/fake_project_builds/extension_build/python_binary")
lookup_python_package(pytest REQUIRED PATH "${EXTERNAL_ROOT}/python")
find_program(PYTEST_EXEC py.test PATH "${EXTERNAL_ROOT}/python" REQUIRED)

cmake_test(pure_build NOEXEC --build-target install)
cmake_test(pure_tests)
set_tests_properties(cmake_test_pure_tests PROPERTIES
    DEPENDS cmake_tests_pure_build)

cmake_test(extension_build NOEXEC --build-target install)
add_test(NAME python_extension
    COMMAND ${LOCAL_PYTHON_EXECUTABLE} ${PYTEST_EXEC} test_extension.py
    WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
)
set_tests_properties(python_extension PROPERTIES
    DEPENDS cmake_test_extension_build)
cmake_test(extension_files)
set_tests_properties(cmake_test_extension_files PROPERTIES
    DEPENDS cmake_test_extension_build)


set_tests_properties(
    cmake_test_pure_tests cmake_test_pure_build
    cmake_test_extension_build python_extension
    cmake_test_extension_files
    PROPERTIES LABELS "python"
)
