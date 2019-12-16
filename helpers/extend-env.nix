{ paths, pkgs ? import <nixpkgs> {} }: with pkgs;
let
extendVarWithParentsOfExt = var: basePath: ext: ''

RESULT1="$(
  find "${basePath}" -type f -iname "*${ext}" |
  sed -r "s=/[^/]+$==" |
  sort |
  uniq
)"
RESULT2="$(
  echo "$RESULT1" |
  while read line; do
    if [ -z "$line" ]; then continue; fi
    echo "$line"
    while [ "${basePath}" != "$line" ]; do
      line="$(dirname $line)"
      echo "$line"
    done
  done |
  sort |
  uniq
)"
export ${var}="''$${var}:''$(echo "$RESULT2" | paste -sd ':')"
'';
in ''
  ${builtins.concatStringsSep "\n" (builtins.map (x: extendVarWithParentsOfExt "GUILE_LOAD_PATH" x ".scm") paths)}
  ${builtins.concatStringsSep "\n" (builtins.map (x: extendVarWithParentsOfExt "LD_LIBRARY_PATH" x ".so") paths)}
  export PYTHONPATH="$PYTHONPATH:$LD_LIBRARY_PATH"
''


