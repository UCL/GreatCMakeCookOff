function(test_exists test_name)
    execute_process(
        COMMAND ${CMAKE_CTEST_COMMAND} -N -R ${test_name}
        WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/../pytest_build/"
        RESULT_VARIABLE result
        OUTPUT_VARIABLE output
        ERROR_VARIABLE error
    )
    if(NOT result EQUAL 0)
        message(FATAL_ERROR "Could not run ctest command")
    endif()
    string(REGEX REPLACE ".*Total Tests: ([0-9]+).*" "\\1"
        nb_tests ${output})
    if(NOT nb_tests EQUAL 1)
        message(FATAL_ERROR "Could not find test ${test_name}")
    endif()
endfunction()

function(check_test_passes test_name)
    execute_process(
        COMMAND ${CMAKE_CTEST_COMMAND} -V -R ${test_name}
        WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/../pytest_build/"
        RESULT_VARIABLE result OUTPUT_QUIET ERROR_QUIET
    )
    if(NOT result EQUAL 0)
        message(FATAL_ERROR "test ${test_name} did not pass - ${result}")
    endif()
endfunction()
function(check_test_fails test_name)
    execute_process(
        COMMAND ${CMAKE_CTEST_COMMAND} -R ${test_name}
        WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/../pytest_build/"
        RESULT_VARIABLE result OUTPUT_QUIET ERROR_QUIET
    )
    if(result EQUAL 0)
        message(FATAL_ERROR "test ${test_name} did not fail")
    endif()
endfunction()

test_exists(package.this)
test_exists(package.that)
check_test_passes(package.this)
check_test_fails(package.that)
