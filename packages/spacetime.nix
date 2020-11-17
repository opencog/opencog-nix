{ pkgs ? import <nixpkgs> {}}: with pkgs;
stdenv.mkDerivation rec {
  name = "spacetime";

  src = fetchFromGitHub {
    owner = "opencog";
    repo = "spacetime";
    rev = "dba43aefd4aabb8a6b8c2212350fbdac285a37ec";
    sha256 = "0q2qyg2rkqgx4wynair8fjlxv1znax6wc1g47z7jmgqky4qarkgj";
  };

  cogutil = (import ./cogutil.nix {});
  atomspace = (import ./atomspace.nix {});

  octomap = (import ./other/octomap.nix {});

  nativeBuildInputs = [
    cmake
    boost166
    cxxtest
    guile gmp

    cogutil
    atomspace
    octomap
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
    cp -r ${atomspace.src}/cmake $out/share/opencog/

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
    description = "Quickly Locate Atoms in Space & Time.";
    homepage = https://wiki.opencog.org/w/SpaceServer;
    license = licenses.agpl3;
#    maintainers = with maintainers; [ radivarig ];
    platforms = with platforms; unix;
  };
}
