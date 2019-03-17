{ pkgs }: with pkgs;

stdenv.mkDerivation rec {
  name = "link-grammar";

  src = fetchFromGitHub {
    owner = "opencog";
    repo = "link-grammar";
    rev = "895fca1b94b5a2966599b1af9ce97121d6eebc1e";
    sha256 = "16i2g411fahbm750z659791mqzpsni7a99n65dprchy2nnxrr3jb";
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
