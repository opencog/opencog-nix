with import <nixpkgs> {};
stdenv.mkDerivation rec {
  name = "opencog-env";
  src = ./.;
  env = buildEnv { inherit name; paths = buildInputs; };

  atomspace = import ../packages/atomspace.nix {};
  opencog = import ../packages/opencog.nix {};

  buildInputs = [
    guile
    opencog
  ];

  shellHook = ''
    export LD_LIBRARY_PATH="${atomspace}/lib/opencog"

    gcc test.c -o test -ldl
    ./test

    export GUILE_LOAD_PATH="${atomspace}/build:${atomspace.src}/opencog/scm"
    # enter: ,apropos cog
    guile -l ${atomspace.src}/examples/atomspace/basic.scm
  '';
}
