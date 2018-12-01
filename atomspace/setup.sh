unset PATH
for p in $baseInputs $buildInputs; do
  export PATH=$p/bin${PATH:+:}$PATH
done

function unpackPhase() {
  # tar -xzf $src
  cp -r $src .
  chmod -R 777 .

  for d in *; do
    if [ -d "$d" ]; then
      cd "$d"
      break
    fi
  done
}

function configurePhase() {
  mkdir -p build
  cd build
}

function buildPhase() {
  sed -i '1i INCLUDE_DIRECTORIES(${GMP_INCLUDE_DIR})' ../opencog/**/CMakeLists.txt

  cmake \
    -DCMAKE_PREFIX_PATH:PATH="$GMP_LIBRARY;$GMP_INCLUDE_DIR;$GUILE_LIBRARY;$GUILE_INCLUDE_DIR" \
    -DCMAKE_INSTALL_PREFIX:PATH=$out ..

  make
}

function installPhase() {
  make install
  cd ..
  mkdir -p $build
  mv build $build/
}

function fixupPhase() {
  find $out -type f -exec patchelf --shrink-rpath '{}' \; -exec strip '{}' \; 2>/dev/null
}

function genericBuild() {
  unpackPhase
  configurePhase
  buildPhase
  installPhase
  fixupPhase
}
