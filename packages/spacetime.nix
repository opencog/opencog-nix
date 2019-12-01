{ pkgs ? import <nixpkgs> {}}: with pkgs;
stdenv.mkDerivation rec {
  name = "spacetime";

  src = fetchFromGitHub {
    owner = "opencog";
    repo = "spacetime";
    rev = "12785d9131fca650b6d4071f42230674d602bbbc";
    sha256 = "149a1c92aplhpk4p74jz1wqjdq0gqrrn75qm2d0zx7w7fxz3aa9f";
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

  CPATH = "${cxxtest.src}:${atomspace.src}";
  CXXTEST_BIN_DIR = "${cxxtest}/bin";

  GUILE_INCLUDE_DIR = "${guile.dev}/include/guile/2.2";
  GMP_INCLUDE_DIR = "${gmp.dev}/include";

  GUILE_SITE_DIR="share/guile/site";

  cmakeFlags = [
    ''-DCPATH:PATH=${CPATH}''
    ''-DCXXTEST_BIN_DIR:PATH=${CXXTEST_BIN_DIR}''

    ''-DGUILE_INCLUDE_DIR:PATH=${GUILE_INCLUDE_DIR}''
    ''-DGMP_INCLUDE_DIR:PATH=${GMP_INCLUDE_DIR}''

    ''-DGUILE_SITE_DIR:PATH=${GUILE_SITE_DIR}''
  ];

  patchPhase = ''
    mkdir -p $out/share/opencog
    cp -r ${atomspace.src}/cmake $out/share/opencog/
  '';

  doCheck = true;

  meta = with stdenv.lib; {
    description = "Quickly Locate Atoms in Space & Time.";
    homepage = https://wiki.opencog.org/w/SpaceServer;
    license = licenses.agpl3;
#    maintainers = with maintainers; [ radivarig ];
    platforms = with platforms; unix;
  };
}
