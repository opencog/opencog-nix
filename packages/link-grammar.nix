{ pkgs }: with pkgs;

stdenv.mkDerivation rec {
  name = "link-grammar";

  src = fetchFromGitHub {
    owner = "opencog";
    repo = "link-grammar";
    rev = "f8139e7278bda28946fc22d41ffca2bef50bc89a";
    sha256 = "0kjsrd1gxw6iibqam5q22nlpvhiza5lnsyyhx2w0vgnzg611jz99";
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

  # doCheck = true;
  # checkTarget = "test";

  meta = with stdenv.lib; {
    description = "The CMU Link Grammar natural language parser";
    homepage = https://www.abisource.com/projects/link-grammar;
    license = licenses.lgpl21;
#    maintainers = with maintainers; [ radivarig ];
    platforms = with platforms; unix;
  };
}
