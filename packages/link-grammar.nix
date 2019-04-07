{ pkgs ? import <nixpkgs> {} }: with pkgs;

stdenv.mkDerivation rec {
  name = "link-grammar";

  src = fetchFromGitHub {
    owner = "opencog";
    repo = "link-grammar";
    rev = "6bd44df09302fa601b0dbc1076a69ddf2ade395a";
    sha256 = "09w36a7p5bn5vh2wfm6kq5y1x161r2krcv5qa0dkr7s1l7p58klb";
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
