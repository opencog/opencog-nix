{ pkgs ? import <nixpkgs> {} }: with pkgs;

stdenv.mkDerivation rec {
  name = "link-grammar";

  src = fetchFromGitHub {
    owner = "opencog";
    repo = "link-grammar";
    rev = "11dd734bb32c3f71e71b3fbb6c2e22f5a14135a7";
    sha256 = "1ivl7mrwbp1arlvd6an9c2p2cs7afkal5d826w3k9jkv2lmavm7a";
  };

  nativeBuildInputs = [
    automake
    autoconf
    autoconf-archive
    libtool
    pkgconfig
    m4
    swig
    flex
    graphviz
  ];

  buildInputs = [
    perl
    python36

    ncurses # needed for python bindings..
    sqlite
    minisatUnstable
    zlib
    tre
    libedit
    file

    hunspell
    hunspellDicts.en-us
  ];

  # fix for https://github.com/NixOS/nixpkgs/issues/38991
  LOCALE_ARCHIVE_2_27 = "${pkgs.glibcLocales}/lib/locale/locale-archive";

  patchPhase = ''
    ./autogen.sh --no-configure

    sed -i -e 's#/usr/bin/file#${file}/bin/file#g' $(find . -type f)

    sed -i -e 's#/usr/include/minisat#${minisatUnstable}/include/minisat#g' $(find . -type f)
    sed -i -e 's#/usr/share/myspell/dicts#${hunspellDicts.en-us}/share/myspell/dicts#g' $(find . -type f)
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
