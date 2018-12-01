let
  pkgs = import <nixpkgs> {};
  mkDerivation = import ./autotools.nix pkgs;
in with pkgs;
mkDerivation rec {
  name = "atomspace";
  version = "5.0.4";

  BOOST_ROOT = "${boost166.dev}";
  BOOST_LIBRARYDIR = "${boost166}/lib";
  
  CXXTEST_BIN_DIR ="${cxxtest}/bin";
  
  COGUTIL_DIR = import ../cogutil/default.nix;

  GUILE_LIBRARY = "${guile}/lib";
  GUILE_INCLUDE_DIR = "${guile.dev}/include/guile/2.2";

  GMP_LIBRARY = "${gmp}/lib";
  GMP_INCLUDE_DIR = "${gmp.dev}/include";

  buildInputs = [
    cmake boost166
    cxxtest
    python
    guile gmp
    (import ../cogutil/default.nix)
  ];

  outputs = ["out" "build"];

  src = builtins.fetchGit {
    url = https://github.com/opencog/atomspace.git;
    rev = "fddaf5426c3f1d379c4a92c7fd396e9736551ad1";
  };
}
