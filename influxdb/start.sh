#!/bin/bash

docker run \
    -p 8086:8086 \
    -v ~/docker_date/influxdb/data:/var/lib/influxdb2 \
    -v ~/docker_date/influxdb/config:/etc/influxdb2 \
    influxdb:latest
