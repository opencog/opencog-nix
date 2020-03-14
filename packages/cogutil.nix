{ pkgs ? import <nixpkgs> {}}: with pkgs;
with import <nixpkgs/nixos> {}; # for /etc/os-release
stdenv.mkDerivation rec {
  name = "cogutil";

  src = fetchFromGitHub {
    owner = "opencog";
    repo = "cogutil";
    rev = "99ad9df8638a43c4f4796982df8a044379a14213";
    sha256 = "1v5yr60r26457fh6n3pbawvv1l03dg1n1dskhzp2sfah3nr576dd";
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
