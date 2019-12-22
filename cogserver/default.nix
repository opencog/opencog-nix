with import <nixpkgs> {};
stdenv.mkDerivation rec {
  name = "cogserver-env";
  src = ./.;
  env = buildEnv { inherit name; paths = buildInputs; };

  cogserver = import ../packages/cogserver.nix {};
  opencog = import ../packages/opencog.nix {};
  atomspace = import ../packages/atomspace.nix {};

  buildInputs = [
    cogserver
    opencog
    atomspace

    python36 # auto extends PYTHONPATH
    guile # auto extends GUILE_LOAD_PATH

    rlwrap
    telnet
  ];

  shellHook = ''
    # TODO: LD_LIBRARY_PATH is auto extended with <package>/lib
    # maybe copy to $out/lib without "/opencog" to avoid extra extending?
    ${lib.concatStringsSep "\n" (
      map (x: "export LD_LIBRARY_PATH=\"$LD_LIBRARY_PATH:${x}/lib/opencog\"")
    buildInputs)}
    # TODO: refactor repos to handle "lib/opencog" folders better (like "modules")
    ${lib.concatStringsSep "\n" (
      map (x: "export OPENCOG_MODULE_PATHS=\"$OPENCOG_MODULE_PATHS:${x}/lib/opencog/modules\"")
    buildInputs)}
    export OPENCOG_MODULE_PATHS="$OPENCOG_MODULE_PATHS:$LD_LIBRARY_PATH"

    export COGSERVER_CONF=$(mktemp)
    cat <<EOF > $COGSERVER_CONF
    LOG_FILE              = /tmp/cogserver.log
    LOG_LEVEL             = debug
    LOG_TO_STDOUT         = true
    # MODULES = comma, separated, lists

    EOF

    cogserver -c $COGSERVER_CONF &

    # enter "help"
    rlwrap telnet localhost 17001
  '';
}
