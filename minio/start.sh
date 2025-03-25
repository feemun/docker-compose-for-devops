#!/bin/bash

docker run -d \
	--name minio \
	-e "MINIO_ROOT_USER=admin" \
	-e "MINIO_ROOT_PASSWORD=admin123456" \
    	--publish 9000:9000 \
    	--publish 9001:9001 \
    	--volume ~/docker/docker-data/minio:/bitnami/minio/data \
    	bitnami/minio:latest

