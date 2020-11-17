addOpencogPaths () {
  if [ -d "$1/lib" ]
  then
    export LD_LIBRARY_PATH="${LD_LIBRARY_PATH-}:$1/lib"
  fi

  if [ -d "$1/lib/opencog" ]
  then
    export LD_LIBRARY_PATH="${LD_LIBRARY_PATH-}:$1/lib/opencog"
  fi

  if [ -d "$1/lib/opencog/modules" ]
  then
    export OPENCOG_MODULE_PATHS="${OPENCOG_MODULE_PATHS-}:$1/lib/opencog/modules"
  fi
}

addEnvHooks "$hostOffset" addOpencogPaths
