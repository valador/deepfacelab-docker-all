THIS_FILE := $(lastword $(MAKEFILE_LIST))
# ENVFILE := .env
SHELL := /bin/bash

DATETIME := $(shell date +%s)

.PHONY: help
help:
	make -pRrq -f $(THIS_FILE) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'
## build all
.PHONY: build-anaconda-nvidia build-ffmpeg-nvidia build-deepfacelab-nvidia
build-anaconda-nvidia:
	docker build -t slayerus/anaconda3:nvidia-1.0 --no-cache -f ./anaconda3/Dockerfile.nvidia ./anaconda3/.
#	docker push slayerus/anaconda3:nvidia-1.0
build-ffmpeg-nvidia:
	docker build -t slayerus/ffmpeg:nvidia-1.0 --no-cache -f ./ffmpeg/Dockerfile ./ffmpeg/.
#	docker push slayerus/ffmpeg:nvidia-1.0
build-deepfacelab-nvidia:
	docker build -t slayerus/deepfacelab:nvidia-1.0 -f ./deepfacelab/Dockerfile.nvidia ./deepfacelab/.
#	docker build -t slayerus/deepfacelab:nvidia-1.0 --build-arg CACHEBUST=${DATETIME} -f ./deepfacelab/Dockerfile.nvidia ./deepfacelab/.
#	docker push slayerus/deepfacelab:nvidia-1.0
# .PHONY: run-deepfacelab
# run-deepfacelab:
# 	docker run --gpus all --rm -it -v workspace:/usr/local/deepface/workspace slayerus/deepfacelab:nvidia-1.0 /bin/bash
## stop and remove containers & volumes (--remove-orphans Remove containers for services not defined in the Compose file)
.PHONY: clean
clean:
	docker-compose -f docker-compose.yml down --volumes --rmi all --remove-orphans
	docker-compose -f docker-compose.yml rm -v --force
## removes everything created by docker-compose and prunes everything in docker
## (!!) this includes all your work with docker, not just stuff (--remove-orphans Remove containers for services not defined in the Compose file)
.PHONY: purge-deepfacelab-nvidia
purge-deepfacelab-nvidia:
	docker-compose -f docker-compose.yml down --volumes --rmi all --remove-orphans
	docker-compose -f docker-compose.yml rm -v --force
	yes | docker system prune --all --volumes --force


.PHONY: run-deepfacelab-nvidia
run-deepfacelab-nvidia:
	docker-compose run deepfacelab

.PHONY: destroy
destroy:
	docker-compose -f docker-compose.yml -f docker-compose.yml down -v $(c)

.PHONY: ps
ps:
	docker ps --format \
	"table {{.ID}}\t{{.Status}}\t{{.Names}}"
# #Logs
# .PHONY: logs-dev logs-dev-slave logs-prod logs-prod-slave logs-ws logs-db-master logs-db-slave
# logs-dev:
# 	docker-compose -f docker-compose.yml logs --tail=100 -f $(c)
