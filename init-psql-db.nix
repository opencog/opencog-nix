''
export PGDATA=$PWD/postgres_data
export PGHOST=$PWD/postgres
export LOG_PATH=$PWD/postgres/LOG
export PGDATABASE=postgres
export DATABASE_URL="postgresql:///postgres?host=$PGHOST"
if [ ! -d $PGHOST ]; then
  mkdir -p $PGHOST
fi
if [ ! -d $PGDATA ]; then
  echo 'Initializing postgresql database...'
  initdb $PGDATA --auth=trust >/dev/null
fi
pg_ctl start -l $LOG_PATH -o "-c listen_addresses= -c unix_socket_directories=$PGHOST"

sleep 0.1 # for template1 missing error
''
