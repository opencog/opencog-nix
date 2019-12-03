{ pkgs ? import <nixpkgs> {} }: with pkgs;

stdenv.mkDerivation rec {
  name = "attention";

  src = fetchFromGitHub {
    owner = "opencog";
    repo = "attention";
    rev = "e91ade5180b170a3564c05c069b4f11df1fe23f7";
    sha256 = "1pmgdnxmcf3hrc9dm1bkhp44qyp546lsp1bg5kd5a2v8zdfmb3r7";
  };

  cogutil = (import ./cogutil.nix {});
  atomspace = (import ./atomspace.nix {});
  cogserver = (import ./cogserver.nix {});

  netcat = (import ./other/netcat-openbsd.nix {});

  nativeBuildInputs = [
    cmake
    boost166
    cxxtest

    netcat
  ];

  buildInputs = [
    guile gmp

    cogutil
    atomspace
    cogserver

    python36
    python36Packages.cython
    python36Packages.nose

    doxygen
  ];

  CPATH = "${cxxtest.src}:${atomspace.src}";
  CXXTEST_BIN_DIR = "${cxxtest}/bin";

  GUILE_INCLUDE_DIR = "${guile.dev}/include/guile/2.2";
  GMP_INCLUDE_DIR = "${gmp.dev}/include";
  VALGRIND_INCLUDE_DIR = "${valgrind.dev}/include";

  GUILE_SITE_DIR="share/guile/site";
  PYTHON_DEST="share/python3.6/site-packages";

  cmakeFlags = [
    ''-DCPATH:PATH=${CPATH}''
    ''-DCXXTEST_BIN_DIR:PATH=${CXXTEST_BIN_DIR}''

    ''-DGUILE_INCLUDE_DIR:PATH=${GUILE_INCLUDE_DIR}''
    ''-DGMP_INCLUDE_DIR:PATH=${GMP_INCLUDE_DIR}''
    ''-DVALGRIND_INCLUDE_DIR:PATH=${VALGRIND_INCLUDE_DIR}''

    ''-DGUILE_SITE_DIR:PATH=${GUILE_SITE_DIR}''
    ''-DPYTHON_DEST:PATH=${PYTHON_DEST}''
  ];

  patchPhase = ''
    mkdir -p $out/share/opencog
    cp -r ${atomspace.src}/cmake $out/share/opencog

    cp -r ${cogserver}/lib/opencog/modules opencog

    mkdir -p build/opencog/agents
    cp ${cogserver}/lib/opencog/modules/libagents.so build/opencog/agents

    # bad..
    cp -r ${atomspace}/share/guile/site build/opencog/agents

    sed -i -e 's/nosetests3/nosetests/g' $(find . -type f -iname "CMakeLists.txt")

    export PYTHONPATH="$PYTHONPATH:${atomspace}/share/python3.6/site-packages";
    export PYTHONPATH="$PYTHONPATH:${cogserver}/share/python3.6/site-packages";

    # exported PYTHONPATH is overriden, force prepend site-packages
    sed -i -e "s#PYTHONPATH=#PYTHONPATH=$PYTHONPATH:#g" $(find . -type f -iname "CMakeLists.txt")

    # prevent override of GUILE_LOAD_PATH
    sed -i -e 's#SET(GUILE_LOAD_PATH "''${PROJECT_BINARY_DIR}/opencog/scm")##g' $(find . -type f -iname "CMakeLists.txt")

    # prevent override of PYTHON_DEST
    sed -i -e 's#OUTPUT_VARIABLE PYTHON_DEST#OUTPUT_VARIABLE PYTHON_DEST1#g' $(find . -type f -iname "CMakeLists.txt")

    THIS_DIR=$(pwd)

    mkdir .cache
    export XDG_CACHE_HOME=$THIS_DIR/.cache

    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${cogutil}/lib/opencog"
    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${atomspace}/lib/opencog"
    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${cogserver}/lib/opencog/modules"

    export GUILE_LOAD_PATH="$GUILE_LOAD_PATH:$(pwd)/build"
    export GUILE_LOAD_PATH="$GUILE_LOAD_PATH:$(pwd)/build/opencog"
    export GUILE_LOAD_PATH="$GUILE_LOAD_PATH:$(pwd)/build/opencog/scm"
    export GUILE_LOAD_PATH="$GUILE_LOAD_PATH:$(pwd)/build/opencog/scm/opencog"

    export GUILE_LOAD_PATH="$GUILE_LOAD_PATH:${src}"
    export GUILE_LOAD_PATH="$GUILE_LOAD_PATH:${src}/opencog"
    export GUILE_LOAD_PATH="$GUILE_LOAD_PATH:${src}/opencog/scm"

    export GUILE_LOAD_PATH="$GUILE_LOAD_PATH:${cogutil}"
    export GUILE_LOAD_PATH="$GUILE_LOAD_PATH:${cogutil}/opencog/scm"

    export GUILE_LOAD_PATH="$GUILE_LOAD_PATH:${atomspace}"
    export GUILE_LOAD_PATH="$GUILE_LOAD_PATH:${atomspace}/opencog/scm"
    export GUILE_LOAD_PATH="$GUILE_LOAD_PATH:${atomspace}/share/guile/site"

    export GUILE_LOAD_PATH="$GUILE_LOAD_PATH:${cogserver}"
    export GUILE_LOAD_PATH="$GUILE_LOAD_PATH:${cogserver}/opencog/scm"
  '';

  checkPhase = ''
    make test ARGS="-V"
  '';

  enableParallelChecking = false;

  doCheck = true;

  meta = with stdenv.lib; {
    description = "OpenCog Attention Allocation Subsystem";
    homepage = https://wiki.opencog.org/w/Development;
    license = licenses.agpl3;
#    maintainers = with maintainers; [ radivarig ];
    platforms = with platforms; unix;
  };
}
