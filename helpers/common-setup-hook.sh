exportVarExtendedWithPath () {
  local varName=$1
  local path=$2

  # check if path is existing directory and not already added
  if [ -d "$path" ] && [[ ":${!varName-}:" != *":$path:"* ]]
  then
    export $varName="${!varName-}:$path"
  fi
}

addOpencogPaths () {
  exportVarExtendedWithPath "LD_LIBRARY_PATH" "$1/lib"
  exportVarExtendedWithPath "LD_LIBRARY_PATH" "$1/lib/opencog"
  exportVarExtendedWithPath "OPENCOG_MODULE_PATHS" "$1/lib/opencog/modules"
}

addEnvHooks "$hostOffset" addOpencogPaths
