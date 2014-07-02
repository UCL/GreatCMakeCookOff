find_package(GreatCMakeCookOff NO_MODULE PATHS ${cookoff_path} REQUIRED)
initialize_cookoff()
include(PassonVariables)

set(thisvar_zero "${CMAKE_CURRENT_BINARY_DIR}/hello" CACHE PATH "something")
set(thisvar_two True CACHE BOOL "something" FORCE)
set(othervar_one 2 CACHE STRING "something" FORCE)
set(othervar_two 2 CACHE INTERNAL "something" FORCE)
set(othervarone 3 CACHE PATH "something" FORCE)
set(alist 42;this;that CACHE STRING "something" FORCE)
passon_variables(thispackage
  FILENAME "${CMAKE_CURRENT_BINARY_DIR}/thispackage.cmake"
  PUBLIC
  PATTERNS ".*var_.*" alist
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
    "list(LENGTH alist alist_size)\n"
    "if(NOT alist_size EQUAL 3)\n"
    "    message(FATAL_ERROR \"Incorrect list size: \${alist_size} vs 3\")\n"
    "endif()\n"
    "list(GET alist 0 item)\n"
    "if(NOT item EQUAL 42)\n"
    "    message(FATAL_ERROR \"Incorrect first item\")\n"
    "endif()\n"
    "list(GET alist 1 item)\n"
    "if(NOT item STREQUAL \"this\")\n"
    "    message(FATAL_ERROR \"Incorrect second item\")\n"
    "endif()\n"
    "list(GET alist 2 item)\n"
    "if(NOT item STREQUAL \"that\")\n"
    "    message(FATAL_ERROR \"Incorrect third item\")\n"
    "endif()\n"
)

execute_process(
    COMMAND ${CMAKE_COMMAND} -P "${CMAKE_BINARY_DIR}/test.cmake"
    RESULT_VARIABLE result
)
if(NOT result EQUAL 0)
  message(FATAL_ERROR "passon_variables test failed -- ${result}")
endif()
