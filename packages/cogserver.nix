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
    boost162
    cxxtest

    netcat
  ];

  buildInputs = [
    cogutil
    atomspace

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
    sed -i -e 's/OUTPUT_VARIABLE PYTHON_DEST//g' $(find . -type f)

    # replace shared paths
    sed -i -e "s=/usr/local/share/opencog/scm=$out/${GUILE_SITE_DIR}/opencog/scm=g" $(find . -type f)

    # TODO: is this correct? There is a message in `tests/CMakeLists.txt`:
    # "All tests should load the atomspace scm from the build dir"
    # Otherwise throws: Unable to find file "opencog/atoms/atom_types/core_types.scm" in load path
    # prevent override of GUILE_LOAD_PATH
    sed -i -e 's#SET(GUILE_LOAD_PATH "''${PROJECT_BINARY_DIR}/opencog/scm")##g' $(find . -type f -iname "CMakeLists.txt")

    # TODO: if this is not added PyEvalUTest doesn't throw even though it shows: Failed to load the opencog.atomspace module
    export PYTHONPATH="$PYTHONPATH:${atomspace}/share/python3.6/site-packages/";

    # TODO: how are atomspace python files obtained on non-nix?
    # Exported PYTHONPATH is overriden, force prepend site-packages
    sed -i -e 's#PYTHONPATH=#PYTHONPATH=${atomspace}/share/python3.6/site-packages:#g' $(find . -type f -iname "CMakeLists.txt")
  '';

  enableParallelChecking = false;
  doCheck = true;

  meta = with stdenv.lib; {
    description = "OpenCog Newtwork Server";
    homepage = https://wiki.opencog.org/w/Development;
    license = licenses.agpl3;
#    maintainers = with maintainers; [ radivarig ];
    platforms = with platforms; unix;
  };
}
