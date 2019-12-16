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

  GUILE_SITE_DIR="share/guile/site";
  PYTHON_DEST=python36.sitePackages;

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
    # psql setup
    ${import ../helpers/init-psql-db.nix {inherit pkgs;}} # prepare psql
    createdb opencog_test # create test database
    psql -c "CREATE USER opencog_tester WITH PASSWORD 'cheese';" # create test user
    # NOTE: create with test user, or user will be nixbld and grants to other users seem to not work
    cat ${src}/opencog/persist/sql/multi-driver/atom.sql | psql opencog_test -U opencog_tester

    export GUILE_LOAD_PATH="$GUILE_LOAD_PATH:$(pwd)/build/opencog/scm"
    ${import ../helpers/common-patch.nix {inherit GUILE_SITE_DIR;}}
  '';

  postFixup = ''
    for file in $(find $out/lib -type f -executable); do
      rpath=$(patchelf --print-rpath $file)
      patchelf --set-rpath "$rpath:$out/lib/opencog:$out/${PYTHON_DEST}/opencog" $file
    done
  '';

  enableParallelChecking = false; # for database tests conflicts
  doCheck = true;

  meta = with stdenv.lib; {
    description = "The OpenCog hypergraph database, query system and rule engine";
    homepage = https://wiki.opencog.org/w/AtomSpace;
    license = licenses.agpl3;
#    maintainers = with maintainers; [ radivarig ];
    platforms = with platforms; unix;
  };
}
