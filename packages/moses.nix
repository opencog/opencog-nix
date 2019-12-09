{ pkgs ? import <nixpkgs> {} }: with pkgs;

stdenv.mkDerivation rec {
  name = "moses";

  src = fetchFromGitHub {
    owner = "opencog";
    repo = "moses";
    rev = "6e327d2f1081c06e107ed2df2a50d83c3574c1d7";
    sha256 = "01vd25zd0a9sscm4c25wgpmxppx9qdapqlhgdkyj4w18pjvv4ffq";
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
    python3Packages.nose

    doxygen
  ];

  CPATH="${cxxtest.src}";
  CXXTEST_BIN_DIR = "${cxxtest}/bin";
  MPI_EXTRA_LIBRARY="${openmpi}/lib";
  VALGRIND_PROGRAM = "${valgrind}/bin";
  VALGRIND_INCLUDE_DIR = "${valgrind.dev}/include";
  PYTHON_DEST="share/python3.6/site-packages";

  cmakeFlags = [
    ''-DCPATH:PATH=${CPATH}''
    ''-DCXXTEST_BIN_DIR:PATH=${CXXTEST_BIN_DIR}''
    ''-DMPI_EXTRA_LIBRARY:PATH=${MPI_EXTRA_LIBRARY}''
    ''-DVALGRIND_PROGRAM:PATH=${VALGRIND_PROGRAM}''
    ''-DVALGRIND_INCLUDE_DIR:PATH=${VALGRIND_INCLUDE_DIR}''
    ''-DPYTHON_DEST:PATH=${PYTHON_DEST}''

    ''-DCMAKE_BUILD_TYPE=Release''
  ];

  patchPhase = ''
    # prevent override of PYTHON_DEST
    sed -i -e 's/OUTPUT_VARIABLE PYTHON_DEST//g' $(find . -type f)
    sed -i -e 's/nosetests3/nosetests/g' $(find . -type f -iname "CMakeLists.txt")
  '';

  checkPhase = ''
    make test
  '';

  enableParallelChecking = false;
  doCheck = true;

  meta = with stdenv.lib; {
    description = "MOSES Machine Learning: Meta-Optimizing Semantic Evolutionary Search";
    homepage = https://wiki.opencog.org/w/Meta-Optimizing_Semantic_Evolutionary_Search;
    license = licenses.agpl3;
#    maintainers = with maintainers; [ radivarig ];
    platforms = with platforms; unix;
  };
}
