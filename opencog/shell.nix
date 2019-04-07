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

    guile \
    -L ${atomspace}/build \
    -L ${atomspace.src}/opencog/scm \
    -l ${atomspace.src}/examples/atomspace/basic.scm \
    # enter: ,apropos cog
  '';
}
