{ pkgs ? import <nixpkgs> {}}: with pkgs;

stdenv.mkDerivation rec {
  name = "cogutil";

  src = fetchFromGitHub {
    owner = "opencog";
    repo = "cogutil";
    rev = "d1f3df098824e14ed8e1a74933e7aeab2ea022fb";
    sha256 = "0xfdfxqwkzaim2g8nib46kpxzvslqmjn03q4awgg4kriv3vwqr28";
  };

  nativeBuildInputs = [
    cmake
    boost166
    cxxtest

    binutils
    libiberty
    doxygen
  ];

  CXXTEST_BIN_DIR = "${cxxtest}/bin";
  CPLUS_INCLUDE_PATH = "${cxxtest.src}";

  cmakeFlags = [
    ''-DCXXTEST_BIN_DIR:PATH=${CXXTEST_BIN_DIR}''
    ''-DCPLUS_INCLUDE_PATH:PATH=${CPLUS_INCLUDE_PATH}''
  ];

  patchPhase = ''
    # prevent override of PYTHON_DEST
    sed -i -e 's/OUTPUT_VARIABLE PYTHON_DEST//g' $(find . -type f)

    sed -i -e 's/nosetests3/nosetests/g' $(find . -type f)
  '';

  setupHook = ../helpers/common-setup-hook.sh;

  doCheck = true;

  meta = with stdenv.lib; {
    description = "Very low-level C++ programming utilities used by several components";
    homepage = http://opencog.org;
    license = licenses.agpl3;
#    maintainers = with maintainers; [ radivarig ];
    platforms = with platforms; unix;
  };
}
