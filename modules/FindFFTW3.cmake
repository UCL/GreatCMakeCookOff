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

macro(find_specific_libraries KIND PARALLEL)
  find_library(FFTW3_${KIND}_${PARALLEL}_LIBRARY NAMES
    fftw3${SUFFIX_${KIND}}${SUFFIX_${PARALLEL}}${SUFFIX_FINAL} HINTS ${HINT_DIRS})
  if(FFTW3_${KIND}_${PARALLEL}_LIBRARY MATCHES fftw3)
    list(APPEND FFTW3_LIBRARIES ${FFTW3_${KIND}_${PARALLEL}_LIBRARY})
    set(FFTW3_${KIND}_${PARALLEL}_FOUND TRUE)
    STRING(TOLOWER "${KIND}" kind)
    STRING(TOLOWER "${PARALLEL}" parallel)
    if(FFTW3_${kind}_${parallel}_LIBRARY MATCHES "\\.a$")
      add_library(fftw3::${kind}::${parallel} STATIC IMPORTED GLOBAL)
    else()
      add_library(fftw3::${kind}::${parallel} SHARED IMPORTED GLOBAL)
    endif()
    set(FFTW3_INCLUDE_DIR_PARALLEL ${FFTW3_INCLUDE_DIR} )
    if(PARALLEL STREQUAL "MPI")
      set(FFTW3_INCLUDE_DIR_PARALLEL ${FFTW3_${PARALLEL}_INCLUDE_DIR})
    endif()
    set_target_properties(fftw3::${kind}::${parallel} PROPERTIES
      IMPORTED_LOCATION "${FFTW3_${KIND}_${PARALLEL}_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES "${FFTW3_INCLUDE_DIR_PARALLEL}")
    if(PARALLEL STREQUAL "MPI")
      if(NOT MPI_C_FOUND)
        message(FATAL_ERROR "Please, find mpi libraries before FFTW")
      else()
        if(MPI_C_LIBRARIES)
          target_link_libraries(fftw3::${kind}::mpi ${MPI_C_LIBRARIES})
        endif()
        if(MPI_C_INCLUDE_DIRS)
          target_include_directories(fftw3::${kind}::mpi SYSTEM ${MPI_C_INCLUDE_PATH})
        endif()
        if(MPI_C_FLAGS)
          target_compile_options(fftw3::${kind}::mpi INTERFACE ${MPI_C_FLAGS})
        endif()
      endif()
    endif()

  endif()
endmacro()




# if(fftw3_FIND_COMPONENTS)
#     set(FFTW3_FIND_COMPONENTS ${fftw3_FIND_COMPONENTS})
# endif()
if(NOT FFTW3_FIND_COMPONENTS)
  set(FFTW3_FIND_COMPONENTS SINGLE DOUBLE LONGDOUBLE SERIAL)
endif()

string(TOUPPER "${FFTW3_FIND_COMPONENTS}" FFTW3_FIND_COMPONENTS)
message(STATUS "MY COMPONENTS ARE: ${FFTW3_FIND_COMPONENTS}")

list(FIND FFTW3_FIND_COMPONENTS SINGLE LOOK_FOR_SINGLE)
list(FIND FFTW3_FIND_COMPONENTS DOUBLE LOOK_FOR_DOUBLE)
list(FIND FFTW3_FIND_COMPONENTS LONGDOUBLE LOOK_FOR_LONGDOUBLE)
list(FIND FFTW3_FIND_COMPONENTS THREADED LOOK_FOR_THREADED)
list(FIND FFTW3_FIND_COMPONENTS OPENMP LOOK_FOR_OPENMP)
list(FIND FFTW3_FIND_COMPONENTS MPI LOOK_FOR_MPI)
list(FIND FFTW3_FIND_COMPONENTS SERIAL LOOK_FOR_SERIAL)

if(WIN32)
  set(HINT_DIRS ${FFTW3_DIRECTORY} $ENV{FFTW3_DIRECTORY})
else()
  find_package(PkgConfig)
  if(PKG_CONFIG_FOUND)
    pkg_check_modules(PC_FFTW QUIET fftw3)
    set(FFTW3_DEFINITIONS ${PC_FFTW3_CFLAGS_OTHER})
  endif()
  set(HINT_DIRS ${PC_FFTW3_INCLUDEDIR} ${PC_FFTW3_INCLUDE_DIRS}
    ${FFTW3_INCLUDE_DIR} $ENV{FFTW3_INCLUDE_DIR} )
endif()

find_path(FFTW3_INCLUDE_DIR NAMES fftw3.h HINTS ${HINT_DIRS})
if (LOOK_FOR_MPI)  # Probably is going to be the same as fftw3.h
  find_path(FFTW3_MPI_INCLUDE_DIR NAMES fftw3-mpi.h HINTS ${HINT_DIRS})
endif()

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

set(SUFFIX_DOUBLE "")
set(SUFFIX_SINGLE "f")
set(SUFFIX_LONGDOUBLE "l")
set(SUFFIX_SERIAL "")
set(SUFFIX_OPENMP "_omp")
set(SUFFIX_MPI "_mpi")
set(SUFFIX_THREADED "_threads")
set(SUFFIX_FINAL "")

if(WIN32)
  set(SUFFIX_FINAL "-3")
else()
  set(HINT_DIRS ${PC_FFTW3_LIBDIR} ${PC_FFTW3_LIBRARY_DIRS}
    $ENV{FFTW3_LIBRARY_DIR} ${FFTW3_LIBRARY_DIR} )
endif(WIN32)

unset(FFTW3_LIBRARIES)
set(FFTW3_INCLUDE_DIRS ${FFTW3_INCLUDE_DIR} ) # TODO what's for?

foreach(KIND SINGLE DOUBLE LONGDOUBLE)
  if(LOOK_FOR_${KIND} LESS 0)
    continue()
  endif()
  foreach(PARALLEL SERIAL MPI OPENMP THREADED)
    if(LOOK_FOR_${PARALLEL} LESS 0)
      continue()
    endif()
    find_specific_libraries(${KIND} ${PARALLEL})
  endforeach()
endforeach()





if(FFTW3_SINGLE_FOUND AND FFTW3_INCLUDE_DIR)
    find_version(FFTW3_VERSION_STRING ${FFTW3_SINGLE_LIBRARY} f)
elseif(FFTW3_DOUBLE_FOUND AND FFTW3_INCLUDE_DIR)
    find_version(FFTW3_VERSION_STRING ${FFTW3_DOUBLE_LIBRARY} "")
elseif(FFTW3_LONGDOUBLE_FOUND AND FFTW3_INCLUDE_DIR)
    find_version(FFTW3_VERSION_STRING ${FFTW3_LONGDOUBLE_LIBRARY} "l")
elseif(FFTW3_THREADED_FOUND AND FFTW3_INCLUDE_DIR)  # TODO What happens when you ask for double and threaded?
    find_version(FFTW3_VERSION_STRING ${FFTW3_THREADED_LIBRARY} "t") # TODO is this ok?
elseif(FFTW3_OPENMP_FOUND AND FFTW3_INCLUDE_DIR)  # TODO What happens when you ask for double and openmp?
    find_version(FFTW3_VERSION_STRING ${FFTW3_OPENMP_LIBRARY} "t") # TODO is this ok?
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
    if(FFTW3_SINGLE_LIBRARY MATCHES "\\.a$")

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
    if(FFTW3_LONGDOUBLE_LIBRARY MATCHES "\\.a$")
      add_library(fftw3::longdouble STATIC IMPORTED GLOBAL)
    else()
      add_library(fftw3::longdouble SHARED IMPORTED GLOBAL)
    endif()
    set_target_properties(fftw3::longdouble PROPERTIES
      IMPORTED_LOCATION "${FFTW3_LONGDOUBLE_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES "${FFTW3_INCLUDE_DIR}")
  endif()
  # TODO do I need this?
  if(FFTW3_THREADED_LIBRARY MATCHES fftw3_threads)
    if(FFTW3_THREADED_LIBRARY MATCHES "\\.a$")
      add_library(fftw3::threaded STATIC IMPORTED GLOBAL)
    else()
      add_library(fftw3::threaded SHARED IMPORTED GLOBAL)
    endif()
    set_target_properties(fftw3::threaded PROPERTIES
      IMPORTED_LOCATION "${FFTW3_THREADED_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES "${FFTW3_INCLUDE_DIR}")
  endif()
  if(FFTW3_OPENMP_LIBRARY MATCHES fftw3_omp)
    if(FFTW3_OPENMP_LIBRARY MATCHES "\\.a$")
      add_library(fftw3::openmp STATIC IMPORTED GLOBAL)
    else()
      add_library(fftw3::openmp SHARED IMPORTED GLOBAL)
    endif()
    set_target_properties(fftw3::openmp PROPERTIES
      IMPORTED_LOCATION "${FFTW3_OPENMP_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES "${FFTW3_INCLUDE_DIR}")
  endif()
endif()
