{ pkgs }: with pkgs;

stdenv.mkDerivation rec {
  name = "opencog";

  src = fetchFromGitHub {
    owner = "opencog";
    repo = "opencog";
    rev = "cf188947294f48a5473f87adaf34250e9bcca4ef";
    sha256 = "1ngh0nal1khchmd8x4b8m2c4b7p53x6ih253k4hnif0q2pqfldpn";
  };

  cogutil = (import ./cogutil.nix { inherit pkgs; });
  atomspace = (import ./atomspace.nix { inherit pkgs; });
  link-grammar = (import ./link-grammar.nix { inherit pkgs; });
  moses = (import ./moses.nix { inherit pkgs; });

  octomap = (import ./other/octomap.nix { inherit pkgs; });
  cpprest = (import ./other/cpprest.nix { inherit pkgs; });

  nativeBuildInputs = [
    cmake boost166
    cogutil
    atomspace
    guile
    gmp # dep of guile
    link-grammar
    libuuid
    octomap

    #optional:
    moses
    python3
    python3Packages.cython
    cxxtest
    pkgconfig
    pcre
    valgrind
    stack
    doxygen

    # deprecated or soon to be:
    # cpprest # will be removed with the new pattern miner
    # openssl # required by cpprest

    # zeromq
    # jsoncpp
    # protobuf
    # blas
    # liblapack
    # gtk3
  ];

  CXXTEST_BIN_DIR = "${cxxtest}/bin";
  # ZMQ_LIBRARY="${zeromq}/lib/libzmq.so";

  GUILE_INCLUDE_DIR = "${guile.dev}/include/guile/2.2";
  GMP_INCLUDE_DIR = "${gmp.dev}/include";
  VALGRIND_INCLUDE_DIR = "${valgrind.dev}/include";

  # cpprest_LIBRARY = "${cpprest}/lib/libcpprest.so";
  # cpprest_version_FILE = "${cpprest}/include/cpprest/version.h";

  cmakeFlags = [
    ''-DGUILE_INCLUDE_DIR:PATH=${GUILE_INCLUDE_DIR}''
    ''-DGMP_INCLUDE_DIR:PATH=${GMP_INCLUDE_DIR}''
    ''-DVALGRIND_INCLUDE_DIR:PATH=${VALGRIND_INCLUDE_DIR}''

    # ''-Dcpprest_version_FILE:PATH=${cpprest_version_FILE}''
  ];

  patchPhase = ''
    mkdir -p $out/share/opencog
    cp -r ${atomspace.src}/cmake $out/share/opencog/
  '';

  # https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/setup-hooks/move-lib64.sh#L6
  dontMoveLib64 = 1;

  # doCheck = true;
  # checkTarget = "test";

  meta = with stdenv.lib; {
    description = "A framework for integrated Artificial Intelligence & Artificial General Intelligence (AGI)";
    homepage = https://wiki.opencog.org/w/Development;
    license = licenses.agpl3;
#    maintainers = with maintainers; [ radivarig ];
    platforms = with platforms; unix;
  };
}
