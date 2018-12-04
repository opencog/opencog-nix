{ pkgs }: with pkgs;

stdenv.mkDerivation rec {
  name = "opencog";

  src = fetchFromGitHub {
    owner = "opencog";
    repo = "opencog";
    rev = "7d8862eb1dfa459ca9d5a3248cd28d928496dc5c";
    sha256 = "1skcj3b1mcrnlnhwkdgz9yqj27adgsy4arpl8mwvdbcjh3w1ghiv";
  };

  nativeBuildInputs = [
    cmake
    boost166
    (import ./cogutil.nix { inherit pkgs; })
    (import ./atomspace.nix { inherit pkgs; })
    guile gmp
    python
    cxxtest
    pkgconfig
    blas
    libuuid
    # laplack
    # cpprest
    # gtk3
    # cheev_
    python27Packages.cython
    # valgrind # path VALGRIND_INCLUDE_DIR
    # octomap
    protobuf
    zeromq
    jsoncpp

    # link-grammar
    # moses
  ];

  GUILE_LIBRARY = "${guile}/lib";
  GUILE_INCLUDE_DIR = "${guile.dev}/include/guile/2.2";

  GMP_LIBRARY = "${gmp}/lib";
  GMP_INCLUDE_DIR = "${gmp.dev}/include";

  cmakeFlags = [
    ''-DGMP_LIBRARY:PATH=${GMP_LIBRARY}''
    ''-DGMP_INCLUDE_DIR:PATH=${GMP_INCLUDE_DIR}''

    ''-DGUILE_LIBRARY:PATH=${GUILE_LIBRARY}''
    ''-DGUILE_INCLUDE_DIR:PATH=${GUILE_INCLUDE_DIR}''
  ];

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
