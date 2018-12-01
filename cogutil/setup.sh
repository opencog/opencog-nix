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
  mkdir build
  cd build
}

function buildPhase() {
  cmake -DCMAKE_INSTALL_PREFIX:PATH=$out ..
  make
}

function installPhase() {
  make install
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
