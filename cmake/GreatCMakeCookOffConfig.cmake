# Adds subdirectory to CMAKE_MODULE_PATH so the scripts of the GreatCMakeCookOff can be found.
set(GREAT_CMAKE_COOKOFF_MODULE_DIR ${CMAKE_CURRENT_LIST_DIR}/../modules CACHE DOC
    "Path to GreatCMakeCookOff module directory")
set(GREAT_CMAKE_COOKOFF_SCRIPT_DIR ${CMAKE_CURRENT_LIST_DIR}/../scripts CACHE DOC
    "Path to GreatCMakeCookOff script directory")
macro(initialize_cookoff)
    list(APPEND CMAKE_MODULE_PATH ${GREAT_CMAKE_COOKOFF_MODULE_DIR}
        ${GREAT_CMAKE_COOKOFF_SCRIPT_DIR})
endmacro()
