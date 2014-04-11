#!@ENV_EXECUTABLE@ @BASH_EXECUTABLE@
add_to_ld() {
  if [ -d "$1" ] && [[ ":$LD_LIBRARY_PATH:" != *":$1:"* ]]; then
    LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+"$LD_LIBRARY_PATH:"}$1"
  fi
  if [ -d "$1" ] && [[ ":$DYLD_LIBRARY_PATH:" != *":$1:"* ]]; then
    DYLD_LIBRARY_PATH="${DYLD_LIBRARY_PATH:+"$DYLD_LIBRARY_PATH:"}$1"
  fi
}
add_to_pypath() {
  if [ -d "$1" ] && [[ ":$PYTHONPATH:" != *":$1:"* ]]; then
    PYTHONPATH="${PYTHONPATH:+"$PYTHONPATH:"}$1"
  fi
}
if [ -e @PROJECT_BINARY_DIR@/ldpaths ]; then
  while read -r line; do
    add_to_ld $line
  done < @PROJECT_BINARY_DIR@/ldpaths
fi
if [ -e @PROJECT_BINARY_DIR@/pypaths ]; then
  while read -r line; do
    add_to_pypath $line
  done < @PROJECT_BINARY_DIR@/pypaths
fi
export PYTHONPATH=$PYTHONPATH
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH
export DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH
@EXECUTABLE@ "$@"
