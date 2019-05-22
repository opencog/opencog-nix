with import <nixpkgs> {};
stdenv.mkDerivation rec {
  name = "cogutil-env";
  src = ./.;
  env = buildEnv { inherit name; paths = buildInputs; };

  cogutil = import ../packages/cogutil.nix {};

  buildInputs = [
    cogutil
  ];

  shellHook = ''
    gcc -o test test.c
    ./test
  '';
}
