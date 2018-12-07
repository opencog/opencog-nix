with import <nixpkgs> {};
stdenv.mkDerivation rec {
  name = "opencog-env";
  src = ./.;
  env = buildEnv { inherit name; paths = buildInputs; };

  atomspace = import ../packages/atomspace.nix { inherit pkgs; };
  opencog = import ../packages/opencog.nix { inherit pkgs; };

  buildInputs = [
    guile
    opencog
  ];

  shellHook = ''
    export LD_LIBRARY_PATH="${atomspace}/lib/opencog"

    gcc test.c -o test -ldl
    ./test

    # guile \
    # -L ${atomspace}/share/opencog/scm \
    # -l ${atomspace}/examples/atomspace/basic.scm \
  '';
}
