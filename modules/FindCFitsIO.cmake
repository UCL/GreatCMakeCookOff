# Defines the following variables
#
# - CFitsIO_FOUND if the library is found
# - CFitsIO_LIBRARY is the path to the library
# - CFitsIO_INCLUDE_DIR is the path to the include directory
# - CFitsIO_VERSION_STRING is the version of the library

if(NOT CFitsIO_LIBRARY)
    find_library(
      CFitsIO_LIBRARY cfitsio
      DOC "Path to the cfitsio library"
    )
endif()
if(NOT CFitsIO_INCLUDE_DIR)
    find_path(
      CFitsIO_INCLUDE_DIR fitsio.h
      PATH_SUFFIXES include include/cfitsio
      DOC "Path to the cfitsio include directory"
    )
endif()
if(CFitsIO_INCLUDE_DIR)
  file(
    STRINGS ${CFitsIO_INCLUDE_DIR}/fitsio.h
    CFitsIO_VERSION_STRING
    REGEX "#define[ ]+CFITSIO_VERSION[ ]+([0-9]*\\.[0-9]*)"
  )
  string(
    REGEX REPLACE
    ".*#define[ ]+CFITSIO_VERSION[ ]+([0-9]*\\.[0-9]*).*"
    "\\1"
    CFitsIO_VERSION_STRING
    "${CFitsIO_VERSION_STRING}"
  )
endif()

include(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(
  CFitsIO
  REQUIRED_VARS CFitsIO_LIBRARY CFitsIO_INCLUDE_DIR
  VERSION_VAR CFitsIO_VERSION_STRING
)
if(CFITSIO_FOUND AND NOT CFitsIO_FOUND)
    set(CFitsIO_FOUND ${CFITSIO_FOUND})
endif()
