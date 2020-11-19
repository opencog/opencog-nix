with import <nixpkgs> {};
stdenv.mkDerivation rec {
  name = "generate-env";
  src = ./.;
  env = buildEnv { inherit name; paths = buildInputs; };

  generate = import ../packages/generate.nix {};

  buildInputs = [
    generate
  ];

  shellHook = ''
  '';
}
