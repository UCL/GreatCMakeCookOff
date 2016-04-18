#.rst:
# FindMKL
# ---------
#
# Find Intel Math Kernel Library include dirs and libraries
#
# Use this module by invoking find_package with the form::
#
#   find_package(MKL
#     [version] [EXACT]      # Minimum or EXACT version e.g. 11.3.2,
#     [REQUIRED]             # Fail with error if MKL is not found
#     [COMPONENTS <libs>...] # Cluster libraries by their canonical name e.g.
#     )                      # "ScaLAPACK" for "libmkl_scalapack_{i}lp64.{a,so}"
#
# This module finds headers and requested cluster libraries.  Results are
# reported in variables::
#
#   MKL_FOUND            - True if headers and requested libraries were found
#   MKL_DEFINITIONS      - MKL compiler definitions
#   MKL_INCLUDE_DIRS     - MKL include directories
#   MKL_LIBRARIES        - MKL libraries to be linked
#   MKL_<C>_FOUND        - True if cluster library <C> was found (<C> is
#                          upper-case)
#   MKL_<C>_LIBRARY      - Libraries to link for cluster library <C> (may
#                          include target_link_libraries debug/optimized
#                          keywords)
#   MKL_VERSION          - INTEL_MKL_VERSION value from mkl.h
#   MKL_MAJOR_VERSION    - MKL major version number (X in X.y.z)
#   MKL_MINOR_VERSION    - MKL minor version number (Y in x.Y.z)
#   MKL_PATCH_VERSION    - MKL patch version number (Z in x.y.Z)
#
# This module reads hints about search locations from variables::
#
#   MKL_ROOT             - Preferred installation prefix
#    (or MKLROOT)
#   MKL_INCLUDEDIR       - Preferred include directory e.g. <prefix>/include
#   MKL_LIBRARYDIR       - Preferred library directory e.g. <prefix>/lib
#   MKL_ADDITIONAL_VERSIONS -
#
# and saves search results persistently in CMake cache entries::
#
#   MKL_INCLUDE_DIR         - Directory containing MKL headers
#   MKL_LIBRARY_DIR         - Directory containing MKL libraries
#   MKL_<C>_LIBRARY         - Component <C> library

# This module first searches for mkl.h using the above hint variables (excluding
# MKL_LIBRARYDIR) and saves the result in MKL_INCLUDE_DIR.  Then it searches for
# appropriate interface libraries for the current architecture using dynamic or
# static linking.  Finally it searches for requested cluster libraries using
# the above hints (excluding MKL_INCLUDEDIR and MKL_ADDITIONAL_VERSIONS), "lib"
# directories near MKL_INCLUDE_DIR, and the library name configuration settings
# below.  It saves the library directories in MKL_LIBRARY_DIR and individual
# library locations in MKL_<C>_LIBRARY.
# When one changes settings used by previous searches in the same build
# tree (excluding environment variables) this module discards previous
# search results affected by the changes and searches again.
#
# MKL libraries come in many variants encoded in their file name.
# Users or projects may tell this module which variant to find by
# setting variables::
#
#   MKL_USE_STATIC_LIBS      - Set to ON to force the use of static libraries.
#                              Default is OFF.
#   MKL_XEON_PHI_USAGE_MODEL - Set to "none", "native", "automatic" or
#                              "compiler" to select how the MKL is to use any
#                              Xeon Phi coprocessors found.  Default is "none".
#   MKL_THREADING            - Set to "Sequential", "OpenMP" or "TBB"  to select
#                              threading library.  Default is "OpenMP".
#   MKL_OPENMP               - Set to "Intel", "GNU" or "PGI" to use vendor
#                              OpenMP library.  This setting only has an effect
#                              when MPI_THREADING is"OpenMP".  Default is
#                              "Intel".
#   MKL_MESSAGE_PASSING      - Set to "Intel", "MPICH", "MPICH2", "OpenMPI" or
#                              "SGI" to use a specific MPI library.  This
#                              setting only has an effect when COMPONENTS is
#                              non-empty.  Default is "Intel".
#
# Some combinations of the variants above do not exist (e.g. Using GNU compilers
# with PGI OpenMP and SGI Message Passing).  In order to support future versions
# of MKL these combinations are not checked for in CMake and will result in a
# generic "library not found" error.
#
# Example to find MKL headers only::
#
#   find_package(MKL 11.3.2)
#   if(MKL_FOUND)
#     include_directories(${MKL_INCLUDE_DIRS})
#     add_executable(foo foo.cc)
#   endif()
#
#
# Example to find MKL headers and some *static* libraries::
#
#   set(MKL_USE_STATIC_LIBS        ON) # only find static libs
#   find_package(MKL 11.3.2 COMPONENTS CDFT ScaLAPACK ...)
#   if(MKL_FOUND)
#     include_directories(${MKL_INCLUDE_DIRS})
#     link_directories(${MKL_LIBRARY_DIRS})
#     add_executable(foo foo.cc)
#     target_link_libraries(foo ${MKL_LIBRARIES})
#   endif()
#

# Set defaults
if (NOT DEFINED MKL_USE_STATIC_LIBS)
  set(MKL_USE_STATIC_LIBS OFF)
endif()
if (NOT DEFINED MKL_XEON_PHI_USAGE_MODEL)
  set(MKL_XEON_PHI_USAGE_MODEL none)
endif()
if (NOT DEFINED MKL_THREADING)
  set(MKL_THREADING OpenMP)
endif()
if (NOT DEFINED MKL_OPENMP)
  set(MKL_OPENMP Intel)
endif()
if (NOT DEFINED MKL_MESSAGE_PASSING)
  set(MKL_MESSAGE_PASSING Intel)
endif()

# Detect changes in used variables.
# Compares the current variable value with the last one.
# In short form:
# v != v_LAST                      -> CHANGED = 1
# v is defined, v_LAST not         -> CHANGED = 1
# v is not defined, but v_LAST is  -> CHANGED = 1
# otherwise                        -> CHANGED = 0
# CHANGED is returned in variable named ${changed_var}
macro(_MKL_CHANGE_DETECT changed_var)
  set(${changed_var} 0)
  foreach(v ${ARGN})
    if(DEFINED _MKL_COMPONENTS_SEARCHED)
      if(${v})
        if(_${v}_LAST)
          string(COMPARE NOTEQUAL "${${v}}" "${_${v}_LAST}" _${v}_CHANGED)
        else()
          set(_${v}_CHANGED 1)
        endif()
      elseif(_${v}_LAST)
        set(_${v}_CHANGED 1)
      endif()
      if(_${v}_CHANGED)
        set(${changed_var} 1)
      endif()
    else()
      set(_${v}_CHANGED 0)
    endif()
  endforeach()
endmacro()

# Collect environment variable inputs as hints.  Do not consider changes.
foreach(v MKLROOT MKL_ROOT MKL_INCLUDEDIR MKL_LIBRARYDIR)
  set(_env $ENV{${v}})
  if(_env)
    file(TO_CMAKE_PATH "${_env}" _ENV_${v})
  else()
    set(_ENV_${v} "")
  endif()
endforeach()
if(NOT _ENV_MKL_ROOT AND _ENV_MKLROOT)
  set(_ENV_MKL_ROOT "${_ENV_MKLROOT}")
endif()

# Collect inputs and cached results.  Detect changes since the last run.
if(NOT MKL_ROOT AND MKLROOT)
  set(MKL_ROOT "${MKLROOT}")
endif()
set(_MKL_VARS_DIR
  MKL_ROOT
  MKL_NO_SYSTEM_PATHS
  )

# ------------------------------------------------------------------------
#  Search for MKL include DIR
# ------------------------------------------------------------------------

set(_MKL_VARS_INC MKL_INCLUDEDIR MKL_INCLUDE_DIR MKL_ADDITIONAL_VERSIONS)
_MKL_CHANGE_DETECT(_MKL_CHANGE_INCDIR ${_MKL_VARS_DIR} ${_MKL_VARS_INC})
# Clear MKL_INCLUDE_DIR if it did not change but other input affecting the
# location did.  We will find a new one based on the new inputs.
if(_MKL_CHANGE_INCDIR AND NOT _MKL_INCLUDE_DIR_CHANGED)
  unset(MKL_INCLUDE_DIR CACHE)
endif()

if(NOT MKL_INCLUDE_DIR)
  set(_MKL_INCLUDE_SEARCH_DIRS "")
  if(MKL_INCLUDEDIR)
    list(APPEND _MKL_INCLUDE_SEARCH_DIRS ${MKL_INCLUDEDIR})
  elseif(_ENV_MKL_INCLUDEDIR)
    list(APPEND _MKL_INCLUDE_SEARCH_DIRS ${_ENV_MKL_INCLUDEDIR})
  endif()

  if(MKL_ROOT)
    list(APPEND _MKL_INCLUDE_SEARCH_DIRS ${MKL_ROOT}/include ${MKL_ROOT})
  elseif(_ENV_MKL_ROOT)
    list(APPEND _MKL_INCLUDE_SEARCH_DIRS ${_ENV_MKL_ROOT}/include ${_ENV_MKL_ROOT})
  endif()

  if(MKL_NO_SYSTEM_PATHS)
    list(APPEND _MKL_INCLUDE_SEARCH_DIRS NO_CMAKE_SYSTEM_PATH)
  else()
    list(APPEND _MKL_INCLUDE_SEARCH_DIRS PATHS
      "C:/Program Files (x86)/IntelSWTools"
      /opt/intel
      )
  endif()

  # Create a list of directories to search.
  # MKL comes bundled with Intel Composer/Parallel Studio and has a different
  # version to that of the package it comes bundled with (e.g. Composer XE
  # 2016.1.111 bundles MKL 11.3.2)
  # TODO: Prepend new versions to this as they are released (they must remain
  # sorted in descending order).
  set(_MKL_PACKAGE_KNOWN_VERSIONS ${MKL_PACKAGE_ADDITIONAL_VERSIONS}
      "2016.1.111" "2016.0.109" "2015.2.164")
  foreach(v ${_MKL_PACKAGE_KNOWN_VERSIONS})
    if (${CMAKE_SYSTEM_NAME} MATCHES "Windows")
      list(APPEND _MKL_PATH_SUFFIXES "compilers_and_libraries_${v}/windows/mkl/include")
    elseif(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
      list(APPEND _MKL_PATH_SUFFIXES "compilers_and_libraries_${v}/mac/mkl/include")
    elseif(${CMAKE_SYSTEM_NAME} MATCHES "Linux")
      list(APPEND _MKL_PATH_SUFFIXES "compilers_and_libraries_${v}/linux/mkl/include")
    endif()
    list(APPEND _MKL_PATH_SUFFIXES "composer_xe_${v}/mkl/include")
  endforeach()

  find_path(MKL_INCLUDE_DIR
    NAMES         mkl.h
    HINTS         ${_MKL_INCLUDE_SEARCH_DIRS}
    PATH_SUFFIXES ${_MKL_PATH_SUFFIXES}
  )
endif()

# ------------------------------------------------------------------------------
#  Extract version information from mkl.h (or mkl_version.h in newer versions)
# ------------------------------------------------------------------------------

# Set MKL_FOUND based only on header location and version.
# It will be updated below for component libraries.
if (MKL_INCLUDE_DIR)
  # Extract __INTEL_MKL__, __INTEL_MKL_MINOR__ and __INTEL_MKL_UPDATE__ from
  # mkl.h or mkl_version.h
  if(EXISTS "${MKL_INCLUDE_DIR}/mkl_version.h")
    file(STRINGS "${MKL_INCLUDE_DIR}/mkl_version.h" _MKL_VERSION_CONTENTS REGEX "#define __INTEL_MKL(_MINOR|_UPDATE)?__ ")
  else()
    file(STRINGS "${MKL_INCLUDE_DIR}/mkl.h" _MKL_VERSION_CONTENTS REGEX "#define __INTEL_MKL(_MINOR|_UPDATE)?__ ")
  endif()

  if("${_MKL_VERSION_CONTENTS}" MATCHES "#define __INTEL_MKL__ ([0-9]+)")
    set(MKL_MAJOR_VERSION "${CMAKE_MATCH_1}")
  endif()
  if("${_MKL_VERSION_CONTENTS}" MATCHES "#define __INTEL_MKL_MINOR__ ([0-9]+)")
    set(MKL_MINOR_VERSION "${CMAKE_MATCH_1}")
  endif()
  if("${_MKL_VERSION_CONTENTS}" MATCHES "#define __INTEL_MKL_UPDATE__ ([0-9]+)")
    set(MKL_UPDATE_VERSION "${CMAKE_MATCH_1}")
  endif()
  unset(_MKL_VERSION_CONTENTS)

  math(EXPR MKL_VERSION "${MKL_MAJOR_VERSION} * 10000 + ${MKL_MINOR_VERSION} * 100 + ${MKL_UPDATE_VERSION}")
  set(_MKL_VERSION "${MKL_MAJOR_VERSION}.${MKL_MINOR_VERSION}.${MKL_UPDATE_VERSION}")
  if (NOT MKL_FIND_QUIETLY)
    message(STATUS "Found MKL: ${MKL_INCLUDE_DIR} (found version \"${_MKL_VERSION}\")")
  endif()

  # Check version against any requested
  if (MKL_FIND_VERSION_EXACT AND NOT "${_MKL_VERSION}" VERSION_EQUAL "${MKL_FIND_VERSION}")
    set(MKL_FOUND 0)
  elseif (MKL_FIND_VERSION AND "${_MKL_VERSION}" VERSION_LESS "${MKL_FIND_VERSION}")
    set(MKL_FOUND 0)
  else()
    set(MKL_FOUND 1)
    set(MKL_INCLUDE_DIRS ${MKL_INCLUDE_DIR})
  endif()
  unset(_MKL_VERSION)
endif()

# ------------------------------------------------------------------------------
# Find libraries
# ------------------------------------------------------------------------------
if (MKL_FOUND)

  # Work out whether to search the ia32/ or intel64/ lib/ subdirectories
  set(_MKL_LIBRARY_SEARCH_DIRS "${MKL_INCLUDE_DIR}/../lib")
  try_run(_MKL_IS_64BIT
          _MKL_IS_64BIT_COMPILE_RESULT
          "${CMAKE_BINARY_DIR}"
          "${CMAKE_CURRENT_LIST_DIR}/arch/test_is_64bit.c")
  if (_MKL_IS_64BIT)
    list(APPEND _MKL_LIBRARY_SEARCH_DIRS "${MKL_INCLUDE_DIR}/../lib/intel64")
  else()
    list(APPEND _MKL_LIBRARY_SEARCH_DIRS "${MKL_INCLUDE_DIR}/../lib/ia32")
  endif()

  set(MKL_LIBRARIES "")

  # Find the core library
  find_library(MKL_CORE_LIB
               "mkl_core"
               HINTS ${_MKL_LIBRARY_SEARCH_DIRS})
  if("${MKL_CORE_LIB}" STREQUAL "MKL_CORE_LIB-NOTFOUND")
    set(MKL_FOUND 0)
  else()
    list(APPEND MKL_LIBRARIES ${MKL_CORE_LIB})
  endif()

  # Construct MKL_LIBRARIES
  list(REMOVE_DUPLICATES MKL_LIBRARIES)
endif()
