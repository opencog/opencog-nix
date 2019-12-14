with import <nixpkgs> {};
stdenv.mkDerivation rec {
  name = "opencog-env";
  src = ./.;
  env = buildEnv { inherit name; paths = buildInputs; };

  atomspace = import ../packages/atomspace.nix {};
  opencog = import ../packages/opencog.nix {};

  buildInputs = [
    guile
    opencog

    rlwrap # add history and move cursor in line
  ];

  shellHook = ''
    ${import ../helpers/extend-env.nix {paths = [ atomspace opencog ];}}

    gcc test.c -o test -ldl
    ./test

    # enter: ,apropos cog
    rlwrap guile -l ${atomspace.src}/examples/atomspace/basic.scm
  '';
}
