{ pkgs ? import <nixpkgs> {} }: with pkgs;

stdenv.mkDerivation rec {
  name = "link-grammar";

  src = fetchFromGitHub {
    owner = "opencog";
    repo = "link-grammar";
    rev = "9bcbeb25432f815a6c05503a3070aa70d5f4c269";
    sha256 = "17azaxcimsdc8v2zh1xjh8xilhz5jlajn4mhylv2l3z9x4gr7h5k";
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
    minisat
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

    sed -i -e 's#/usr/include/minisat#${minisat}/include/minisat#g' $(find . -type f)
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
