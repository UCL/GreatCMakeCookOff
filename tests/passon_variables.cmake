find_package(GreatCMakeCookOff NO_MODULE PATHS ${cookoff_path} REQUIRED)
initialize_cookoff()
include(PassonVariables)

set(thisvar_zero "${CMAKE_CURRENT_BINARY_DIR}/hello" CACHE PATH "something")
set(thisvar_two True CACHE BOOL "something" FORCE)
set(othervar_one 2 CACHE STRING "something" FORCE)
set(othervar_two 2 CACHE INTERNAL "something" FORCE)
set(othervarone 3 CACHE PATH "something" FORCE)
passon_variables(thispackage
  FILENAME "${CMAKE_CURRENT_BINARY_DIR}/thispackage.cmake"
  PUBLIC
  PATTERNS ".*var_.*"
)

file(WRITE "${CMAKE_BINARY_DIR}/test.cmake"
    "include(thispackage.cmake)\n"
    "if(NOT DEFINED thisvar_zero)\n"
    "  message(FATAL_ERROR \"thisvar_zero undefined\")\n"
    "endif()\n"
    "if(NOT thisvar_zero STREQUAL \"${CMAKE_CURRENT_BINARY_DIR}/hello\")\n"
    "  message(FATAL_ERROR \"wrong value for thisvar_zero\")\n"
    "endif()\n"
    "if(NOT DEFINED thisvar_two)\n"
    "  message(FATAL_ERROR \"thisvar_two undefined\")\n"
    "endif()\n"
    "if(NOT thisvar_two)\n"
    "  message(FATAL_ERROR \"wrong value for thisvar_two\")\n"
    "endif()\n"
    "if(NOT DEFINED othervar_one)\n"
    "  message(FATAL_ERROR \"othervar_one undefined\")\n"
    "endif()\n"
    "if(NOT othervar_one EQUAL 2)\n"
    "  message(FATAL_ERROR \"wrong value for othervar_one\")\n"
    "endif()\n"
    "if(DEFINED othervar_two)\n"
    "  message(FATAL_ERROR \"othervar_two defined\")\n"
    "endif()\n"
    "if(DEFINED othervarone)\n"
    "  message(FATAL_ERROR \"othervarone defined\")\n"
    "endif()\n"
)

execute_process(
    COMMAND ${CMAKE_COMMAND} -P "${CMAKE_BINARY_DIR}/test.cmake"
    RESULT_VARIABLE result
)
if(NOT result EQUAL 0)
  message(FATAL_ERROR "test failed -- ${result}")
endif()
