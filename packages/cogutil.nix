{ pkgs ? import <nixpkgs> {}}: with pkgs;
with import <nixpkgs/nixos> {}; # for /etc/os-release
stdenv.mkDerivation rec {
  name = "cogutil";

  src = fetchFromGitHub {
    owner = "opencog";
    repo = "cogutil";
    rev = "f3f2c69525b87c7302999a6f182bf491a2aaf0d3";
    sha256 = "098aj5skrbwsb0h7gqx6avhjgdpkq8m3rrlr9pnkdhakpr2hp213";
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
