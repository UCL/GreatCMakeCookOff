# First attempts to find the package
set(COOKOFF_DOWNLOAD_DIR ${PROJECT_BINARY_DIR}/external/src/GreatCMakeCookOff)
find_package(GreatCMakeCookOff CONFIG PATHS ${COOKOFF_DOWNLOAD_DIR} QUIET)

# Otherwise attempts to download it.
# Does not use ExternalProject_Add to avoid doing a recursive cmake step.
if(NOT GreatCMakeCookOff_FOUND)
  message(STATUS "[GreatCMakeCookOff] not found. Will attempt to clone it.")

  # Need git for cloning.
  find_package(Git)
  if(NOT GIT_FOUND)
    message(FATAL_ERROR "[Git] not found. Cannot download GreatCMakeCookOff")
  endif()

  # Remove GreatCMakeCookOff directory if it exists
  if(EXISTS ${COOKOFF_DOWNLOAD_DIR})
    execute_process(
      COMMAND ${CMAKE_COMMAND} -E remove_directory ${COOKOFF_DOWNLOAD_DIR}
      OUTPUT_QUIET
    )
  endif()
  execute_process(
    COMMAND ${GIT_EXECUTABLE} clone
         https://github.com/UCL/GreatCMakeCookOff.git
         -b refactor
         ${COOKOFF_DOWNLOAD_DIR}
    RESULT_VARIABLE CLONING_COOKOFF
    OUTPUT_QUIET
    ERROR_VARIABLE CLONING_ERROR
  )

  if(NOT ${CLONING_COOKOFF} EQUAL 0)
    message(STATUS "${CLONING_ERROR}")
    message(FATAL_ERROR "[GreatCMakeCookOff] git cloning failed.")
  else()
    message(STATUS "[GreatCMakeCookOff] downloaded to ${COOKOFF_DOWNLOAD_DIR}")
    find_package(GreatCMakeCookOff CONFIG PATHS ${COOKOFF_DOWNLOAD_DIR} QUIET)
  endif()
  
  set(GreatCMakeCookOff_DIR ${COOKOFF_DOWNLOAD_DIR})
  set(GreatCMakeCookOff_FOUND TRUE)
endif()
unset(COOKOFF_DOWNLOAD_DIR)

# Adds GreatCMakeCookOff to module paths
initialize_cookoff()
