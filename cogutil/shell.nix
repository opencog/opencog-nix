with import <nixpkgs> {};
with import <nixpkgs/nixos> {};
stdenv.mkDerivation rec {
  name = "cogutil-env";
  src = ./.;
  env = buildEnv { inherit name; paths = buildInputs; };

  cogutil = import ../packages/cogutil.nix { inherit pkgs; inherit config; };

  buildInputs = [
    cogutil
  ];

  shellHook = ''
    gcc -o test test.c
    ./test
  '';
}
