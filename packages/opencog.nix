{ pkgs }: with pkgs;

stdenv.mkDerivation rec {
  name = "opencog";

  src = fetchFromGitHub {
    owner = "opencog";
    repo = "opencog";
    rev = "7d8862eb1dfa459ca9d5a3248cd28d928496dc5c";
    sha256 = "1skcj3b1mcrnlnhwkdgz9yqj27adgsy4arpl8mwvdbcjh3w1ghiv";
  };

  cogutil = (import ./cogutil.nix { inherit pkgs; });
  atomspace = (import ./atomspace.nix { inherit pkgs; });
  link-grammar = (import ./link-grammar.nix { inherit pkgs; });

  nativeBuildInputs = [
    cmake
    cogutil
    atomspace
    xorg.libpthreadstubs
    boost166
    # cpprest # not in nixpkgs
    cxxtest
    pkgconfig
    pcre
    # xdmcp # not in nixpkgs; required by xcb, xdmcp.pc dir to PKG_CONFIG_PATH
    gtk3
    guile
    gmp # dep of guile
    # dgemm_ # ?
    blas
    liblapack
    link-grammar
    libuuid
    # moses
    # octomap
    protobuf
    python3
    python3Packages.cython
    tbb
    valgrind
    # zeromq #ZMQ_LIBRARY
    jsoncpp
    stack
    doxygen
    graphviz # doxygen dot
  ];

  CXXTEST_BIN_DIR = "${cxxtest}/bin";

  GUILE_INCLUDE_DIR = "${guile.dev}/include/guile/2.2";
  GMP_INCLUDE_DIR = "${gmp.dev}/include";
  VALGRIND_INCLUDE_DIR = "${valgrind.dev}/include";

  cmakeFlags = [
    ''-DGUILE_INCLUDE_DIR:PATH=${GUILE_INCLUDE_DIR}''
    ''-DGMP_INCLUDE_DIR:PATH=${GMP_INCLUDE_DIR}''
    ''-DVALGRIND_INCLUDE_DIR:PATH=${VALGRIND_INCLUDE_DIR}''
  ];

  patchPhase = ''
    mkdir -p $out/share/opencog
    cp -r ${cogutil.src}/cmake $out/share/opencog/
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
