# Defines the following variables
#
# - CFitsIO_FOUND if the library is found
# - CFitsIO_LIBRARY is the path to the library
# - CFitsIO_INCLUDE_DIR is the path to the include directory
# - CFitsIO_VERSION_STRING is the version of the library

find_library(
  CFitsIO_LIBRARY cfitsio
  DOC "Path to the cfitsio library"
)
find_path(
  CFitsIO_INCLUDE_DIR fitsio.h
  PATH_SUFFIXES include include/cfitsio
  DOC "Path to the cfitsio include directory"
)
if(NOT "${CFitsIO_INCLUDE_DIR}" MATCHES "\\-NOTFOUND")
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
  FOUND_VAR CFitsIO_FOUND
  REQUIRED_VARS CFitsIO_LIBRARY CFitsIO_INCLUDE_DIR
  VERSION_VAR CFitsIO_VERSION_STRING
)
