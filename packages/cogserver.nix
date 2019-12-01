{ pkgs ? import <nixpkgs> {} }: with pkgs;

stdenv.mkDerivation rec {
  name = "cogserver";

  src = fetchFromGitHub {
    owner = "opencog";
    repo = "cogserver";
    rev = "2d5f5f66e5d092f572ad0ea231e104d329687e9c";
    sha256 = "06qn7717c5wcjjcswd6bis125f36n0slzj55xcb4xpm5mgz5m12g";
  };

  cogutil = (import ./cogutil.nix {});
  atomspace = (import ./atomspace.nix {});

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

  PYTHONPATH="${atomspace}/share/python3.6/site-packages/";

  patchPhase = ''
    sed -i -e 's/nosetests3/nosetests/g' $(find . -type f -iname "CMakeLists.txt")

    # exported PYTHONPATH is overriden, force prepend site-packages
    sed -i -e 's#PYTHONPATH=#PYTHONPATH=${PYTHONPATH}:#g' $(find . -type f -iname "CMakeLists.txt")

    # prevent override of GUILE_LOAD_PATH
    sed -i -e 's#SET(GUILE_LOAD_PATH "''${PROJECT_BINARY_DIR}/opencog/scm")##g' $(find . -type f -iname "CMakeLists.txt")

    # disable more than ofter failing test https://github.com/opencog/cogserver/issues/5
    sed -i -e 's#ADD_CXXTEST(ShellUTest)##g' $(find . -type f -iname "CMakeLists.txt")

    # prevent override of PYTHON_DEST
    sed -i -e 's#OUTPUT_VARIABLE PYTHON_DEST#OUTPUT_VARIABLE PYTHON_DEST1#g' $(find . -type f -iname "CMakeLists.txt")

    THIS_DIR=$(pwd)

    mkdir .cache
    export XDG_CACHE_HOME=$THIS_DIR/.cache

    export GUILE_LOAD_PATH="$GUILE_LOAD_PATH:${atomspace}/build"
  '';

  checkPhase = ''
    make test ARGS="-V"
  '';

  doCheck = true;

  meta = with stdenv.lib; {
    description = "OpenCog Newtwork Server";
    homepage = https://wiki.opencog.org/w/Development;
    license = licenses.agpl3;
#    maintainers = with maintainers; [ radivarig ];
    platforms = with platforms; unix;
  };
}
