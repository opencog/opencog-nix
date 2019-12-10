{ pkgs ? import <nixpkgs> {} }: with pkgs;

stdenv.mkDerivation rec {
  name = "atomspace";

  src = fetchFromGitHub {
    owner = "opencog";
    repo = "atomspace";
    rev = "acbe08ae472e1aec7575d041e4b7e4f9e1dcb3a8";
    sha256 = "0yyh0xmw0imnmwa2badyawgjj4m1pkiwxgbwsfs69y4646gnmccp";
  };

  cogutil = (import ./cogutil.nix {});
  nativeBuildInputs = [
    cmake boost166
    cxxtest
  ];

  buildInputs = [
    cogutil

    guile gmp

    python36
    python36Packages.cython
    python36Packages.nose

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
    # fix python nosetests binary name
    sed -i -e 's/nosetests3/nosetests/g' $(find . -type f -iname "CMakeLists.txt")

    # prevent override of PYTHON_DEST
    sed -i -e 's/OUTPUT_VARIABLE PYTHON_DEST//g' $(find . -type f)

    # replace shared paths
    sed -i -e "s=/usr/local/share/opencog/scm=$out/${GUILE_SITE_DIR}/opencog/scm=g" $(find . -type f)

    # psql setup
    ${import ../init-psql-db.nix {inherit pkgs;}} # prepare psql
    createdb opencog_test # create test database
    psql -c "CREATE USER opencog_tester WITH PASSWORD 'cheese';" # create test user
    # NOTE: create with test user, or user will be nixbld and grants to other users seem to not work
    cat ${src}/opencog/persist/sql/multi-driver/atom.sql | psql opencog_test -U opencog_tester
  '';

  enableParallelChecking = false;
  doCheck = true;

  meta = with stdenv.lib; {
    description = "The OpenCog hypergraph database, query system and rule engine";
    homepage = https://wiki.opencog.org/w/AtomSpace;
    license = licenses.agpl3;
#    maintainers = with maintainers; [ radivarig ];
    platforms = with platforms; unix;
  };
}
