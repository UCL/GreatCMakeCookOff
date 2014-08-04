include(FindPackageHandleStandardArgs)
include(PythonInstall)
include(TargetCopyFiles)
include(EnvironmentScript)

if(NOT PYTHON_BINARY_DIR)
    set(PYTHON_BINARY_DIR "${PROJECT_BINARY_DIR}/python_package"
        CACHE PATH "Location of python package in build tree")
endif()
add_to_python_path(${PYTHON_BINARY_DIR})

function(_pm_location_and_name module)
    string(REGEX REPLACE "\\." "/" location "${module}")
    get_filename_component(submodule "${location}" NAME)

    set(submodule ${submodule} PARENT_SCOPE)
    set(location ${location} PARENT_SCOPE)
endfunction()

function(_pm_default)
    if(${module}_NOINSTALL)
        set(do_install FALSE PARENT_SCOPE)
    else()
        set(do_install TRUE PARENT_SCOPE)
    endif()

    unset(excluded)
    if(${module}_EXCLUDE)
        file(GLOB files RELATIVE
            "${CMAKE_CURRENT_SOURCE_DIR}" ${${module}_EXCLUDE})
        list(APPEND excluded ${files})
    endif()

    unset(sources)
    if(NOT "${${module}_SOURCES}" STREQUAL "")
        file(GLOB sources RELATIVE
            "${CMAKE_CURRENT_SOURCE_DIR}" ${${module}_SOURCES})
        if(NOT "${excluded}" STREQUAL "")
            list(REMOVE_ITEM sources ${excluded})
        endif()
        list(REMOVE_DUPLICATES sources)
    endif()

    if("${sources}" STREQUAL "")
        message(FATAL_ERROR "Python module has no sources")
    endif()
    set(ALL_SOURCES ${sources} PARENT_SCOPE)
endfunction()

function(_pm_filter_list output input)
    unset(result)
    foreach(filename ${${input}})
        foreach(pattern ${ARGN})
            if("${filename}" MATCHES "${pattern}")
                list(APPEND result "${filename}")
            endif()
        endforeach()
    endforeach()
    set(${output} ${result} PARENT_SCOPE)
endfunction()

function(_pm_add_fake_init location)
    set(fake_init_file "${PYTHON_BINARY_DIR}/${location}/__init__.py")
    if(NOT EXISTS "${fake_init_file}")
        file(WRITE "${fake_init_file}" "# Empty file added by CMake")
    endif()
    if(do_install)
        install_python(FILES "${fake_init_file}" DESTINATION ${location})
    endif()
endfunction()

function(_pm_add_python_extension module)
    string(REGEX REPLACE "/" "_" ext "ext.${module}")
    cmake_parse_arguments(${ext}
        ""
        "INSTALL;TARGET;LOCATION;EXTENSION"
        "SOURCES;LIBRARIES"
        ${ARGN}
    )
    if("${${ext}_SOURCES}" STREQUAL "")
        return()
    endif()

    include_directories(${PYTHON_INCLUDE_DIRS})
    if(NUMPY_INCLUDE_DIRS)
        include_directories(${NUMPY_INCLUDE_DIRS})
    endif()

    add_library (${${ext}_TARGET}-ext MODULE ${${ext}_SOURCES})
    get_filename_component(location "${${ext}_LOCATION}" PATH)
    target_link_libraries(${${ext}_TARGET}-ext ${PYTHON_LIBRARIES})
    set_target_properties(${${ext}_TARGET}-ext
        PROPERTIES
        OUTPUT_NAME "${${ext}_EXTENSION}"
        PREFIX "" SUFFIX ".so"
        LIBRARY_OUTPUT_DIRECTORY "${PYTHON_BINARY_DIR}/${location}"
    )
    if(${ext}_LIBRARIES)
        target_link_libraries(${${ext}_TARGET}-ext ${${ext}_LIBRARIES})
    endif()
    add_dependencies(${${ext}_TARGET} ${${ext}_TARGET}-ext)

    if(${${ext}_INSTALL})
        install_python(TARGETS ${${ext}_TARGET}-ext DESTINATION "${location}")
    endif()
endfunction()

function(_pm_add_pure_python)
    string(REGEX REPLACE "/" "_" py "py.${module}")
    cmake_parse_arguments(${py}
        ""
        "INSTALL;TARGET;LOCATION"
        "SOURCES"
        ${ARGN}
    )
    if("${${py}_SOURCES}" STREQUAL "")
        return()
    endif()

    file(RELATIVE_PATH targetname_copy "${PROJECT_SOURCE_DIR}"
        "${CMAKE_CURRENT_SOURCE_DIR}")
    string(REGEX REPLACE "( |/)" "_" targetname_copy "${targetname_copy}")
    if("${targetname_copy}" STREQUAL "")
        set(targetname_copy "${${py}_TARGET}-copy")
    else()
        set(targetname_copy "${targetname_copy}-copy")
    endif()

    add_copy_files(${targetname_copy}
        FILES ${${py}_SOURCES}
        DESTINATION "${PYTHON_BINARY_DIR}/${${py}_LOCATION}"
    )
    add_dependencies(${${py}_TARGET} ${targetname_copy})
    if(${${py}_INSTALL})
        install_python(FILES ${${py}_SOURCES} DESTINATION ${${py}_LOCATION})
    endif()
endfunction()

function(_pm_add_headers module)
    string(REGEX REPLACE "/" "_" h "h.${module}")
    cmake_parse_arguments(${h}
        ""
        "INSTALL;LOCATION;DESTINATION"
        "SOURCES"
        ${ARGN}
    )
    if(NOT ${${h}_INSTALL})
        return()
    endif()

    set(headers ${${h}_SOURCES})
    if("${headers}" STREQUAL "")
        return()
    endif()
    list(REMOVE_DUPLICATES headers)

    string(FIND "${module}" "." first_dot)
    if(first_dot EQUAL -1)
        set(base_module ${module})
    else()
        string(SUBSTRING "${module}" 0 ${first_dot} base_module)
    endif()

    set(header_destination ${base_module}/include/${${h}_LOCATION})
    if(${h}_DESTINATION)
        string(REGEX REPLACE "\\." "/" header_destination ${${h}_DESTINATION})
    endif()

    install_python(FILES ${headers}
        DESTINATION ${header_destination}
        COMPONENT dev
    )
endfunction()

function(add_python_module module)

    # Sets submodule, location, and module from module
    _pm_location_and_name(${module})

    # Parses arguments
    cmake_parse_arguments(${module}
        "FAKE_INIT;NOINSTALL;INSTALL"
        "HEADER_DESTINATION;TARGETNAME"
        "SOURCES;HEADERS;EXCLUDE;LIBRARIES"
        ${ARGN}
    )
    list(APPEND ${module}_SOURCES ${${module}_UNPARSED_ARGUMENTS})
    # Sets defaults, do_install, and  ALL_SOURCES
    _pm_default()
    # Figures out C/C++/HEADERS/Python sources
    _pm_filter_list(C_SOURCES ALL_SOURCES ".*\\.c$")
    _pm_filter_list(C_HEADERS ALL_SOURCES ".*\\.h$")
    _pm_filter_list(CPP_SOURCES ALL_SOURCES ".*\\.cpp$" ".*\\.cc$")
    _pm_filter_list(CPP_HEADERS ALL_SOURCES ".*\\.hpp" ".*\\.h")
    _pm_filter_list(PY_SOURCES ALL_SOURCES ".*\\.py$")

    if(C_SOURCES OR CPP_SOURCES)
        if(PY_SOURCES)
            message(FATAL_ERROR "Python and C sources in same call"
                " to add_python_module.\n"
                "Please split into separate calls."
            )
        endif()
    endif()

    set(targetname ${module})
    if(${module}_TARGETNAME)
        set(targetname ${${module}_TARGETNAME})
    endif()

    # Now for the actual meat
    # First creates a global target
    if(NOT TARGET ${targetname})
        add_custom_target(${targetname} ALL)
    endif()

    # First adds fake init if necessary
    if(${${module}_FAKE_INIT})
        _pm_add_fake_init(${location})
    endif()


    # Then compiles an extension if C/C++ sources
    _pm_add_python_extension(${module}
        TARGET ${targetname}
        INSTALL ${do_install}
        EXTENSION ${submodule}
        LOCATION ${location}
        LIBRARIES ${${module}_LIBRARIES}
        SOURCES ${C_SOURCES} ${CPP_SOURCES}
    )

    # Then copy/install pure python files
    _pm_add_pure_python(${module}
        TARGET ${targetname}
        INSTALL ${do_install}
        LOCATION ${location}
        SOURCES ${PY_SOURCES}
    )

    # Then copy/install header files
    _pm_add_headers(${module}
        LOCATION ${location}
        DESTINATION ${${module}_HEADER_DESTINATION}
        SOURCES ${CPP_HEADERS} ${C_HEADERS}
        INSTALL ${do_install}
    )
endfunction()
