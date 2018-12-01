with import <nixpkgs> {};
stdenv.mkDerivation rec {
  name = "env";
  src = ./.;
  env = buildEnv { inherit name; paths = buildInputs; };

  opencog = (import ../opencog);
  opencog_src = "${opencog.src}";
  opencog_build = "${opencog.build}/build";

  atomspace = (import ../atomspace);
  atomspace_src ="${atomspace.src}";
  atomspace_build ="${atomspace.build}/build";

  opencog_scm = "${atomspace_src}/opencog/scm";

  # atomspaceAll = symlinkJoin {name="atomspace-all"; paths = [
  #   atomspace atomspace.build
  # ];};

  buildInputs = [
    cmake
    guile
    atomspace
    opencog
  ];

  shellHook = ''
    export LTDL_LIBRARY_PATH="${atomspace_build}/opencog/guile" # has libsmob.so

    echo "LTDL_LIBRARY_PATH = $LTDL_LIBRARY_PATH"
    ls $LTDL_LIBRARY_PATH

    # error: In procedure dynamic-link: file: "libsmob", message: "file not found"
    #  when calling: (use-modules (opencog))
    # guile -L $opencog_scm # has opencog.scm

    # simpler test for loading libsmob.so
    gcc -o test test.c -ldl

    ./test
  '';
}
