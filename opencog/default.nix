with import <nixpkgs> {};
stdenv.mkDerivation rec {
  name = "opencog-env";
  src = ./.;
  env = buildEnv { inherit name; paths = buildInputs; };

  cogutil = (import ../packages/cogutil.nix {});
  atomspace = (import ../packages/atomspace.nix {});
  cogserver = (import ../packages/cogserver.nix {});
  attention = (import ../packages/attention.nix {});
  link-grammar = (import ../packages/link-grammar.nix {});
  moses = (import ../packages/moses.nix {});
  ure = (import ../packages/ure.nix {});
  spacetime = (import ../packages/spacetime.nix {});
  opencog = import ../packages/opencog.nix {};

  # build
  buildInputs = [
    cogutil
    atomspace
    cogserver
    attention
    link-grammar
    moses
    ure
    spacetime
    opencog

    guile
    rlwrap # add history and move cursor in line
  ];

  shellHook = ''
    gcc test.c -o test -ldl
    ./test

    # enter: ,apropos cog
    rlwrap guile -l ${atomspace.src}/examples/atomspace/basic.scm
  '';
}
