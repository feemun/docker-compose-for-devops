#!/bin/bash

docker run -d \
	--name postgres \
	-p 5432:5432 \
	-e POSTGRES_PASSWORD=postgres \
	-e PGDATA=/var/lib/postgresql/data/pgdata \
	-v ~/docker/docker-data/postgres/custom/mount:/var/lib/postgresql/data \
	postgres:latest
