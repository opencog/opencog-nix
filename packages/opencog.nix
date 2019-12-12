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
  PYTHON_DEST="share/python3.6/site-packages";

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

    sed -i -e '/def test_create_rule/i \    @unittest.skip("")' $(find . -type f)

    sed -i -e 's/nosetests3/nosetests/g' $(find . -type f)

    mkdir -p $out/share/opencog
    cp -r ${atomspace.src}/cmake $out/share/opencog/

    mkdir .cache
    export XDG_CACHE_HOME=$(pwd)/.cache

    # for unit tests, why is GUILE_LOAD_PATH overrided?
    sed -i -e 's#SET(GUILE_LOAD_PATH "''${PROJECT_BINARY_DIR}/opencog/scm")##g' $(find . -type f -iname "CMakeLists.txt")
    sed -i -e 's#"GUILE_LOAD_PATH=''${GUILE_LOAD_PATH}"##g' $(find . -type f -iname "CMakeLists.txt")

    sed -i -e 's/OUTPUT_VARIABLE PYTHON_DEST//g' $(find . -type f)

    # replace shared paths
    sed -i -e 's=/usr/local/share/opencog/scm=$out/${GUILE_SITE_DIR}/opencog/scm=g' $(find . -type f)

    cp ${cogserver.src}/lib/*.conf $(pwd)/lib

    export GUILE_LOAD_PATH="$GUILE_LOAD_PATH:${ure}/share/guile/site"
    export GUILE_LOAD_PATH="$GUILE_LOAD_PATH:${ure}/share/guile/site/opencog"

    export GUILE_LOAD_PATH="$GUILE_LOAD_PATH:${atomspace}"
    export GUILE_LOAD_PATH="$GUILE_LOAD_PATH:${atomspace}/share/guile/site"
    export GUILE_LOAD_PATH="$GUILE_LOAD_PATH:${atomspace}/share/guile/site/opencog"

    export GUILE_LOAD_PATH="$GUILE_LOAD_PATH:${cogserver}/share/guile/site"
    export GUILE_LOAD_PATH="$GUILE_LOAD_PATH:${cogserver}/share/guile/site/opencog"

    export GUILE_LOAD_PATH="$GUILE_LOAD_PATH:${atomspace.src}/opencog"
    export GUILE_LOAD_PATH="$GUILE_LOAD_PATH:${atomspace.src}/opencog/scm"
    export GUILE_LOAD_PATH="$GUILE_LOAD_PATH:${atomspace.src}/opencog/scm/opencog"

    # yeah I know
    export GUILE_LOAD_PATH="$GUILE_LOAD_PATH:$(pwd)/build"
    export GUILE_LOAD_PATH="$GUILE_LOAD_PATH:$(pwd)/build/opencog"
    export GUILE_LOAD_PATH="$GUILE_LOAD_PATH:$(pwd)/build/opencog/nlp"
    export GUILE_LOAD_PATH="$GUILE_LOAD_PATH:$(pwd)/build/opencog/nlp/types"
    export GUILE_LOAD_PATH="$GUILE_LOAD_PATH:$(pwd)/build/opencog/scm"
    export GUILE_LOAD_PATH="$GUILE_LOAD_PATH:$(pwd)/build/opencog/scm/opencog"
    export GUILE_LOAD_PATH="$GUILE_LOAD_PATH:$(pwd)/build/opencog/scm/opencog/eva-behavior"
    export GUILE_LOAD_PATH="$GUILE_LOAD_PATH:$(pwd)/build/opencog/scm/opencog/eva-model"
    export GUILE_LOAD_PATH="$GUILE_LOAD_PATH:$(pwd)/build/opencog/scm/opencog/nlp"
    export GUILE_LOAD_PATH="$GUILE_LOAD_PATH:$(pwd)/build/opencog/scm/opencog/nlp/aiml"
    export GUILE_LOAD_PATH="$GUILE_LOAD_PATH:$(pwd)/build/opencog/scm/opencog/nlp/chatbot"
    export GUILE_LOAD_PATH="$GUILE_LOAD_PATH:$(pwd)/build/opencog/scm/opencog/nlp/chatbot-eva"
    export GUILE_LOAD_PATH="$GUILE_LOAD_PATH:$(pwd)/build/opencog/scm/opencog/nlp/chatbot-psi"
    export GUILE_LOAD_PATH="$GUILE_LOAD_PATH:$(pwd)/build/opencog/scm/opencog/nlp/microplanning"
    export GUILE_LOAD_PATH="$GUILE_LOAD_PATH:$(pwd)/build/opencog/scm/opencog/nlp/relex2logic"
    export GUILE_LOAD_PATH="$GUILE_LOAD_PATH:$(pwd)/build/opencog/scm/opencog/nlp/relex2logic/loader"
    export GUILE_LOAD_PATH="$GUILE_LOAD_PATH:$(pwd)/build/opencog/scm/opencog/nlp/relex2logic/rules"
    export GUILE_LOAD_PATH="$GUILE_LOAD_PATH:$(pwd)/build/opencog/scm/opencog/nlp/sureal"
    export GUILE_LOAD_PATH="$GUILE_LOAD_PATH:$(pwd)/build/opencog/scm/opencog/nlp/types"
    export GUILE_LOAD_PATH="$GUILE_LOAD_PATH:$(pwd)/build/opencog/scm/opencog/openpsi"
    export GUILE_LOAD_PATH="$GUILE_LOAD_PATH:$(pwd)/build/opencog/scm/opencog/openpsi/dynamics"

    export GUILE_LOAD_PATH="$GUILE_LOAD_PATH:${spacetime}/share/guile/site"
    export GUILE_LOAD_PATH="$GUILE_LOAD_PATH:${spacetime}/share/guile/site/opencog"
    export GUILE_LOAD_PATH="$GUILE_LOAD_PATH:${spacetime}/share/guile/site/opencog/spacetime"
    export GUILE_LOAD_PATH="$GUILE_LOAD_PATH:${spacetime}/share/guile/site/opencog/spacetime/octomap"

    export GUILE_LOAD_PATH="$GUILE_LOAD_PATH:${attention}/share/guile/site"
    export GUILE_LOAD_PATH="$GUILE_LOAD_PATH:${attention}/share/guile/site/opencog"
    export GUILE_LOAD_PATH="$GUILE_LOAD_PATH:${attention}/share/guile/site/opencog/attention"
    export GUILE_LOAD_PATH="$GUILE_LOAD_PATH:${attention}/share/guile/site/opencog/attentionbank"
    export GUILE_LOAD_PATH="$GUILE_LOAD_PATH:${attention}/share/guile/site/opencog/attentionbank/types"

    # extend LD_LIBRARY_PATH
    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${moses}/lib"
    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${moses}/share/python3.6./site-packages"
    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${moses}/share/python3.6./site-packages/opencog"

    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${spacetime}/lib"
    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${spacetime}/lib/opencog"

    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${cogutil}/lib/opencog"

    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${ure}/lib/opencog"
    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${ure}/share/python3.6/site-packages"
    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${ure}/share/python3.6/site-packages/opencog"

    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${atomspace}/lib/opencog"
    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${atomspace}/share/python3.6/site-packages"
    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${atomspace}/share/python3.6/site-packages/opencog"

    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${cogserver}/lib/opencog"
    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${cogserver}/lib/opencog/modules"
    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${cogserver}/share/python3.6/site-packages"
    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${cogserver}/share/python3.6/site-packages/opencog"

    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${spacetime}/lib"
    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${spacetime}/lib/opencog"

    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${attention}/lib/opencog"
    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${attention}/lib/opencog/modules"
    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${attention}/share/python3.6/site-packages"
    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${attention}/share/python3.6/site-packages/opencog"

    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${octomap}/lib"

    # extend PYTHONPATH
    export PYTHONPATH="$PYTHONPATH:$LD_LIBRARY_PATH"

    # exported PYTHONPATH is overriden, force prepend site-packages
    sed -i -e "s#PYTHONPATH=#PYTHONPATH=$PYTHONPATH:#g" $(find . -type f -iname "CMakeLists.txt")
  '';

  postBuild = ''
    mkdir early_lib
    cp $(find . -name "*.so") early_lib
    ls -R early_lib

    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$(pwd)/early_lib"
  '';

  # https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/setup-hooks/move-lib64.sh#L6
  # dontMoveLib64 = 1;

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
