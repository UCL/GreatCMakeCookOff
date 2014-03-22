find_package(GreatCMakeCookOff CONFIG PATHS ${cookoff_path} REQUIRED)
initialize_cookoff()
find_package(Julia)
include(CheckIsNan)
if(NOT NORECURSE)
    # Rerun without failing
    execute_process(
        COMMAND ${CMAKE_COMMAND} -DNORECURSE=TRUE
                                 -Dcookoff_path=${cookoff_path}
                                 ${PROJECT_SOURCE_DIR}
        WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
        RESULT_VARIABLE DID_RERUN
        OUTPUT_VARIABLE OUTPUT
        ERROR_VARIABLE ERROR
    )
    if(NOT DID_RERUN EQUAL 0)
        message(STATUS "Output:\n${OUTPUT}")
        message(STATUS "Error:\n${ERROR}")
        message(FATAL_ERROR "COULD NOT RERUN ${DID_RERUN}")
    endif()
    # Rerun with expected failure
    execute_process(
        COMMAND ${CMAKE_COMMAND} -DNORECURSE=TRUE
                                 -Dcookoff_path=${cookoff_path}
                                 -DDOFAILNOW=TRUE
                                 ${PROJECT_SOURCE_DIR}
        WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
        RESULT_VARIABLE DID_RERUN
        OUTPUT_VARIABLE OUTPUT
        ERROR_VARIABLE ERROR
    )
    if(DID_RERUN EQUAL 0)
        message(STATUS "Output:\n${OUTPUT}")
        message(STATUS "Error:\n${ERROR}")
        message(FATAL_ERROR "Expected rerun to fail")
    endif()
elseif(NOT DOFAILNOW)
    find_package(Eigen)
else()
    message(FATAL_ERROR "Should fail here")
endif()
