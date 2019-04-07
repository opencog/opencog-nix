{ pkgs ? import <nixpkgs> {} }: with pkgs;

stdenv.mkDerivation rec {
  name = "moses";

  src = fetchFromGitHub {
    owner = "opencog";
    repo = "moses";
    rev = "2600e5da493b0e36b1d656ca7ca3c0663b048cab";
    sha256 = "0v87p18j5kv0f0ywk7ad8x3m5df452lx9j92hqgn579h8w0v6452";
  };

  cogutil = (import ./cogutil.nix {});

  nativeBuildInputs = [
    cmake boost166
    cogutil
    cxxtest

    # optional:
    openmpi
    python3
    python3Packages.cython
    doxygen
  ];

  MPI_EXTRA_LIBRARY="${openmpi}/lib";

  VALGRIND_PROGRAM = "${valgrind}/bin";
  VALGRIND_INCLUDE_DIR = "${valgrind.dev}/include";

  PYTHON_DEST="share/python3.6/site-packages";

  cmakeFlags = [
    ''-DMPI_EXTRA_LIBRARY:PATH=${MPI_EXTRA_LIBRARY}''

    ''-DVALGRIND_PROGRAM:PATH=${VALGRIND_PROGRAM}''
    ''-DVALGRIND_INCLUDE_DIR:PATH=${VALGRIND_INCLUDE_DIR}''

    ''-DPYTHON_DEST:PATH=${PYTHON_DEST}''

    ''-DCMAKE_BUILD_TYPE=Release''
  ];

  patchPhase = ''
    # prevent override of PYTHON_DEST
    sed -i -e 's/OUTPUT_VARIABLE PYTHON_DEST//g' $(find . -type f)
'';

  # doCheck = true;

  meta = with stdenv.lib; {
    description = "MOSES Machine Learning: Meta-Optimizing Semantic Evolutionary Search";
    homepage = https://wiki.opencog.org/w/Meta-Optimizing_Semantic_Evolutionary_Search;
    license = licenses.agpl3;
#    maintainers = with maintainers; [ radivarig ];
    platforms = with platforms; unix;
  };
}
