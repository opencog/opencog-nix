{ pkgs }: with pkgs;

stdenv.mkDerivation rec {
  name = "moses";

  src = fetchFromGitHub {
    owner = "opencog";
    repo = "moses";
    rev = "4414eaddf1db965aaae645f45faf882c3247539a";
    sha256 = "1d7f8hs71090nmchr6gkp2cw32q9fy8c83iv1w7ww3sbv4dmj2y5";
  };

  cogutil = (import ./cogutil.nix { inherit pkgs; });

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
  cmakeFlags = [
    ''-DMPI_EXTRA_LIBRARY:PATH=${MPI_EXTRA_LIBRARY}''

    ''-DVALGRIND_PROGRAM:PATH=${VALGRIND_PROGRAM}''
    ''-DVALGRIND_INCLUDE_DIR:PATH=${VALGRIND_INCLUDE_DIR}''

    ''-DCMAKE_BUILD_TYPE=Release''
  ];

  # doCheck = true;
  # checkTarget = "test";

  meta = with stdenv.lib; {
    description = "MOSES Machine Learning: Meta-Optimizing Semantic Evolutionary Search";
    homepage = https://wiki.opencog.org/w/Meta-Optimizing_Semantic_Evolutionary_Search;
    license = licenses.agpl3;
#    maintainers = with maintainers; [ radivarig ];
    platforms = with platforms; unix;
  };
}
