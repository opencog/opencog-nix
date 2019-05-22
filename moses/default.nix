with import <nixpkgs> {};
stdenv.mkDerivation rec {
  name = "moses-env";
  src = ./.;
  env = buildEnv { inherit name; paths = buildInputs; };

  moses = import ../packages/moses.nix {};

  buildInputs = [
    moses
  ];

  shellHook = ''
  '';
}
