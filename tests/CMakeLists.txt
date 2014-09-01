cmake_test(checkisnan SOURCE)
cmake_test(checkcpp11flags)
cmake_test(local_include)
cmake_test(self_lookup)
cmake_test(cached_variables)
cmake_test(delete_variables)
cmake_test(passon_variables)
cmake_test(python_package)
cmake_test(add_to_path)
cmake_test(create_environment_script)
cmake_test(output_filename)
cmake_test(configure_files)

find_program(Hg_EXECUTABLE hg)
if("${CMAKE_VERSION}" VERSION_GREATER 2.8.9 AND Hg_EXECUTABLE)
    cmake_test(lookup_eigen SOURCE -DLOOKUP_EIGEN=TRUE)
    cmake_test(use_external)
    cmake_test(use_external_download_by_default)
    set_tests_properties(
        cmake_test_use_external cmake_test_use_external_download_by_default
        PROPERTIES DEPENDS cmake_test_lookup_eigen
    )
endif()
find_program(svn_EXECUTABLE svn)
if(svn_EXECUTABLE)
    cmake_test(addgtest NOEXEC SOURCE
        --test-command ${CMAKE_MAKE_PROGRAM} test)
endif()

add_subdirectory(cpp11)
add_subdirectory(copy_files)
add_subdirectory(python_modules)
add_subdirectory(py.test)
add_subdirectory(mako)
