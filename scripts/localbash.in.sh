#!@ENV_EXECUTABLE@ @BASH_EXECUTABLE@
add_to_ld() {
  if [ -d "$1" ] && [[ ":$LD_LIBRARY_PATH:" != *":$1:"* ]]; then
    LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+"$LD_LIBRARY_PATH:"}$1"
  fi
  if [ -d "$1" ] && [[ ":$DYLD_LIBRARY_PATH:" != *":$1:"* ]]; then
    DYLD_LIBRARY_PATH="${DYLD_LIBRARY_PATH:+"$DYLD_LIBRARY_PATH:"}$1"
  fi
}
if [ -e @PROJECT_BINARY_DIR@/paths/ldpaths ]; then
  while read -r line; do
    add_to_ld $line
  done < @PROJECT_BINARY_DIR@/paths/ldpaths
fi
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH
export DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH
@EXECUTABLE@ "$@"
