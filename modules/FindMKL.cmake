# - Try to find MKL
# Once done this will define
#  MKL_FOUND - System has MKL
#  MKL_INCLUDE_DIRS - The mkl include directories
#  MKL_LIBRARIES - The libraries needed to use mkl
if(NOT MKL_FOUND)

  if(EXISTS $ENV{MKL_PATH})
    set(HINT_DIRS ${MKL_DIRECTORY} $ENV{MKL_PATH}/include)
  endif(EXISTS $ENV{MKL_PATH})
  find_path(MKL_INCLUDE_DIRS NAMES mkl_dfti.h HINTS ${HINT_DIRS} ${MKL_INCLUDE_DIRS})

  if(DEFINED ENV{MKL_LINK_LINE})
    set(MKL_LIBRARIES "$ENV{MKL_LINK_LINE}")
  elseif(NOT "$ENV{BLASDIR}" STREQUAL "" AND NOT "$ENV{BLASLIB}" STREQUAL "")
    set(MKL_LIBRARIES "-L$ENV{BLASDIR} -l$ENV{BLASLIB}")
  endif()

  include(FindPackageHandleStandardArgs)

  find_package(Threads REQUIRED)
  set(MKL_LIBRARIES "${MKL_LIBRARIES} ${CMAKE_THREAD_LIBS_INIT}")
  # handle the QUIETLY and REQUIRED arguments and set FFTW3_FOUND to TRUE
  # if all listed variables are TRUE
  find_package_handle_standard_args(MKL  DEFAULT_MSG MKL_LIBRARIES MKL_INCLUDE_DIRS)

  mark_as_advanced(MKL_INCLUDE_DIRS MKL_LIBRARIES)
  set(MKL_SINGLE_FOUND TRUE)
  set(MKL_DOUBLE_FOUND TRUE)
  set(MKL_LONGDOUBLE_FOUND FALSE)
endif(NOT MKL_FOUND)
