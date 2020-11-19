with import <nixpkgs> {};
stdenv.mkDerivation rec {
  name = "pln-env";
  src = ./.;
  env = buildEnv { inherit name; paths = buildInputs; };

  pln = import ../packages/pln.nix {};

  buildInputs = [
    pln
  ];

  shellHook = ''
  '';
}
