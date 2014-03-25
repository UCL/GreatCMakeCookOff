# Adds a target which simply copies files from one place to another.
# 
# USAGE:
# add_copy_file(
#    <target>                          -- target name
#    [DESTINATION <destination>]       -- Directory where files will be copied
#                                         Defaults to current binary directory
#    [GLOB <glob>]                     -- A glob to find target files to copy
#    [REPLACE <pattern> <replacement>] -- string(REGEX REPLACE) arguments on output filename
#    [FILES <list of files>]           -- list of files to copy. Cannot be used with GLOB or ARGN.
#    [<list of files>]                 -- list of files to copy. Cannot be used with GLOB or FILES.
# )
include(CMakeParseArguments)

function(add_copy_files FILECOPIER_TARGET)
  set(oneValueArgs DESTINATION GLOB)
  set(multiValueArgs REPLACE FILES)
  cmake_parse_arguments(FILECOPIER "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )

  if(NOT FILECOPIER_DESTINATION)
    set(FILECOPIER_DESTINATION ${CMAKE_CURRENT_BINARY_DIR})
  endif()
  if(NOT FILECOPIER_GLOB AND NOT FILECOPIER_FILES)
    set(input_sources ${FILECOPIER_UNPARSED_ARGUMENTS})
  elseif(FILECOPIER_GLOB AND FILECOPIER_FILES)
    message(FATAL_ERROR "copy_files takes one of GLOB or FILES, not both")
  elseif(FILECOPIER_FILES)
    set(input_sources ${FILECOPIER_FILES})
  else()
    file(GLOB input_sources ${FILECOPIER_GLOB})
  endif()
  if(NOT FILECOPIER_TARGET)
    set(copy_target copy)
  else()
    set(copy_target ${FILECOPIER_TARGET})
  endif()

  if(FILECOPIER_REPLACE)
    list(LENGTH FILECOPIER_REPLACE replace_length)
    if(NOT ${replace_length} EQUAL 2)
      message(FATAL_ERROR "copy_files argument REPLACE takes two inputs")
    endif()
    list(GET FILECOPIER_REPLACE 0 PATTERN)
    list(GET FILECOPIER_REPLACE 1 REPLACEMENT)
  endif()

  foreach(input ${input_sources})
    get_filename_component(output ${input} NAME)
    if(NOT "${FILECOPIER_REPLACE}" STREQUAL "")
      string(REGEX REPLACE "${PATTERN}" "${REPLACEMENT}" output ${output})
    endif()
    set(output ${FILECOPIER_DESTINATION}/${output})

    add_custom_command(
      TARGET ${copy_target}
      PRE_BUILD
      COMMAND ${CMAKE_COMMAND} -E copy ${input} ${output}
      DEPENDS ${input}
    )
  endforeach()
endfunction()

