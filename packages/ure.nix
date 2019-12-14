{ pkgs ? import <nixpkgs> {} }: with pkgs;

stdenv.mkDerivation rec {
  name = "ure";

  src = fetchFromGitHub {
    owner = "opencog";
    repo = "ure";
    rev = "128ae411f2977c3425157b90edfd07bddd3e4b1f";
    sha256 = "0jl4iaxg48db12f1kdy1arslsxasf6y5h5zmw880a1xvjfj24zv1";
  };

  cogutil = (import ./cogutil.nix {});
  atomspace = (import ./atomspace.nix {});

  nativeBuildInputs = [
    cmake
    boost166
    cxxtest
  ];

  buildInputs = [
    cogutil
    atomspace

    guile gmp

    python36
    python36Packages.cython
    python36Packages.nose

    doxygen
  ];

  GUILE_INCLUDE_DIR = "${guile.dev}/include/guile/2.2";
  GMP_INCLUDE_DIR = "${gmp.dev}/include";

  GUILE_SITE_DIR="share/guile/site";
  PYTHON_DEST="share/python3.6/site-packages";

  CXXTEST_BIN_DIR = "${cxxtest}/bin";
  CPLUS_INCLUDE_PATH = "${cxxtest.src}";

  cmakeFlags = [
    ''-DGUILE_INCLUDE_DIR:PATH=${GUILE_INCLUDE_DIR}''
    ''-DGMP_INCLUDE_DIR:PATH=${GMP_INCLUDE_DIR}''

    ''-DGUILE_SITE_DIR:PATH=${GUILE_SITE_DIR}''
    ''-DPYTHON_DEST:PATH=${PYTHON_DEST}''

    ''-DCXXTEST_BIN_DIR:PATH=${CXXTEST_BIN_DIR}''
    ''-DCPLUS_INCLUDE_PATH:PATH=${CPLUS_INCLUDE_PATH}''
  ];

  patchPhase = ''
    ${import ../helpers/extend-env.nix {paths = [ "$(pwd)" cogutil atomspace atomspace.src ];}}
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
    description = "Unified Rule Engine. Graph rewriting system for the AtomSpace. Used as reasoning engine for OpenCog.";
    homepage = https://wiki.opencog.org/w/Development;
    license = licenses.agpl3;
#    maintainers = with maintainers; [ radivarig ];
    platforms = with platforms; unix;
  };
}
