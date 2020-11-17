{ pkgs ? import <nixpkgs> {} }: with pkgs;

stdenv.mkDerivation rec {
  name = "attention";

  src = fetchFromGitHub {
    owner = "opencog";
    repo = "attention";
    rev = "e89c96639dc5fd88818dfc38870c64138b4042bb";
    sha256 = "1zi5pds4pj9sblcv7wpbb7m6pz7ahdsi4kb2bvfpgy6wck345cl0";
  };

  cogutil = (import ./cogutil.nix {});
  atomspace = (import ./atomspace.nix {});
  cogserver = (import ./cogserver.nix {});

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
    cogserver

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

  patchPhase = ''
    mkdir -p $out/share/opencog
    cp -r ${atomspace.src}/cmake $out/share/opencog

    # TODO: why is this needed to be copied?
    # 8 - ImportanceDiffusionUTest (SEGFAULT)
    # 9 - HebbianCreationModuleUTest (SEGFAULT)
    cp -r ${cogserver}/lib/opencog/modules/* opencog
    mkdir -p build/opencog/agents
    cp ${cogserver}/lib/opencog/modules/libagents.so build/opencog/agents

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

  setupHook = ../helpers/common-setup-hook.sh;

  checkPhase = ''
    make test ARGS="-V"
  '';

  doCheck = true;

  meta = with stdenv.lib; {
    description = "OpenCog Attention Allocation Subsystem";
    homepage = https://wiki.opencog.org/w/Development;
    license = licenses.agpl3;
#    maintainers = with maintainers; [ radivarig ];
    platforms = with platforms; unix;
  };
}
