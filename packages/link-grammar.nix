{ pkgs ? import <nixpkgs> {} }: with pkgs;

stdenv.mkDerivation rec {
  name = "link-grammar";

  src = fetchFromGitHub {
    owner = "opencog";
    repo = "link-grammar";
    rev = "972ea245bde7365ee6942610154da88a46d12c1f";
    sha256 = "1vqa5aqwn9mf5c38k12sxbjmh40wfc6ghrajcyc279kdqmaryn5k";
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

  setupHook = ../helpers/common-setup-hook.sh;

  doCheck = true;

  meta = with stdenv.lib; {
    description = "The CMU Link Grammar natural language parser";
    homepage = https://www.abisource.com/projects/link-grammar;
    license = licenses.lgpl21;
#    maintainers = with maintainers; [ radivarig ];
    platforms = with platforms; unix;
  };
}
