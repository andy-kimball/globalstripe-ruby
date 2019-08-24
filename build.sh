#!/bin/bash -x
set -e

rm -rf lib && rm -rf vendor && mkdir lib && mkdir vendor

docker build -t pg_mysql_layer -f Dockerfile .

CONTAINER=$(docker run -d pg_mysql_layer false)

docker cp \
    $CONTAINER:/var/task/vendor/ \
    ./

docker cp \
    $CONTAINER:/usr/lib64/libpq.so.5.5 \
    lib/libpq.so.5

docker cp \
    $CONTAINER:/usr/lib64/mysql/. \
    lib/

docker rm $CONTAINER