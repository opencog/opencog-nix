let
  pkgs = import <nixpkgs> {};
  mkDerivation = import ./autotools.nix pkgs;
in with pkgs;
mkDerivation {
  name = "opencog";
  BOOST_ROOT= "${boost166.dev}";
  BOOST_LIBRARYDIR= "${boost166}/lib";
 
  buildInputs = [
    cmake boost166

    libuuid
    (import ../cogutil/default.nix)
    (import ../atomspace/default.nix)
  ];
  outputs = [ "out" "build" ];
  src = builtins.fetchGit {
    url = https://github.com/opencog/cogutil.git;
    rev = "e3eca79143975cd930f3ba58a89ba143189205e9";
  };
}