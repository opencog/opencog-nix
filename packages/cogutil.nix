{ pkgs }: with pkgs;
with import <nixpkgs/nixos> {};
stdenv.mkDerivation rec {
  name = "cogutil";

  src = fetchFromGitHub {
    owner = "opencog";
    repo = "cogutil";
    rev = "be725eed573d7b083c575d937606e0db8a3e1c64";
    sha256 = "1hlpnwx04wc2b9hprw67vxak9275ngiqyr80vfva8jf0fxvw8w70";
  };

  nativeBuildInputs = [
    cmake
    boost166
    cxxtest
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
