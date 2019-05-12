{ pkgs ? import <nixpkgs> {} }: with pkgs;

stdenv.mkDerivation rec {
  name = "atomspace";

  src = fetchFromGitHub {
    owner = "opencog";
    repo = "atomspace";
    rev = "11f84ad0e0a441a67c7447259778fd492dc2abcd";
    sha256 = "0wxql81ff9wab2anzrpsk3zm1plxzp69rvwhgmn6niz5a7dh0xih";
  };

  cogutil = (import ./cogutil.nix {});
  nativeBuildInputs = [
    cmake boost166
    cxxtest
  ];

  buildInputs = [
    cogutil

    guile gmp
    python3
    python3Packages.cython
    postgresql
  ];

  GUILE_INCLUDE_DIR = "${guile.dev}/include/guile/2.2";
  GMP_INCLUDE_DIR = "${gmp.dev}/include";

  # fixes for writting into other packages output paths
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
    # prevent override of PYTHON_DEST
    sed -i -e 's/OUTPUT_VARIABLE PYTHON_DEST//g' $(find . -type f)

    sed -i -e "s=/usr/local/share/opencog/scm=${src}/opencog/scm=g" $(find . -type f)

    ${import ../init-psql-db.nix} # prepare psql
    createdb opencog_test # create test database
    psql -c "CREATE USER opencog_tester WITH PASSWORD 'cheese';" # create test user
    # NOTE: create with test user, or user will be nixbld and grants to other users seem to not work
    cat ${src}/opencog/persist/sql/multi-driver/atom.sql | psql opencog_test -U opencog_tester
  '';

  postBuild = ''
    ATOM_TYPES_DIR="build/opencog/atoms/atom_types"
    mkdir -p $out/$ATOM_TYPES_DIR
    cp ../$ATOM_TYPES_DIR/core_types.scm $out/$ATOM_TYPES_DIR
    ls -R $out/build

    # TODO: do with patchelf
    mkdir early_lib
    cp $(find . -name "*.so") early_lib
    ls -R early_lib

    THIS_DIR=$(pwd)
    export GUILE_LOAD_PATH="$out/build:${src}/opencog/scm"
    export LD_LIBRARY_PATH="$THIS_DIR/early_lib"

    mkdir .cache
    export XDG_CACHE_HOME=$THIS_DIR/.cache
  '';

  doCheck = true;

  meta = with stdenv.lib; {
    description = "The OpenCog hypergraph database, query system and rule engine";
    homepage = https://wiki.opencog.org/w/AtomSpace;
    license = licenses.agpl3;
#    maintainers = with maintainers; [ radivarig ];
    platforms = with platforms; unix;
  };
}
