#!/bin/bash

source ../config/conf.ini

image_target=$USER_DOCKER/apache-airflow

docker rmi $image_target
docker build -t $image_target -f ./Dockerfile ./
