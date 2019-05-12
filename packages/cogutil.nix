{ pkgs ? import <nixpkgs> {}}: with pkgs;
with import <nixpkgs/nixos> {}; # for /etc/os-release
stdenv.mkDerivation rec {
  name = "cogutil";

  src = fetchFromGitHub {
    owner = "opencog";
    repo = "cogutil";
    rev = "b4da0dfd1beef2c292c34725066633727458cbfd";
    sha256 = "0knwkxps9mfzaqsblv00v8p8n1j95snkiv1b6nk4jl7r9vl3b4q6";
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
