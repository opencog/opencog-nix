{ pkgs ? import <nixpkgs> {} }: with pkgs;

stdenv.mkDerivation rec {
  name = "link-grammar";

  src = fetchFromGitHub {
    owner = "opencog";
    repo = "link-grammar";
    rev = "ced78cc2f7e8ae7ff42e57cf2c0f9ed0afd37a4a";
    sha256 = "1kakw87n6j2s4299kax0s5w8c8v5wky0ahd42hhq1rvs8hwca528";
  };

  nativeBuildInputs = [
    automake
    perl
    autoconf
    autoconf-archive
    libtool
    pkgconfig
    m4
    swig
    flex
    graphviz
    zlib
  ];

  configurePhase =''
    ./autogen.sh
    ./configure --prefix=$out
  '';

  installPhase = ''
    mkdir -p $out
    make install
  '';

#  checkPhase = ''
#    export LANG=C #?
#  '';

#   doCheck = true;

  meta = with stdenv.lib; {
    description = "The CMU Link Grammar natural language parser";
    homepage = https://www.abisource.com/projects/link-grammar;
    license = licenses.lgpl21;
#    maintainers = with maintainers; [ radivarig ];
    platforms = with platforms; unix;
  };
}
