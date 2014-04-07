# Immediately creates a directory
function(mkdir directory)
    if(NOT EXISTS "${directory}")
        execute_process(
            COMMAND ${CMAKE_COMMAND} -E make_directory ${directory}
            OUTPUT_QUIET
        )
    endif()
endfunction()

# Immediately creates a symbolic link between two files
function(symlink FROM TO)
    if(NOT EXISTS "${FROM}")
        return()
    endif()
    if(EXISTS "${TO}")
        return()
    endif()
    if(WIN32)
        set(linkme mklink)
        if(IS_DIRECTORY "${FROM}")
          set(argument "/d")
        else()
          set(argument "")
        endif()
    else()
        set(linkme "ln")
        set(argument "-s")
    endif()
    get_filename_component(WD "${TO}" PATH)
    get_filename_component(TO "${TO}" NAME)
    execute_process(COMMAND ${linkme} ${argument} ${FROM} ${TO}
        WORKING_DIRECTORY ${WD}
    )
endfunction()
