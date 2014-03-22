cmake_test(checkisnan SOURCE)
cmake_test(checkcpp11flags)
cmake_test(addgtest NOEXEC SOURCE --test-command ${CMAKE_MAKE_PROGRAM} test)
cmake_test(local_include)

add_subdirectory(cpp11)
