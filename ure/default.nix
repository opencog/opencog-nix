with import <nixpkgs> {};
stdenv.mkDerivation rec {
  name = "ure-env";
  src = ./.;
  env = buildEnv { inherit name; paths = buildInputs; };

  ure = import ../packages/ure.nix {};

  buildInputs = [
    ure
  ];

  shellHook = ''
  '';
}
