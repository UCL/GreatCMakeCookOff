# Defines the following variables
#
# - GBENCHMARK_FOUND if the library is found
# - GBENCHMARK_LIBRARY is the path to the library
# - GBENCHMARK_INCLUDE_DIR is the path to the include directory

find_library(GBENCHMARK_LIBRARY benchmark DOC "Path to the google benchmark library")
find_path(
  GBENCHMARK_INCLUDE_DIR benchmark/benchmark.h
  DOC "Path to google benchmark include directory"
  PATHS "${casapath}"
)

include(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(
  GBENCHMARK
  REQUIRED_VARS GBENCHMARK_LIBRARY GBENCHMARK_INCLUDE_DIR
)
