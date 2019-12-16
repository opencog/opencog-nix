{GUILE_SITE_DIR}:
''
  mkdir .cache
  export XDG_CACHE_HOME=$(pwd)/.cache

  sed -i -e 's/nosetests3/nosetests/g' $(find . -type f)
  sed -i -e 's/OUTPUT_VARIABLE PYTHON_DEST//g' $(find . -type f)
  sed -i -e 's=/usr/local/share/opencog/scm=$out/${GUILE_SITE_DIR}/opencog/scm=g' $(find . -type f)
  sed -i -e 's#GUILE_LOAD_PATH=''${GUILE_LOAD_PATH}##g' $(find . -type f -iname "CMakeLists.txt")
  sed -i -e 's#SET(GUILE_LOAD_PATH "#SET(GUILE_LOAD_PATH "'$GUILE_LOAD_PATH':#g' $(find . -type f -iname "CMakeLists.txt")
  sed -i -e 's#PYTHONPATH=#PYTHONPATH='$PYTHONPATH':#g' $(find . -type f -iname "CMakeLists.txt")
''


