{ pkgs ? import <nixpkgs> {} }: with pkgs;

stdenv.mkDerivation rec {
  name = "link-grammar";

  src = fetchFromGitHub {
    owner = "opencog";
    repo = "link-grammar";
    rev = "2c3a78404b5fe6423dda14d25ab5063d37b941ac";
    sha256 = "0qgqmyjplpg1mm0knwi3izf4270xclj3lfy2h7g6m1lfjmfc36wi";
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
