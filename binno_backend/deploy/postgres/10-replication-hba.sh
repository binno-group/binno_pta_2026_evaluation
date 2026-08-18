#!/bin/bash
set -euo pipefail
{
  echo
  echo "# Streaming replication from the compose network (deploy/postgres/10-replication-hba.sh)"
  echo "host replication all 172.16.0.0/12 scram-sha-256"
  echo "host replication all 10.0.0.0/8    scram-sha-256"
} >> "$PGDATA/pg_hba.conf"
