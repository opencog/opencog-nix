{ pkgs ? import <nixpkgs> {}}: with pkgs;
with import <nixpkgs/nixos> {}; # for /etc/os-release
stdenv.mkDerivation rec {
  name = "cogutil";

  src = fetchFromGitHub {
    owner = "opencog";
    repo = "cogutil";
    rev = "4520349899dc7247b6a74c123244c6cd8685a036";
    sha256 = "0clpj8dnn7vxm3dv7823pm093zfz5qbgwyl92c2zhgrqbai08dxs";
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

  osReleasePath = config.environment.etc.os-release.source;
  patchPhase = ''
    # prevent override of PYTHON_DEST
    sed -i -e 's/OUTPUT_VARIABLE PYTHON_DEST//g' $(find . -type f)

    sed -i -e 's/nosetests3/nosetests/g' $(find . -type f)

    sed -i -e 's=/etc/os-release=${osReleasePath}=g' $(find . -type f)
  '';


  doCheck = true;

  meta = with stdenv.lib; {
    description = "Very low-level C++ programming utilities used by several components";
    homepage = http://opencog.org;
    license = licenses.agpl3;
#    maintainers = with maintainers; [ radivarig ];
    platforms = with platforms; unix;
  };
}
