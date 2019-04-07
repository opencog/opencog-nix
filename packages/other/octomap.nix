{ pkgs ? import <nixpkgs> {} }: with pkgs;

stdenv.mkDerivation rec {
  name = "octomap";

  src = fetchFromGitHub {
    owner = "OctoMap";
    repo = "octomap";
    rev = "23cb13f757e83e407ddb84d104fa55c057fb2c5e";
    sha256 = "0mwhawaf6j9vmgi8zn8idzsw7fsp626dsa908fgv5ja4bawg8p2l";
  };

  nativeBuildInputs = [ cmake ];

  # doCheck = true;
  # checkTarget = "test";

  meta = with stdenv.lib; {
    description = "An Efficient Probabilistic 3D Mapping Framework Based on Octrees. Contains the main OctoMap library, the viewer octovis, and dynamicEDT3D";
    homepage = http://octomap.github.io;
    license = licenses.bsd3;
#    maintainers = with maintainers; [ radivarig ];
    platforms = with platforms; unix;
  };
}
