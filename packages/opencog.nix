{ pkgs ? import <nixpkgs> {} }: with pkgs;

stdenv.mkDerivation rec {
  name = "opencog";

  src = fetchFromGitHub {
    owner = "opencog";
    repo = "opencog";
    rev = "087df53cf72901f043fa0fed946e385136f91474";
    sha256 = "19cv049gx9rj6v5051mxn74dvm4zf1vgglqgi7xh39lfar305wwp";
  };

  cogutil = (import ./cogutil.nix {});
  atomspace = (import ./atomspace.nix {});
  cogserver = (import ./cogserver.nix {});
  attention = (import ./attention.nix {});
  link-grammar = (import ./link-grammar.nix {});
  moses = (import ./moses.nix {});

  octomap = (import ./other/octomap.nix {});
  # cpprest = (import ./other/cpprest.nix {});

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
    attention
    link-grammar
    moses

    libuuid
    octomap

    python36
    python36Packages.cython
    python36Packages.nose
    pkgconfig
    pcre
    valgrind
    stack
    doxygen

    # deprecated or soon to be:
    # cpprest # will be removed with the new pattern miner
    # openssl # required by cpprest

    # zeromq
    # jsoncpp
    # protobuf
    # blas
    # liblapack
    # gtk3
  ];

  CPATH = "${cxxtest.src}:${atomspace.src}";
  CXXTEST_BIN_DIR = "${cxxtest}/bin";
  # ZMQ_LIBRARY="${zeromq}/lib/libzmq.so";

  GUILE_INCLUDE_DIR = "${guile.dev}/include/guile/2.2";
  GMP_INCLUDE_DIR = "${gmp.dev}/include";
  VALGRIND_INCLUDE_DIR = "${valgrind.dev}/include";

  GUILE_SITE_DIR="share/guile/site";
  PYTHON_DEST="share/python3.6/site-packages";

  # cpprest_LIBRARY = "${cpprest}/lib/libcpprest.so";
  # cpprest_version_FILE = "${cpprest}/include/cpprest/version.h";

  cmakeFlags = [
    ''-DCPATH:PATH=${CPATH}''
    ''-DCXXTEST_BIN_DIR:PATH=${CXXTEST_BIN_DIR}''

    ''-DGUILE_INCLUDE_DIR:PATH=${GUILE_INCLUDE_DIR}''
    ''-DGMP_INCLUDE_DIR:PATH=${GMP_INCLUDE_DIR}''
    ''-DVALGRIND_INCLUDE_DIR:PATH=${VALGRIND_INCLUDE_DIR}''

    ''-DGUILE_SITE_DIR:PATH=${GUILE_SITE_DIR}''
    ''-DPYTHON_DEST:PATH=${PYTHON_DEST}''

    # ''-Dcpprest_version_FILE:PATH=${cpprest_version_FILE}''
  ];

  LOCALE_ARCHIVE_2_27 = "${pkgs.glibcLocales}/lib/locale/locale-archive";

  patchPhase = ''
    sed -i -e 's/nosetests3/nosetests/g' $(find . -type f -iname "CMakeLists.txt")

    mkdir -p $out/share/opencog
    cp -r ${atomspace.src}/cmake $out/share/opencog/

    THIS_DIR=$(pwd)
    mkdir .cache
    export XDG_CACHE_HOME=$THIS_DIR/.cache

    sed -i -e 's/OUTPUT_VARIABLE PYTHON_DEST//g' $(find . -type f)

    sed -i -e 's~load \\"" GUILE_SITE_DIR "/~load-from-path \\"~g' $(find . -type f)

    sed -i -e 's~//logger().set_print_to_stdout_flag(true);~logger().set_print_to_stdout_flag(true);~g' $(find . -type f -iname "*.cxxtest")

    export GUILE_LOAD_PATH="$GUILE_LOAD_PATH:${atomspace}/build"
    export GUILE_LOAD_PATH="$GUILE_LOAD_PATH:${atomspace.src}/opencog/scm"

    export GUILE_LOAD_PATH="$GUILE_LOAD_PATH:${cogserver}/build"

    export GUILE_LOAD_PATH="$GUILE_LOAD_PATH:$THIS_DIR/build/opencog/scm"
    export GUILE_LOAD_PATH="$GUILE_LOAD_PATH:${src}/opencog"
    export GUILE_LOAD_PATH="$GUILE_LOAD_PATH:${src}/tests"
  '';

  postBuild = ''
    mkdir early_lib
    cp $(find . -name "*.so") early_lib
    ls -R early_lib

    THIS_DIR=$(pwd)
    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$THIS_DIR/early_lib"
    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${atomspace}/lib/opencog"

    mkdir .cache
    export XDG_CACHE_HOME=$THIS_DIR/.cache
  '';

  # https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/setup-hooks/move-lib64.sh#L6
  dontMoveLib64 = 1;

  checkPhase = ''
    make test ARGS="-V"
  '';

  doCheck = true;

  meta = with stdenv.lib; {
    description = "A framework for integrated Artificial Intelligence & Artificial General Intelligence (AGI)";
    homepage = https://wiki.opencog.org/w/Development;
    license = licenses.agpl3;
#    maintainers = with maintainers; [ radivarig ];
    platforms = with platforms; unix;
  };
}
