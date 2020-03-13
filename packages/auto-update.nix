with import <nixpkgs> {};
stdenv.mkDerivation rec {
  name = "auto-update"; # this must match the file name
  src = ./.;
  env = buildEnv { inherit name; paths = buildInputs; };

  buildInputs = [
    nix-prefetch-git
  ];

  shellHook = ''
    set_keys_value_in_file () {
      local key=$1
      local new_value=$2
      local file=$3
      local sed_substitution="s/\(.*$key\s*=\s*\"\)[^\"]*\(\"*\)/\1$new_value\2/"
      echo "Substituting keys \"$key\" value with \"$new_value\" in file \"$file\""
      echo "Substitution \"$sed_substitution\""
      pwd
      sed -i "$sed_substitution" $file
    }

    # execute from packages folder
    update_opencog_repos () {
      local FILES=$@
      if [ -z "$FILES" ]; then
        FILES=$(find . -maxdepth 1 -type f -name "*.nix")
      fi
      echo $FILES
      for FILE in $FILES; do
        if [[ $FILE == *"${name}"* ]]; then continue; fi

        echo $FILE;
        FILE=''${FILE%.nix}
        local TARGET_REPO=https://github.com/opencog/$FILE.git
        echo $TARGET_REPO
        local PREFETCH=$(nix-prefetch-git $TARGET_REPO)
        local REV=$(echo "$PREFETCH" | grep '"rev":' | awk '{print $2}' | sed 's/"\|,//g')
        local SHA256=$(echo "$PREFETCH" | grep '"sha256":' | awk '{print $2}' | sed 's/"\|,//g')
        local DATE=$(echo "$PREFETCH" | grep '"date":' | awk '{print $2}' | sed 's/"\|,//g')

        FILE="$FILE".nix
        set_keys_value_in_file rev $REV $FILE
        set_keys_value_in_file sha256 $SHA256 $FILE

      done
    }

    update_opencog_repos # to update only some packages pass their names as arguments
    exit
  '';
}
