with import <nixpkgs> {};
stdenv.mkDerivation rec {
  name = "attention-env";
  src = ./.;
  env = buildEnv { inherit name; paths = buildInputs; };

  attention = import ../packages/attention.nix {};

  buildInputs = [
    attention
  ];

  shellHook = ''
  '';
}
