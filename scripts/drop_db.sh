#!/bin/bash
set -ex

CURRENT=$(cd $(dirname $0);pwd)

mysql \
  -u ${DB_USERNAME} \
  -h ${DB_HOST} \
  -p${DB_PASSWORD} \
  --port ${DB_PORT} \
  -e "DROP DATABASE IF EXISTS ${DB_NAME}"
