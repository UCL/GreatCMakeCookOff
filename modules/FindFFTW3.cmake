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
  message(STATUS "Checking for ${KIND} and ${PARALLEL}")
  message(STATUS "Looking for: fftw3${SUFFIX_${KIND}}${SUFFIX_${PARALLEL}}${SUFFIX_FINAL} ")
  find_library(FFTW3_${KIND}_${PARALLEL}_LIBRARY NAMES
    fftw3${SUFFIX_${KIND}}${SUFFIX_${PARALLEL}}${SUFFIX_FINAL} HINTS ${HINT_DIRS})
  message(STATUS "Library: ${FFTW3_${KIND}_${PARALLEL}_LIBRARY} ?")
  if(FFTW3_${KIND}_${PARALLEL}_LIBRARY MATCHES fftw3)
    message(STATUS "Library: ${FFTW3_${KIND}_${PARALLEL}_LIBRARY} matches fftw3")
    list(APPEND FFTW3_LIBRARIES ${FFTW3_${KIND}_${PARALLEL}_LIBRARY})
    set(FFTW3_${KIND}_${PARALLEL}_FOUND TRUE)


    STRING(TOLOWER "${KIND}" kind)
    STRING(TOLOWER "${PARALLEL}" parallel)
    message(STATUS "Setting target: ${kind} /// ${parallel}")
    if(FFTW3_${kind}_${parallel}_LIBRARY MATCHES "\\.a$")
      add_library(fftw3::${kind}::${parallel} STATIC IMPORTED GLOBAL)
    else()
      add_library(fftw3::${kind}::${parallel} SHARED IMPORTED GLOBAL)
    endif()

    # MPI Has a different included library than the others
    # FFTW3_INCLUDE_DIR_PARALLEL will change depending of which on is used.
    set(FFTW3_INCLUDE_DIR_PARALLEL ${FFTW3_INCLUDE_DIR} )
    if(PARALLEL STREQUAL "MPI")
      set(FFTW3_INCLUDE_DIR_PARALLEL ${FFTW3_${PARALLEL}_INCLUDE_DIR})
    endif()

    set_target_properties(fftw3::${kind}::${parallel} PROPERTIES
      IMPORTED_LOCATION "${FFTW3_${KIND}_${PARALLEL}_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES "${FFTW3_INCLUDE_DIR_PARALLEL}")

    # adding target properties to the different cases
    ##   MPI
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
    ##   OpenMP
    if(PARALLEL STREQUAL "OPENMP")
      if(NOT OPENMP_FOUND)
        message(FATAL_ERROR "Please, find openmp libraries before FFTW")
      else()
        if(OPENMP_C_FLAGS)
          target_compile_options(fftw3::${kind}::openmp INTERFACE ${OPENMP_C_FLAGS})
        endif()
      endif()
    endif()
    ##  THREADED
    if(PARALLEL STREQUAL "THREADED")
      if(CMAKE_THREAD_LIBS_INIT)
        target_link_libraries(fftw3::${kind}::thread ${CMAKE_THREAD_LIBS_INIT})
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

# set serial as default if none parallel component has been set
if((LOOK_FOR_THREADED LESS 0) AND (LOOK_FOR_MPI LESS 0) AND
    (LOOK_FOR_OPENMP LESS 0))
  set(LOOK_FOR_SERIAL 1)
endif()



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
    message(STATUS "Finding version")
    file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/fftw${SUFFIX}/main.c
      # TODO: do we need to add include for mpi headers?
      "#include <fftw3.h>
       #include <stdio.h>
       int main(int nargs, char const *argv[]) {
           printf(\"%s\", fftw${SUFFIX}_version);
           return 0;
       }"
  )
if(NOT CMAKE_CROSSCOMPILING)
  message(STATUS "${LIBRARY} ${FFTW3_INCLUDE_DIR}")
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
  message(STATUS "Checking ${KIND}")
  if(LOOK_FOR_${KIND} LESS 0)
    continue()
  endif()
  foreach(PARALLEL SERIAL MPI OPENMP THREADED)
    message(STATUS "Checking for ${PARALLEL}")
    if(LOOK_FOR_${PARALLEL} LESS 0)
      message(STATUS "skipping macro ${PARALLEL}:${LOOK_FOR_${PARALLEL}}")
      continue()
    endif()
    find_specific_libraries(${KIND} ${PARALLEL})
  endforeach()
endforeach()


message(STATUS "my library is:  ${FFTW3_LIBRARIES}")
message(STATUS ($<bool:${FFTW3_FOUND}>))
message(STATUS "${FFTW3_INCLUDE_DIR}")
if(FFTW3_INCLUDE_DIR)
  # TODO: This just look on the simple case, but that may not been defined...
  # How can I get the last one?
  set(KIND "SINGLE")
  set(PARALLEL "SERIAL")
  message(STATUS "${FFTW3_${KIND}_${PARALLEL}_LIBRARY}")
  message(STATUS "${SUFFIX_${KIND}}${SUFFIX_${PARALLEL}}${SUFFIX_FINAL}")
  find_version(FFTW3_VERSION_STRING ${FFTW3_${KIND}_${PARALLEL}_LIBRARY}
    ${SUFFIX_${KIND}}${SUFFIX_${PARALLEL}}${SUFFIX_FINAL})
endif()
message(STATUS "my version is: ${FFTW3_VERSION_STRING}")


message(STATUS "Printing all the variables:")
message(STATUS  "ReqVars: FFT_LIB = ${FFTW3_LIBRARIES} FFT_INC = ${FFTW3_INCLUDE_DIR}")
message(STATUS "version=${FFTW3_VERSION_STRING}")

# FIXME: fails if use REQUIRED.
include(FindPackageHandleStandardArgs)
# handle the QUIETLY and REQUIRED arguments and set FFTW3_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args(FFTW3
    REQUIRED_VARS FFTW3_LIBRARIES FFTW3_INCLUDE_DIR
    VERSION_VAR FFTW3_VERSION_STRING
    #HANDLE_COMPONENTS
    # FIXME: HANDLE_COMPONENTS fails in this current implementation because
    # COMPONENTS inputs are as SINGLE, but SINGLE_SERIAL is found.
)
