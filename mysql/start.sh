#!/bin/bash

mkdir -p ~/docker/docker-data/mysql
chown -R catfish:catfish ~/docker/docker-data/mysql

docker run -d\
    --name mysql \
    -p 3306:3306 \
    -e MYSQL_ROOT_PASSWORD=my-secret-pw \
    -v ~/docker/docker-data/mysql:/var/lib/mysql \
    mysql:latest

