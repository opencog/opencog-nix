with import <nixpkgs> {};
stdenv.mkDerivation rec {
  name = "cogserver-env";
  src = ./.;
  env = buildEnv { inherit name; paths = buildInputs; };

  cogserver = import ../packages/cogserver.nix {};

  buildInputs = [
    cogserver
  ];

  shellHook = ''
  '';
}
