{ pkgs ? import <nixpkgs> {} }: with pkgs;

stdenv.mkDerivation rec {
  name = "ure";

  src = fetchFromGitHub {
    owner = "opencog";
    repo = "ure";
    rev = "86c4ccaae39cf36d70af6dd13e5ee89fe58986aa";
    sha256 = "09f9rsdgf4rd67awkspxw82b15mqs1mpskdxbs39fc88hipwv6jq";
  };

  cogutil = (import ./cogutil.nix {});
  atomspace = (import ./atomspace.nix {});

  nativeBuildInputs = [
    cmake
    boost166
    cxxtest
  ];

  buildInputs = [
    cogutil
    atomspace

    guile gmp

    python36
    python36Packages.cython
    python36Packages.nose

    doxygen
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
    export GUILE_LOAD_PATH="$GUILE_LOAD_PATH:$(pwd)/build/opencog/scm"
    ${import ../helpers/common-patch.nix {inherit GUILE_SITE_DIR;}}
  '';


  postFixup = ''
    addToRPath="$addToRPath:$out/lib/opencog"
    addToRPath="$addToRPath:$out/${PYTHON_DEST}/opencog"

    for file in $(find $out/lib -type f -executable); do
      rpath=$(patchelf --print-rpath $file)
      patchelf --set-rpath "$rpath:$addToRPath" $file
    done

    rm -rf $out/share/opencog/cmake
    rm -f $out/${PYTHON_DEST}/opencog/__init__.py
  '';

  checkPhase = ''
    make test ARGS="-V"
  '';

  setupHook = ../helpers/common-setup-hook.sh;

  doCheck = true;

  meta = with stdenv.lib; {
    description = "Unified Rule Engine. Graph rewriting system for the AtomSpace. Used as reasoning engine for OpenCog.";
    homepage = https://wiki.opencog.org/w/Development;
    license = licenses.agpl3;
#    maintainers = with maintainers; [ radivarig ];
    platforms = with platforms; unix;
  };
}
