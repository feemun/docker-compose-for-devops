docker run -d \
	--name nextcloud \
	-p 8080:80 \
	-v ~/docker/docker-data/nextcloud/nextcloud:/var/www/html \
	-v ~/docker/docker-data/nextcloud/apps:/var/www/html/custom_apps \
	-v ~/docker/docker-data/nextcloud/config:/var/www/html/config \
	-v ~/docker/docker-data/nextcloud/data:/var/www/html/data \
	nextcloud:latest

