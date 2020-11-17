{ pkgs ? import <nixpkgs> {} }: with pkgs;

stdenv.mkDerivation rec {
  name = "cogserver";

  src = fetchFromGitHub {
    owner = "opencog";
    repo = "cogserver";
    rev = "5d241c92ad0e510e899426da78ac3b4ac7ef7764";
    sha256 = "0whnhkijfxirbyy2b69675cjkqrpjks2dbfak7w8bg7j4rjicx36";
  };

  cogutil = (import ./cogutil.nix {});
  atomspace = (import ./atomspace.nix {});

  netcat = (import ./other/netcat-openbsd.nix {});

  nativeBuildInputs = [
    cmake
    boost166
    cxxtest

    netcat
  ];

  buildInputs = [
    cogutil
    atomspace

    guile gmp
    python36
    python36Packages.cython
    python36Packages.nose
    pkgconfig
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

  patchPhase = ''
    # disable failing test until resolved https://github.com/opencog/opencog-nix/issues/46
    sed -i -e 's#ADD_CXXTEST(ShellUTest)##g' $(find . -type f -iname "CMakeLists.txt")

    ${import ../helpers/common-patch.nix {inherit GUILE_SITE_DIR;}}
  '';

  postFixup = ''
    addToRPath="$addToRPath:$out/lib/opencog"
    addToRPath="$addToRPath:$out/lib/opencog/modules"
    addToRPath="$addToRPath:$out/${PYTHON_DEST}/opencog"

    for file in $(find $out/lib -type f -executable); do
      rpath=$(patchelf --print-rpath $file)
      patchelf --set-rpath "$rpath:$addToRPath" $file
    done

    rm -rf $out/share/opencog/cmake
    rm -f $out/${PYTHON_DEST}/opencog/__init__.py
  '';

  setupHook = ../helpers/common-setup-hook.sh;

  checkPhase = ''
    make test ARGS="-V"
  '';

  enableParallelChecking = false;
  doCheck = true;

  meta = with stdenv.lib; {
    description = "OpenCog Newtwork Server";
    homepage = https://wiki.opencog.org/w/Development;
    license = licenses.agpl3;
#    maintainers = with maintainers; [ radivarig ];
    platforms = with platforms; unix;
  };
}
