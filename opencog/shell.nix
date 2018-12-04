with import <nixpkgs> {};
stdenv.mkDerivation rec {
  name = "opencog-env";
  src = ./.;
  env = buildEnv { inherit name; paths = buildInputs; };

  opencog = import ../packages/opencog.nix { inherit pkgs; };

  buildInputs = [
    opencog
  ];

  shellHook = ''
  '';
}
