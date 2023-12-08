#!/bin/bash
set -ex

CURRENT=$(cd $(dirname $0);pwd)

bundle exec ridgepole \
  -c ${CURRENT}/../spec/dummy/config/database.yml \
  --apply \
  -f ${CURRENT}/../spec/dummy/db/Schemafile \
  -E test