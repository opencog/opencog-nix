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

  GUILE_INCLUDE_DIR = "${guile.dev}/include/guile/2.2";
  GMP_INCLUDE_DIR = "${gmp.dev}/include";

  GUILE_SITE_DIR="share/guile/site";
  PYTHON_DEST="share/python3.6/site-packages";

  CXXTEST_BIN_DIR = "${cxxtest}/bin";
  CPLUS_INCLUDE_PATH = "${cxxtest.src}";

  MPI_EXTRA_LIBRARY = "${openmpi}/lib";

  cmakeFlags = [
    ''-DGUILE_INCLUDE_DIR:PATH=${GUILE_INCLUDE_DIR}''
    ''-DGMP_INCLUDE_DIR:PATH=${GMP_INCLUDE_DIR}''

    ''-DGUILE_SITE_DIR:PATH=${GUILE_SITE_DIR}''
    ''-DPYTHON_DEST:PATH=${PYTHON_DEST}''

    ''-DCXXTEST_BIN_DIR:PATH=${CXXTEST_BIN_DIR}''
    ''-DCPLUS_INCLUDE_PATH:PATH=${CPLUS_INCLUDE_PATH}''

    ''-DMPI_EXTRA_LIBRARY:PATH=${MPI_EXTRA_LIBRARY}''
    ''-DCMAKE_BUILD_TYPE=Release''
  ];

  patchPhase = ''
    ${import ../helpers/extend-env.nix {paths = [ "$(pwd)" cogutil ];}}
    ${import ../helpers/common-patch.nix {inherit GUILE_SITE_DIR;}}
  '';

  postBuild = ''
    ${import ../helpers/extend-env.nix {paths = [ "$(pwd)" ];}}
  '';

  checkPhase = ''
    make test ARGS="-V"
  '';

  doCheck = true;

  meta = with stdenv.lib; {
    description = "MOSES Machine Learning: Meta-Optimizing Semantic Evolutionary Search";
    homepage = https://wiki.opencog.org/w/Meta-Optimizing_Semantic_Evolutionary_Search;
    license = licenses.agpl3;
#    maintainers = with maintainers; [ radivarig ];
    platforms = with platforms; unix;
  };
}
