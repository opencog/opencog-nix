with import <nixpkgs> {};
stdenv.mkDerivation rec {
  name = "pln-env";
  src = ./.;
  env = buildEnv { inherit name; paths = buildInputs; };

  pln = import ../packages/pln.nix {};
  ure = import ../packages/ure.nix {};
  opencog = import ../packages/opencog.nix {};
  atomspace = import ../packages/atomspace.nix {};

  buildInputs = [
    pln
    ure
    opencog
    atomspace

    guile
    rlwrap
  ];

  shellHook = ''
    rlwrap guile
  '';
}
