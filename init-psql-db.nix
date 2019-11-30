{pkgs, ...}: ''
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

TOTAL_RAM=$(${pkgs.procps}/bin/free -m | grep Mem | awk '{print $2}')
TOTAL_CORES=$NIX_BUILD_CORES

cat <<EOF > "$PGDATA/postgresql.conf"
  shared_buffers = $((TOTAL_RAM * 1/4))MB     # Change to 25% of installed RAM
  work_mem = 32MB             # Default was 1MB, change to 32MB
  effective_cache_size = $((TOTAL_RAM * 1/2))MB  # Change to 50%-75% of installed RAM
  synchronous_commit = off    # Default was on, change to off
  max_connections = 130       # Each AtomSpace instance needs 32
  max_worker_processes = $TOTAL_CORES    # One per CPU core
  ssl = off                   # There's no point to encyrption locally

  checkpoint_timeout = 1h
  max_wal_size = 8GB
  checkpoint_completion_target = 0.9

  seq_page_cost = 0.1
  random_page_cost = 0.1
  effective_io_concurrency = 100
EOF

pg_ctl start -w -l $LOG_PATH -o "-c listen_addresses= -c unix_socket_directories=$PGHOST"
''
