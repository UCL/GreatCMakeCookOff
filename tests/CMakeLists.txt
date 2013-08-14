cmake_minimum_required(VERSION 2.8.3 FATAL_ERROR)
project(CPP11_TEST)

enable_testing()

function(cmake_test testname)
  add_test(cmake_test_${testname} 
           ${CMAKE_COMMAND} -Doutdir=${CMAKE_CURRENT_BINARY_DIR}
                            -Dindir=${CMAKE_CURRENT_SOURCE_DIR}
                            -Dindir=${CMAKE_CURRENT_SOURCE_DIR}
                            -Dtestname=${testname}
                            -Dcookoff_path=${CMAKE_SOURCE_DIR}/..
                            -P ${PROJECT_SOURCE_DIR}/run_cmake_test.cmake)
endfunction(cmake_test)

add_subdirectory(cpp11)
