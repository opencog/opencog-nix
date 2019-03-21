{ pkgs, config }: with pkgs;
stdenv.mkDerivation rec {
  name = "atomspace";

  src = fetchFromGitHub {
    owner = "opencog";
    repo = "atomspace";
    rev = "3ed32869896c43d7490115e558db48174315bf39";
    sha256 = "1ki5rpqn4kychbr238b5j3xl610frvjmfisf8bn3vqhwdsh7x03q";
  };

  nativeBuildInputs = [
    cmake boost166
    (import ./cogutil.nix { inherit pkgs; inherit config;})
    guile gmp
    python3
    python3Packages.cython
    cxxtest
    postgresql
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
