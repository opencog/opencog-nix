{ pkgs ? import <nixpkgs> {} }: with pkgs;

stdenv.mkDerivation rec {
  name = "opencog";

  src = fetchFromGitHub {
    owner = "opencog";
    repo = "opencog";
    rev = "c5d1a997c346151626abfe06e057f3235018b170";
    sha256 = "1ldjqch0m1i50jk7nn87y15wgpycp7dsgcinqd6gqpdnbz3sq9qm";
  };

  cogutil = (import ./cogutil.nix {});
  atomspace = (import ./atomspace.nix {});
  cogserver = (import ./cogserver.nix {});
  attention = (import ./attention.nix {});
  link-grammar = (import ./link-grammar.nix {});
  moses = (import ./moses.nix {});
  ure = (import ./ure.nix {});
  spacetime = (import ./spacetime.nix {});

  octomap = (import ./other/octomap.nix {});
  # cpprest = (import ./other/cpprest.nix {});

  netcat = (import ./other/netcat-openbsd.nix {});

  nativeBuildInputs = [
    cmake
    boost166
    cxxtest

    netcat
  ];

  buildInputs = [
    guile gmp

    cogutil
    atomspace
    cogserver
    attention
    link-grammar
    moses
    ure
    spacetime

    libuuid
    octomap

    python36
    python36Packages.cython
    python36Packages.nose
    pkgconfig
    pcre
    valgrind
    stack
    doxygen

    # deprecated or soon to be:
    # cpprest # will be removed with the new pattern miner
    # openssl # required by cpprest

    # zeromq
    # jsoncpp
    # protobuf
    # blas
    # liblapack
    # gtk3
  ];

  # ZMQ_LIBRARY="${zeromq}/lib/libzmq.so";

  GUILE_INCLUDE_DIR = "${guile.dev}/include/guile/2.2";
  GMP_INCLUDE_DIR = "${gmp.dev}/include";

  # fixes for writting into other packages output paths
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

  LOCALE_ARCHIVE_2_27 = "${pkgs.glibcLocales}/lib/locale/locale-archive";

  patchPhase = ''
    mkdir -p $out/share/opencog
    cp -r ${atomspace.src}/cmake $out/share/opencog/

    cp ${cogserver.src}/lib/*.conf $(pwd)/lib

    export GUILE_LOAD_PATH="$GUILE_LOAD_PATH:$(pwd)/build/opencog/scm"
    ${import ../helpers/common-patch.nix {inherit GUILE_SITE_DIR;}}
  '';

  postFixup = ''
    for file in $(find $out/lib -type f -executable); do
      rpath=$(patchelf --print-rpath $file)
      patchelf --set-rpath "$rpath:$out/lib/opencog:$out/${PYTHON_DEST}/opencog" $file
    done

    rm -rf $out/share/opencog/cmake
    rm -f $out/${PYTHON_DEST}/opencog/__init__.py
  '';

  checkPhase = ''
    make test ARGS="-V"
  '';

  doCheck = true;

  meta = with stdenv.lib; {
    description = "A framework for integrated Artificial Intelligence & Artificial General Intelligence (AGI)";
    homepage = https://wiki.opencog.org/w/Development;
    license = licenses.agpl3;
#    maintainers = with maintainers; [ radivarig ];
    platforms = with platforms; unix;
  };
}
