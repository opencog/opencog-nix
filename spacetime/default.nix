with import <nixpkgs> {};
stdenv.mkDerivation rec {
  name = "spacetime-env";
  src = ./.;
  env = buildEnv { inherit name; paths = buildInputs; };

  spacetime = import ../packages/spacetime.nix {};

  buildInputs = [
    spacetime
  ];

  shellHook = ''
  '';
}
