with import <nixpkgs> {};
with import <nixpkgs/nixos> {};

stdenv.mkDerivation rec {
  name = "atomspace-env";
  src = ./.;
  env = buildEnv { inherit name; paths = buildInputs; };

  atomspace = import ../packages/atomspace.nix { inherit pkgs; inherit config; };

  buildInputs = [
    atomspace
  ];

  shellHook = ''
  '';
}
