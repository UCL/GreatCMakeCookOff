# Adds the ability to "look-up" a package, e.g. find it on the system,
# or fetch it from the web and install it.
# See https://github.com/UCL/GreatCMakeCookOff/wiki for information

# Sets location where external project are included
if(NOT EXTERNAL_ROOT)
  set(EXTERNAL_ROOT ${CMAKE_BINARY_DIR}/external)
endif(NOT EXTERNAL_ROOT)
# Makes sure external projects are found by cmake
list(APPEND CMAKE_PREFIX_PATH ${EXTERNAL_ROOT})

include(Utilities)
add_to_envvar(PKG_CONFIG_PATH "${EXTERNAL_ROOT}/lib/pkgconfig" PREPEND OS UNIX)
add_to_envvar(PKG_CONFIG_PATH "${EXTERNAL_ROOT}/lib64/pkgconfig" PREPEND OS UNIX)
add_to_envvar(LD_LIBRARY_PATH "${EXTERNAL_ROOT}/lib" PREPEND OS UNIX)
add_to_envvar(LD_LIBRARY_PATH "${EXTERNAL_ROOT}/lib64" PREPEND OS UNIX)
add_to_envvar(DYLD_LIBRARY_PATH "${EXTERNAL_ROOT}/lib" PREPEND OS APPLE)
add_to_envvar(DYLD_LIBRARY_PATH "${EXTERNAL_ROOT}/lib64" PREPEND OS APPLE)

# Adds a target for all external projects, so they can be made prior to others.
if(NOT TARGET lookup_dependencies)
    add_custom_target(lookup_dependencies ALL)
endif()

include(FindPackageHandleStandardArgs)
include(ExternalProject)

function(_find_lookup_recipe package OUTVAR)
    foreach(path ${CMAKE_MODULE_PATH})
      list(APPEND cmake_paths ${path}/${package})
    endforeach()
    set(LOOKUP_RECIPE LOOKUP_RECIPE-NOTFOUND)
    foreach(filename ${package}-lookup.cmake LookUp${package}.cmake)
        find_path(LOOKUP_RECIPE ${filename}
            PATHS ${CMAKE_LOOKUP_PATH} ${CMAKE_MODULE_PATH} ${cmake_paths}
            NO_DEFAULT_PATH
        )
        if(LOOKUP_RECIPE)
            set(${OUTVAR}_DIR "${LOOKUP_RECIPE}" PARENT_SCOPE)
            set(${OUTVAR}_FILE "${LOOKUP_RECIPE}/${filename}" PARENT_SCOPE)
            return()
        endif()
    endforeach()

    if(NOT LOOKUP_RECIPE)
        find_path(LOOKUP_RECIPE lookup.cmake
            PATHS ${cmake_paths}
            NO_DEFAULT_PATH
        )
    endif()

    if(LOOKUP_RECIPE)
      set(${OUTVAR}_DIR "${LOOKUP_RECIPE}" PARENT_SCOPE)
      set(${OUTVAR}_FILE "${LOOKUP_RECIPE}/lookup.cmake" PARENT_SCOPE)
    endif()
endfunction()

macro(_get_sane_name name OUTVAR)
    string(REGEX REPLACE "\\-" "_" ${OUTVAR} "${name}")
endmacro()

# Changes/unchanges the root path
# Makes it possible to look for packages stricly inside the root
macro(_set_root_path PATH TYPE)
    foreach(save MODE_PACKAGE MODE_INCLUDE MODE_PROGRAM MODE_LIBRARY)
        set(_save_root_path_${save} ${CMAKE_FIND_ROOT_PATH_${save}})
        set(CMAKE_FIND_ROOT_PATH_${save} ${TYPE})
    endforeach()
    set(_save_root_path "${CMAKE_FIND_ROOT_PATH}")
    set(CMAKE_FIND_ROOT_PATH "${PATH}")
    foreach(save MODE_PACKAGE MODE_INCLUDE MODE_PROGRAM MODE_LIBRARY)
    endforeach()
endmacro()

# Unchanges the root path
macro(_unset_root_path)
    foreach(save MODE_PACKAGE MODE_INCLUDE MODE_PROGRAM MODE_LIBRARY)
        set(CMAKE_FIND_ROOT_PATH_${save} ${_save_root_path_${save}})
    endforeach()
    set(CMAKE_FIND_ROOT_PATH "${_save_root_path}")
endmacro()

# Looks for a lookup package file and includes it.
macro(lookup_package package)
    set(solitos "DOWNLOAD_BY_DEFAULT;REQUIRED;QUIET;KEEP;NOFIND;CHECK_EXTERNAL")
    set(multiplos "ARGUMENTS;COMPONENTS")
    cmake_parse_arguments(${package} "${solitos}" "" "${multiplos}" ${ARGN})

    # Reappends components
    if(${package}_COMPONENTS)
        list(APPEND ${package}_UNPARSED_ARGUMENTS COMPONENTS)
        list(APPEND ${package}_UNPARSED_ARGUMENTS ${${package}_COMPONENTS})
    endif()
    # Check whether recursive
    unset(recursive)
    _get_sane_name(${package} SANENAME)
    if(${SANENAME}_RECURSIVE)
        set(recursive TRUE)
        if(${package}_NOFIND)
            set(${package}_FOUND TRUE CACHE BOOL "")
        endif()
    endif()
    # First try and find package (unless downloading by default)
    set(dolook TRUE)
    if(${package}_DOWNLOAD_BY_DEFAULT AND NOT recursive)
        if(${package}_CHECK_EXTERNAL)
            set(do_rootchange TRUE)
        else()
            set(dolook FALSE)
        endif()
    endif()
    if(${package}_NOFIND)
        set(dolook FALSE)
    endif()
    # Figure out whether to add REQUIRED and QUIET keywords
    set(required "")
    if(recursive AND ${package}_REQUIRED)
        set(required REQUIRED)
    endif()
    set(quiet "")
    if(${package}_QIET)
        set(quiet QUIET)
    elseif(NOT recursive AND NOT do_rootchange)
        set(quiet QUIET)
    endif()
    if(dolook)
        if(do_rootchange)
            _set_root_path("${EXTERNAL_ROOT}" ONLY)
        endif()
        find_package(${package} ${${package}_UNPARSED_ARGUMENTS}
            ${required} ${quiet}
        )
        if(do_rootchange)
            _unset_root_path()
            unset(do_rootchange)
        endif()
    endif()
    # Sets lower and upper case versions.
    # Otherwise some package will be registered as not found.
    # This is a problem with changing cmake practices.
    string(TOUPPER "${package}" PACKAGE)
    if(${PACKAGE}_FOUND AND NOT "${package}" STREQUAL "${PACKAGE}")
        set(${package}_FOUND ${${PACKAGE}_FOUND})
    endif()
    # If package is not found, then look for a recipe to download and build it
    if(NOT ${package}_FOUND OR ${package}_LOOKUP_BUILD)
        _find_lookup_recipe(${package} ${package}_LOOKUP_RECIPE)
        if(NOT ${package}_LOOKUP_RECIPE_FILE)
            # Checks if package is required
            set(msg "Could not find recipe to lookup "
                    "${package} -- ${${package}_RECIPE_DIR}")
            if(${package}_REQUIRED)
                message(FATAL_ERROR ${msg})
            elseif(NOT ${package}_QUIET)
                message(STATUS ${msg})
            endif()
        else()
            if(NOT ${package}_QUIET AND NOT ${package}_DOWNLOAD_BY_DEFAULT)
                message(STATUS "Will attempt to download and install ${package}")
            elseif(NOT ${package}_QUIET)
                message(STATUS "Will download, build,"
                   " and install a local version of ${package}")
            endif()
            set(CURRENT_LOOKUP_DIRECTORY "${${package}_LOOKUP_RECIPE_DIR}")
            if(${package}_KEEP)
                set(${package}_LOOKUP_BUILD TRUE CACHE BOOL
                    "Whether package is obtained from a lookup build")
            else()
                set(${package}_LOOKUP_BUILD FALSE CACHE BOOL
                    "Whether package is obtained from a lookup build")
            endif()
            include(${${package}_LOOKUP_RECIPE_FILE})
            unset(CURRENT_LOOKUP_DIRECTORY)
            add_dependencies(lookup_dependencies ${package})
        endif()
    endif()
endmacro()

# Makes target depend on external dependencies
macro(depends_on_lookups TARGET)
    add_dependencies(${TARGET} lookup_dependencies)
endmacro()

# Adds an external step to an external project to rerun cmake
macro(add_recursive_cmake_step name)
    cmake_parse_arguments(recursive "NOCHECK" "FOUND_VAR;PACKAGE_NAME" "" ${ARGN})
    set(recurse_name "${name}")
    if(recursive_PACKAGE_NAME)
        set(recurse_name "${recursive_PACKAGE_NAME}")
    endif()
    set(found_var ${name}_FOUND)
    if(recursive_FOUND_VAR)
        set(found_var ${recursive_FOUND_VAR})
    endif()

    # Only add recurse step if package not found already.
    # Once the package has been found and configured,
    # the locations and such should not change, so
    # there is no need for a recursive cmake step.
    if(NOT DEFINED ${found_var} OR NOT ${${found_var}})
        _get_sane_name(${recurse_name} SANENAME)
        set(cmakefile "${PROJECT_BINARY_DIR}/CMakeFiles/external")
        set(cmakefile "${cmakefile}/${name}_recursive.cmake")
        file(WRITE "${cmakefile}"
            "set(CMAKE_PROGRAM_PATH \"${EXTERNAL_ROOT}/bin\" CACHE PATH \"\")\n"
            "set(CMAKE_LIBRARY_PATH \"${EXTERNAL_ROOT}/lib\" CACHE PATH \"\")\n"
            "set(CMAKE_INCLUDE_PATH \"${EXTERNAL_ROOT}/include\" CACHE PATH \"\")\n"
            "set(CMAKE_PREFIX_PATH \"${EXTERNAL_ROOT}\" CACHE PATH \"\")\n"
            "set(${SANENAME}_RECURSIVE TRUE CACHE INTERNAL \"\")\n"
        )
        if(NOT recursive_NOCHECK)
            file(APPEND "${cmakefile}"
                "set(${SANENAME}_REQUIREDONRECURSE TRUE CACHE INTERNAL \"\")\n"
            )
        endif()
        ExternalProject_Add_Step(
            ${name} reCMake
            COMMAND ${CMAKE_COMMAND} -C "${cmakefile}" --no-varn-unused-cli "${CMAKE_SOURCE_DIR}"
            WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
            ${recursive_UNPARSED_ARGUMENTS}
        )
        if(${${SANENAME}_REQUIREDONRECURSE})
            if(NOT ${found_var} OR "${${found_var}}" STREQUAL "")
                unset(${SANENAME}_REQUIREDONRECURSE CACHE)
                message(FATAL_ERROR "[${name}] Could not be downloaded and installed")
            endif()
        endif()
        # Sets a variable saying we are building this source externally
        set(${name}_BUILT_AS_EXTERNAL_PROJECT TRUE)
    endif()
endmacro()

# Avoids anoying cmake warning, by actually using the variables.
# The will be if the appropriate find_* is used. But won't be otherwise.
if(CMAKE_PROGRAM_PATH)
endif()
if(CMAKE_LIBRARY_PATH)
endif()
if(CMAKE_INCLUDE_PATH)
endif()

