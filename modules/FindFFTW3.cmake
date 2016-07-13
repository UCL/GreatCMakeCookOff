# - Try to find FFTW
# Once done this will define
#  FFTW3_FOUND - System has FFTW3
#  FFTW3_INCLUDE_DIRS - The FFTW3 include directories
#  FFTW3_LIBRARIES - The libraries needed to use FFTW3
#  FFTW3_THREADED_LIBRARIES - The libraries needed to use threaded FFTW3
#  FFTW3_DEFINITIONS - Compiler switches required for using FFTW3
#  FFTW3_SINGLE_FOUND- Set if FFTW3 exists in single precision format.
#  FFTW3_DOUBLE_FOUND- Set if FFTW3 exists in double precision format.
#  FFTW3_LONGDOUBLE_FOUND - Set if FFTW3 exists in double precision format.

if(FFTW3_FOUND)
  return()
endif()

if(FFTW3_INCLUDE_DIR AND FFTW3_LIBRARIES)
  set(FFTW3_FOUND TRUE)
  foreach(component ${FFTW3_FIND_COMPONENTS})
    if("${FFTW3_${component}_LIBRARY}" STREQUAL "")
        set(FFTW3_${component}_LIBRARY "${FFTW3_LIBRARIES}")
    endif()
  endforeach()
  return()
endif()

# if(fftw3_FIND_COMPONENTS)
#     set(FFTW3_FIND_COMPONENTS ${fftw3_FIND_COMPONENTS})
# endif()
if(NOT FFTW3_FIND_COMPONENTS)
    set(FFTW3_FIND_COMPONENTS SINGLE DOUBLE LONGDOUBLE)
endif()
string(TOUPPER "${FFTW3_FIND_COMPONENTS}" FFTW3_FIND_COMPONENTS)

list(FIND FFTW3_FIND_COMPONENTS SINGLE LOOK_FOR_SINGLE)
list(FIND FFTW3_FIND_COMPONENTS DOUBLE LOOK_FOR_DOUBLE)
list(FIND FFTW3_FIND_COMPONENTS LONGDOUBLE LOOK_FOR_LONGDOUBLE)
list(FIND FFTW3_FIND_COMPONENTS THREADED LOOK_FOR_THREADED)

if(WIN32)
  set(HINT_DIRS ${FFTW3_DIRECTORY} $ENV{FFTW3_DIRECTORY})
else()
  find_package(PkgConfig)
  pkg_check_modules(PC_FFTW QUIET fftw3)
  set(FFTW3_DEFINITIONS ${PC_FFTW3_CFLAGS_OTHER})

  set(HINT_DIRS ${PC_FFTW3_INCLUDEDIR} ${PC_FFTW3_INCLUDE_DIRS}
                ${FFTW3_INCLUDE_DIR} $ENV{FFTW3_INCLUDE_DIR} )
endif(WIN32)

find_path(FFTW3_INCLUDE_DIR NAMES fftw3.h HINTS ${HINT_DIRS})

function(find_version OUTVAR LIBRARY SUFFIX)
    file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/fftw${SUFFIX}/main.c
      "#include <fftw3.h>
       #include <stdio.h>
       int main(int nargs, char const *argv[]) {
           printf(\"%s\", fftw${SUFFIX}_version);
           return 0;
       }"
  )
  if(NOT CMAKE_CROSSCOMPILING)
    try_run(RUN_RESULT COMPILE_RESULT
        "${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/fftw${SUFFIX}/"
        "${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/fftw${SUFFIX}/main.c"
        CMAKE_FLAGS
          -DLINK_LIBRARIES=${LIBRARY}
          -DINCLUDE_DIRECTORIES=${FFTW3_INCLUDE_DIR}
        RUN_OUTPUT_VARIABLE OUTPUT
        COMPILE_OUTPUT_VARIABLE COUTPUT
    )
  endif()
  if(RUN_RESULT EQUAL 0)
    string(REGEX REPLACE
        ".*([0-9]+\\.[0-9]+\\.[0-9]+).*"
        "\\1" VERSION_STRING "${OUTPUT}"
    )
    set(${OUTVAR} ${VERSION_STRING} PARENT_SCOPE)
  endif()
endfunction()

if(WIN32)
  if(LOOK_FOR_SINGLE GREATER -1)
    find_library(FFTW3_SINGLE_LIBRARY NAMES libfftw3f-3 HINTS ${HINT_DIRS})
  endif()
  if(LOOK_FOR_DOUBLE GREATER -1)
    find_library(FFTW3_DOUBLE_LIBRARY NAMES libfftw3-3 HINTS ${HINT_DIRS})
  endif()
  if(LOOK_FOR_LONGDOUBLE GREATER -1)
    find_library(FFTW3_LONGDOUBLE_LIBRARY NAMES libfftw3l-3 HINTS ${HINT_DIRS})
  endif()
  # if(LOOK_FOR_THREADED GREATER -1)
  #   # FIXME What's the case for windows?
  #   find_library(FFTW3_THREADED_LIBRARY NAMES libfftw3l-3 HINTS ${HINT_DIRS})
  # endif()
else()
  set(HINT_DIRS ${PC_FFTW3_LIBDIR} ${PC_FFTW3_LIBRARY_DIRS}
                $ENV{FFTW3_LIBRARY_DIR} ${FFTW3_LIBRARY_DIR} )
  if(LOOK_FOR_SINGLE GREATER -1)
    find_library(FFTW3_SINGLE_LIBRARY NAMES fftw3f HINTS ${HINT_DIRS})
  endif()
  if(LOOK_FOR_DOUBLE GREATER -1)
    find_library(FFTW3_DOUBLE_LIBRARY NAMES fftw3 HINTS ${HINT_DIRS})
  endif()
  if(LOOK_FOR_LONGDOUBLE GREATER -1)
    find_library(FFTW3_LONGDOUBLE_LIBRARY NAMES fftw3l HINTS ${HINT_DIRS})
  endif()
  if(LOOK_FOR_THREADED GREATER -1)
    find_library(FFTW3_THREADED_LIBRARY NAMES fftw3f_threads HINTS ${HINT_DIRS})
  endif()
endif(WIN32)

set(FFTW3_LIBRARIES)
set(FFTW3_INCLUDE_DIRS ${FFTW3_INCLUDE_DIR} )
if(FFTW3_SINGLE_LIBRARY MATCHES fftw3f)
  set(FFTW3_LIBRARIES ${FFTW3_LIBRARIES} ${FFTW3_SINGLE_LIBRARY})
  set(FFTW3_SINGLE_FOUND TRUE)
endif(FFTW3_SINGLE_LIBRARY MATCHES fftw3f)
if(FFTW3_DOUBLE_LIBRARY MATCHES fftw3)
  set(FFTW3_HAS_DOUBLE TRUE)
  set(FFTW3_LIBRARIES ${FFTW3_LIBRARIES} ${FFTW3_DOUBLE_LIBRARY})
  set(FFTW3_DOUBLE_FOUND TRUE)
endif(FFTW3_DOUBLE_LIBRARY MATCHES fftw3)
if(FFTW3_LONGDOUBLE_LIBRARY MATCHES fftw3l)
  set(FFTW3_LIBRARIES ${FFTW3_LIBRARIES} ${FFTW3_LONGDOUBLE_LIBRARY})
  set(FFTW3_LONGDOUBLE_FOUND TRUE)
endif(FFTW3_LONGDOUBLE_LIBRARY MATCHES fftw3l)
if(FFTW3_THREADED_LIBRARY MATCHES fftw3l)
  set(FFTW3_LIBRARIES ${FFTW3_LIBRARIES} ${FFTW3_THREADED_LIBRARY})
  set(FFTW3_THREADED_FOUND TRUE)
endif(FFTW3_THREADED_LIBRARY MATCHES fftw3f_threads)

if(FFTW3_SINGLE_FOUND AND FFTW3_INCLUDE_DIR)
    find_version(FFTW3_VERSION_STRING ${FFTW3_SINGLE_LIBRARY} f)
elseif(FFTW3_DOUBLE_FOUND AND FFTW3_INCLUDE_DIR)
    find_version(FFTW3_VERSION_STRING ${FFTW3_DOUBLE_LIBRARY} "")
elseif(FFTW3_LONGDOUBLE_FOUND AND FFTW3_INCLUDE_DIR)
    find_version(FFTW3_VERSION_STRING ${FFTW3_LONGDOUBLE_LIBRARY} "l")
elseif(FFTW3_THREADED_FOUND AND FFTW3_INCLUDE_DIR)  # TODO What happens when you ask for double and threaded?
    find_version(FFTW3_VERSION_STRING ${FFTW3_THREADED_LIBRARY} "t") # TODO is this ok?
endif()

include(FindPackageHandleStandardArgs)
# handle the QUIETLY and REQUIRED arguments and set FFTW3_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args(FFTW3
    REQUIRED_VARS FFTW3_LIBRARIES FFTW3_INCLUDE_DIR
    VERSION_VAR FFTW3_VERSION_STRING
    HANDLE_COMPONENTS
)
if(FFTW3_FOUND)
  if(FFTW3_SINGLE_LIBRARY MATCHES fftw3f)
    if(FFTW3_SINGLE_LIBRARY MATCHES "\.a$")
      add_library(fftw3::single STATIC IMPORTED GLOBAL)
    else()
      add_library(fftw3::single SHARED IMPORTED GLOBAL)
    endif()
    set_target_properties(fftw3::double PROPERTIES
      IMPORTED_LOCATION "${FFTW3_SINGLE_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES "${FFTW3_INCLUDE_DIR}")
  endif()
  if(FFTW3_DOUBLE_LIBRARY MATCHES fftw3)
    if(FFTW3_DOUBLE_LIBRARY MATCHES "\\.a$")
      add_library(fftw3::double STATIC IMPORTED GLOBAL)
    else()
      add_library(fftw3::double SHARED IMPORTED GLOBAL)
    endif()
    set_target_properties(fftw3::double PROPERTIES
      IMPORTED_LOCATION "${FFTW3_DOUBLE_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES "${FFTW3_INCLUDE_DIR}")
  endif()
  if(FFTW3_LONGDOUBLE_LIBRARY MATCHES fftw3l)
    if(FFTW3_LONGDOUBLE_LIBRARY MATCHES "\.a$")
      add_library(fftw3::longdouble STATIC IMPORTED GLOBAL)
    else()
      add_library(fftw3::longdouble SHARED IMPORTED GLOBAL)
    endif()
    set_target_properties(fftw3::longdouble PROPERTIES
      IMPORTED_LOCATION "${FFTW3_LONGDOUBLE_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES "${FFTW3_INCLUDE_DIR}")
  endif()
  # TODO do I need this?
  # if(FFTW3_THREADED_LIBRARY MATCHES fftw3_threads)
  #   if(FFTW3_THREADED_LIBRARY MATCHES "\.a$")
  #     add_library(fftw3::threaded STATIC IMPORTED GLOBAL)
  #   else()
  #     add_library(fftw3::threaded SHARED IMPORTED GLOBAL)
  #   endif()
  #   set_target_properties(fftw3::threaded PROPERTIES
  #     IMPORTED_LOCATION "${FFTW3_THREADED_LIBRARY}"
  #     INTERFACE_INCLUDE_DIRECTORIES "${FFTW3_INCLUDE_DIR}")
  # endif()
endif()
