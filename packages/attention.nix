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
    cogutil
    atomspace
    cogserver

    guile gmp
    python36
    python36Packages.cython
    python36Packages.nose
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
    # fix python nosetests binary name
    sed -i -e 's/nosetests3/nosetests/g' $(find . -type f)

    # prevent override of PYTHON_DEST
    sed -i -e 's#OUTPUT_VARIABLE PYTHON_DEST#OUTPUT_VARIABLE PYTHON_DEST1#g' $(find . -type f -iname "CMakeLists.txt")

    # replace shared paths
    sed -i -e "s=/usr/local/share/opencog/scm=$out/${GUILE_SITE_DIR}/opencog/scm=g" $(find . -type f)

    # # copy over cmake from atomspace required for `atom_types.h`?
    # # comment from attention/tests/CMakeLists.txt:
    # # All tests should load the atomspace scm from the build dir, unless the scm
    # # file is specific to the test (this variable is used by ADD_CXXTEST)
    # SET(GUILE_LOAD_PATH "''${PROJECT_BINARY_DIR}/opencog/scm")
    mkdir -p $out/share/opencog
    cp -r ${atomspace.src}/cmake $out/share/opencog

    # for unit tests, why is GUILE_LOAD_PATH overrided?
    sed -i -e 's#SET(GUILE_LOAD_PATH "''${PROJECT_BINARY_DIR}/opencog/scm")##g' $(find . -type f -iname "CMakeLists.txt")

    cp -r ${cogserver}/lib/opencog/modules opencog
    mkdir -p build/opencog/agents
    cp ${cogserver}/lib/opencog/modules/libagents.so build/opencog/agents

    # extend GUILE_LOAD_PATH
    export GUILE_LOAD_PATH="$GUILE_LOAD_PATH:${atomspace}"
    export GUILE_LOAD_PATH="$GUILE_LOAD_PATH:${atomspace}/share/guile/site"

    export GUILE_LOAD_PATH="$GUILE_LOAD_PATH:${cogserver}/share/guile/site"

    export GUILE_LOAD_PATH="$GUILE_LOAD_PATH:$(pwd)/build/opencog"
    export GUILE_LOAD_PATH="$GUILE_LOAD_PATH:$(pwd)/build/opencog/scm"
    export GUILE_LOAD_PATH="$GUILE_LOAD_PATH:$(pwd)/build/opencog/scm/opencog"

    # extend LD_LIBRARY_PATH
    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${atomspace}/lib/opencog"
    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${cogserver}/lib/opencog"

    # extend PYTHONPATH
    export PYTHONPATH="$PYTHONPATH:${atomspace}/share/python3.6/site-packages"
    export PYTHONPATH="$PYTHONPATH:${cogserver}/share/python3.6/site-packages"

    # exported PYTHONPATH is overriden, force prepend site-packages
    sed -i -e "s#PYTHONPATH=#PYTHONPATH=$PYTHONPATH:#g" $(find . -type f -iname "CMakeLists.txt")
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
