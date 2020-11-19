{ pkgs ? import <nixpkgs> {} }: with pkgs;

stdenv.mkDerivation rec {
  name = "generate";

  src = fetchFromGitHub {
    owner = "opencog";
    repo = "generate";
    rev = "6cbbcc1eaa8c2bd58401a2a592b0f3b7474108a9";
    sha256 = "185anylvzdcylgndn94b3qgdy3ipl5b371dxs023fgmvy7qwa47j";
  };

  cogutil = (import ./cogutil.nix {});
  atomspace = (import ./atomspace.nix {});
  nativeBuildInputs = [
    cmake boost166
    cxxtest
  ];

  buildInputs = [
    libuuid
    cogutil
    atomspace

    guile gmp

    python36
    python36Packages.cython
    python36Packages.nose
  ];

  GUILE_INCLUDE_DIR = "${guile.dev}/include/guile/2.2";
  GMP_INCLUDE_DIR = "${gmp.dev}/include";

  GUILE_SITE_DIR="share/guile/site";
  PYTHON_DEST=python36.sitePackages;

  CXXTEST_BIN_DIR = "${cxxtest}/bin";
  CPLUS_INCLUDE_PATH = "${cxxtest.src}";

  cmakeFlags = [
    ''-DGUILE_INCLUDE_DIR:PATH=${GUILE_INCLUDE_DIR}''
    ''-DGMP_INCLUDE_DIR:PATH=${GMP_INCLUDE_DIR}''

    ''-DGUILE_SITE_DIR:PATH=${GUILE_SITE_DIR}''
    ''-DPYTHON_DEST:PATH=${PYTHON_DEST}''

    ''-DCXXTEST_BIN_DIR:PATH=${CXXTEST_BIN_DIR}''
    ''-DCPLUS_INCLUDE_PATH:PATH=${CPLUS_INCLUDE_PATH}''
  ];

  # fix for https://github.com/NixOS/nixpkgs/issues/38991
  LOCALE_ARCHIVE_2_27 = "${pkgs.glibcLocales}/lib/locale/locale-archive";

  patchPhase = ''
    # needs LOCALE_ARCHIVE_2_27 above TODO: move to common patch
    # needed for python3 str(runtimeError) unicode decoding
    export LC_ALL=en_US.UTF-8

    export GUILE_LOAD_PATH="$GUILE_LOAD_PATH:$(pwd)/build/opencog/scm"
    ${import ../helpers/common-patch.nix {inherit GUILE_SITE_DIR;}}
  '';

  postFixup = ''
    for file in $(find $out/lib -type f -executable); do
      rpath=$(patchelf --print-rpath $file)
      patchelf --set-rpath "$rpath:$out/lib/opencog:$out/${PYTHON_DEST}/opencog" $file
    done
  '';

  setupHook = ../helpers/common-setup-hook.sh;

  doCheck = true;

  meta = with stdenv.lib; {
    description = "Network generation";
    homepage = https://wiki.opencog.org/w/Generate;
    license = licenses.agpl3;
#    maintainers = with maintainers; [ radivarig ];
    platforms = with platforms; unix;
  };
}
