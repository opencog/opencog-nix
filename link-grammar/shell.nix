with import <nixpkgs> {};
stdenv.mkDerivation rec {
  name = "link-grammar-env";
  src = ./.;
  env = buildEnv { inherit name; paths = buildInputs; };

  link-grammar = import ../packages/link-grammar.nix {};

  buildInputs = [
    link-grammar
  ];

  shellHook = ''
    link-parser
  '';
}
