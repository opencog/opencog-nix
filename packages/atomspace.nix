{ pkgs }: with pkgs;

stdenv.mkDerivation rec {
  name = "atomspace";

  src = fetchFromGitHub {
    owner = "opencog";
    repo = "atomspace";
    rev = "fddaf5426c3f1d379c4a92c7fd396e9736551ad1";
    sha256 = "1kblvgc2ryjjh9fac1p2r00mh0ak855i1fcswn3ria5l8v8ndy0q";
  };

  nativeBuildInputs = [
    cmake boost166
    (import ./cogutil.nix { inherit pkgs; })
    guile gmp
    python3
    python3Packages.cython
    cxxtest
  ];

  GUILE_INCLUDE_DIR = "${guile.dev}/include/guile/2.2";
  GMP_INCLUDE_DIR = "${gmp.dev}/include";

  cmakeFlags = [
    ''-DGUILE_INCLUDE_DIR:PATH=${GUILE_INCLUDE_DIR}''
    ''-DGMP_INCLUDE_DIR:PATH=${GMP_INCLUDE_DIR}''
  ];

  # doCheck = true;
  # checkTarget = "test";
  
  meta = with stdenv.lib; {
    description = "The OpenCog hypergraph database, query system and rule engine";
    homepage = https://wiki.opencog.org/w/AtomSpace;
    license = licenses.agpl3;
#    maintainers = with maintainers; [ radivarig ];
    platforms = with platforms; unix;
  };
}
