{ pkgs ? import <nixpkgs> {} }: with pkgs;

stdenv.mkDerivation rec {
  name = "ure";

  src = fetchFromGitHub {
    owner = "opencog";
    repo = "ure";
    rev = "02710e6ff5a456d6f38a66513829d7e71a902b72";
    sha256 = "0j5kpvq6b1dpl4g9qzc90d336b3a5cx7cxsvrcbv3lsbwj1gfaqj";
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
    sed -i -e 's/nosetests3/nosetests/g' $(find . -type f -iname "CMakeLists.txt")

    # prevent override of PYTHON_DEST
    sed -i -e 's#OUTPUT_VARIABLE PYTHON_DEST#OUTPUT_VARIABLE PYTHON_DEST1#g' $(find . -type f -iname "CMakeLists.txt")

    # prevent override of GUILE_LOAD_PATH
    sed -i -e 's#SET(GUILE_LOAD_PATH "''${PROJECT_BINARY_DIR}/opencog/scm")##g' $(find . -type f -iname "CMakeLists.txt")
    sed -i -e 's#"GUILE_LOAD_PATH=''${GUILE_LOAD_PATH}"##g' $(find . -type f -iname "CMakeLists.txt")


    # extend GUILE_LOAD_PATH
    export GUILE_LOAD_PATH="$GUILE_LOAD_PATH:${atomspace}"
    export GUILE_LOAD_PATH="$GUILE_LOAD_PATH:${atomspace}/share/guile/site"

    export GUILE_LOAD_PATH="$GUILE_LOAD_PATH:$(pwd)/build/opencog"
    export GUILE_LOAD_PATH="$GUILE_LOAD_PATH:$(pwd)/build/opencog/scm"
    export GUILE_LOAD_PATH="$GUILE_LOAD_PATH:$(pwd)/build/opencog/scm/opencog"

    # extend LD_LIBRARY_PATH
    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${atomspace}/lib/opencog"
    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${atomspace}/share/python3.6/site-packages/opencog"

    # extend PYTHONPATH
    export PYTHONPATH="$PYTHONPATH:${atomspace}/share/python3.6/site-packages"
    export PYTHONPATH="$PYTHONPATH:${atomspace}/share/python3.6/site-packages/opencog"

    # exported PYTHONPATH is overriden, force prepend site-packages
    sed -i -e "s#PYTHONPATH=#PYTHONPATH=$PYTHONPATH:#g" $(find . -type f -iname "CMakeLists.txt")

    mkdir .cache
    export XDG_CACHE_HOME=$(pwd)/.cache

  '';

  checkPhase = ''
    make test ARGS="-V"
  '';

  enableParallelChecking = false;
  doCheck = true;

  meta = with stdenv.lib; {
    description = "Unified Rule Engine. Graph rewriting system for the AtomSpace. Used as reasoning engine for OpenCog.";
    homepage = https://wiki.opencog.org/w/Development;
    license = licenses.agpl3;
#    maintainers = with maintainers; [ radivarig ];
    platforms = with platforms; unix;
  };
}
