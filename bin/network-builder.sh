#!/bin/bash

source ../config/conf.ini

docker network inspect $CUSTOM_NET >/dev/null 2>&1 || \
docker network create $CUSTOM_NET --subnet $CUSTOM_SUBNET.0.0/16
