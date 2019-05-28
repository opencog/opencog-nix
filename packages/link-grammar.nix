{ pkgs ? import <nixpkgs> {} }: with pkgs;

stdenv.mkDerivation rec {
  name = "link-grammar";

  src = fetchFromGitHub {
    owner = "opencog";
    repo = "link-grammar";
    rev = "90674998aecd53dbf17aca5f618581c7c29e07ca";
    sha256 = "0p9ibzw368pqjj8d37xqw7ifwsifzq3nqfg9l8p50vn4mfws4fwq";
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

    python3

    ncurses # needed for python bindings..
    sqlite
  ];

  # fix for https://github.com/NixOS/nixpkgs/issues/38991
  LOCALE_ARCHIVE_2_27 = "${pkgs.glibcLocales}/lib/locale/locale-archive";

  patchPhase = ''
    ./autogen.sh --no-configure
  '';

  doCheck = true;

  meta = with stdenv.lib; {
    description = "The CMU Link Grammar natural language parser";
    homepage = https://www.abisource.com/projects/link-grammar;
    license = licenses.lgpl21;
#    maintainers = with maintainers; [ radivarig ];
    platforms = with platforms; unix;
  };
}
