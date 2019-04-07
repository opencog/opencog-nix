with import <nixpkgs> {};
stdenv.mkDerivation rec {
  name = "atomspace-env";
  src = ./.;
  env = buildEnv { inherit name; paths = buildInputs; };

  atomspace = import ../packages/atomspace.nix {};

  buildInputs = [
    atomspace
  ];

  shellHook = ''
  '';
}
