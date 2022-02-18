#!/bin/bash
set -ex

CURRENT=$(cd $(dirname $0);pwd)

mysql \
  -u ${DB_USERNAME} \
  -h ${DB_HOST} \
  -p${DB_PASSWORD} \
  --port ${DB_PORT} \
  -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME}"

bundle exec ridgepole \
  -c ${CURRENT}/../spec/dummy-common/config/database.yml \
  --apply \
  -f ${CURRENT}/../spec/dummy-common/db/Schemafile \
  -E test
