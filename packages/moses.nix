{ pkgs ? import <nixpkgs> {} }: with pkgs;

stdenv.mkDerivation rec {
  name = "moses";

  src = fetchFromGitHub {
    owner = "opencog";
    repo = "moses";
    rev = "e22740ec51162bf50a39d5228b3ea8bb1d31d552";
    sha256 = "12zfpicf8dgdmabr9ljvq05fil7qhnvjxjgy8cd0j85yamlb6vsg";
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
  PYTHON_DEST=python36.sitePackages;

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
    ${import ../helpers/common-patch.nix {inherit GUILE_SITE_DIR;}}
  '';

  postFixup = ''
    rm -f $out/${PYTHON_DEST}/opencog/__init__.py
  '';

  checkPhase = ''
    make test ARGS="-V"
  '';

  setupHook = ../helpers/common-setup-hook.sh;

  doCheck = true;

  meta = with stdenv.lib; {
    description = "MOSES Machine Learning: Meta-Optimizing Semantic Evolutionary Search";
    homepage = https://wiki.opencog.org/w/Meta-Optimizing_Semantic_Evolutionary_Search;
    license = licenses.agpl3;
#    maintainers = with maintainers; [ radivarig ];
    platforms = with platforms; unix;
  };
}
