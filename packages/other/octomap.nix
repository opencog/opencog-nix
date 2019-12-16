{ pkgs ? import <nixpkgs> {} }: with pkgs;

stdenv.mkDerivation rec {
  name = "octomap";

  src = fetchFromGitHub {
    owner = "OctoMap";
    repo = "octomap";
    rev = "31af07e5bacc210cbf3c32929acf50338c108123";
    sha256 = "0n0mrfpwywzkppcf61lbvpmail4r2mkkx7dis5smrkkh3v0hqbgp";
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
