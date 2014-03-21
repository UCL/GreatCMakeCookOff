# - Try to find FFTW
# Once done this will define
#  FFTW3_FOUND - System has FFTW3
#  FFTW3_INCLUDE_DIRS - The FFTW3 include directories
#  FFTW3_LIBRARIES - The libraries needed to use FFTW3
#  FFTW3_THREADED_LIBRARIES - The libraries needed to use threaded FFTW3
#  FFTW3_DEFINITIONS - Compiler switches required for using FFTW3
#  FFTW3_HAS_SINGLE - Set if FFTW3 exists in single precision format.
#  FFTW3_HAS_DOUBLE - Set if FFTW3 exists in double precision format.
#  FFTW3_HAS_LONG_DOUBLE - Set if FFTW3 exists in double precision format.

if(NOT FFTW3_FOUND)

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
  
  if(WIN32)
    find_library(FFTW3_LIBRARY_SINGLE NAMES libfftw3f-3 HINTS ${HINT_DIRS})
    find_library(FFTW3_LIBRARY_DOUBLE NAMES libfftw3-3 HINTS ${HINT_DIRS})
    find_library(FFTW3_LIBRARY_LONG_DOUBLE NAMES libfftw3l-3 HINTS ${HINT_DIRS})
  else()
    set(HINT_DIRS ${PC_FFTW3_LIBDIR} ${PC_FFTW3_LIBRARY_DIRS} 
                  $ENV{FFTW3_LIBRARY_DIR} ${FFTW3_LIBRARY_DIR} )
    find_library(FFTW3_LIBRARY_SINGLE NAMES fftw3f HINTS ${HINT_DIRS})
    find_library(FFTW3_LIBRARY_DOUBLE NAMES fftw3 HINTS ${HINT_DIRS})
    find_library(FFTW3_LIBRARY_LONG_DOUBLE NAMES fftw3l HINTS ${HINT_DIRS})
  endif(WIN32)

  set(FFTW3_LIBRARIES)
  set(FFTW3_INCLUDE_DIRS ${FFTW3_INCLUDE_DIR} )
  if(FFTW3_LIBRARY_SINGLE MATCHES fftw3f) 
    set(FFTW3_HAS_SINGLE TRUE)
    set(FFTW3_LIBRARIES ${FFTW3_LIBRARIES} ${FFTW3_LIBRARY_SINGLE})
  endif(FFTW3_LIBRARY_SINGLE MATCHES fftw3f) 
  if(FFTW3_LIBRARY_DOUBLE MATCHES fftw3) 
    set(FFTW3_HAS_DOUBLE TRUE)
    set(FFTW3_LIBRARIES ${FFTW3_LIBRARIES} ${FFTW3_LIBRARY_DOUBLE})
  endif(FFTW3_LIBRARY_DOUBLE MATCHES fftw3) 
  if(FFTW3_LIBRARY_LONG_DOUBLE MATCHES fftw3l) 
    set(FFTW3_HAS_LONG_DOUBLE TRUE)
    set(FFTW3_LIBRARIES ${FFTW3_LIBRARIES} ${FFTW3_LIBRARY_LONG_DOUBLE})
  endif(FFTW3_LIBRARY_LONG_DOUBLE MATCHES fftw3l) 


  include(FindPackageHandleStandardArgs)
  # handle the QUIETLY and REQUIRED arguments and set FFTW3_FOUND to TRUE
  # if all listed variables are TRUE
  find_package_handle_standard_args(FFTW3  DEFAULT_MSG FFTW3_LIBRARIES FFTW3_INCLUDE_DIR)

  mark_as_advanced(FFTW3_INCLUDE_DIR FFTW3_LIBRARY )
endif()
