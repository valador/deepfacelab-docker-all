THIS_FILE := $(lastword $(MAKEFILE_LIST))
# ENVFILE := .env
SHELL := /bin/bash

.PHONY: help
help:
	make -pRrq -f $(THIS_FILE) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'
## build all images using the docker-compose.yml file and BUILDKit
## uses cache
.PHONY: build-anaconda-nvidia build-ffmpeg-nvidia build-deepfacelab-nvidia
build-anaconda-nvidia:
#	BUILD_TAG=${ANACONDA_TAG} docker-compose -f docker-compose.yml build $(c)
	docker build -t slayerus/anaconda3:nvidia-1.0 -f ./anaconda3/Dockerfile.nvidia ./anaconda3/.
	docker push slayerus/anaconda3:nvidia-1.0
build-ffmpeg-nvidia:
	docker build -t slayerus/ffmpeg:nvidia-1.0 -f ./ffmpeg/Dockerfile ./ffmpeg/.
	docker push slayerus/ffmpeg:nvidia-1.0
build-deepfacelab-nvidia:
	docker build -t slayerus/deepfacelab:nvidia-1.0 -f ./deepfacelab/Dockerfile.nvidia ./deepfacelab/.
	docker push slayerus/deepfacelab:nvidia-1.0

## stop and remove containers & volumes (--remove-orphans Remove containers for services not defined in the Compose file)
.PHONY: clean
clean:
	docker-compose -f docker-compose.yml down --volumes --rmi all --remove-orphans
	docker-compose -f docker-compose.yml rm -v --force
## removes everything created by docker-compose and prunes everything in docker
## (!!) this includes all your work with docker, not just stuff (--remove-orphans Remove containers for services not defined in the Compose file)
.PHONY: purge-dev purge-prod
purge-dev:
	docker-compose -f docker-compose.yml -f docker-compose.dev.yml -f docker-compose.slave.dev.yml -f docker-compose.backup.yml down --volumes --rmi all --remove-orphans
	docker-compose -f docker-compose.yml -f docker-compose.dev.yml -f docker-compose.slave.dev.yml -f docker-compose.backup.yml rm -v --force
	yes | docker system prune --all --volumes --force
purge-prod:
	docker-compose -f docker-compose.yml -f docker-compose.prod.yml -f docker-compose.slave.prod.yml -f docker-compose.backup.yml down --volumes --rmi all --remove-orphans
	docker-compose -f docker-compose.yml -f docker-compose.prod.yml -f docker-compose.slave.prod.yml -f docker-compose.backup.yml rm -v --force
	yes | docker system prune --all --volumes --force
## Default build target if no dependencies
# .PHONY: build-%
# build-%:
# 	BUILD_TAG=$(BUILD_TAG) $*
#Operate
.PHONY: up-dev up-dev-slave up-prod up-prod-slave up-backup
up-dev:
	docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d $(c)
up-dev-slave:
	docker-compose -f docker-compose.slave.dev.yml up -d $(c)
up-prod:
	docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d $(c)
up-prod-slave:
	docker-compose -f docker-compose.slave.prod.yml up -d $(c)
up-backup:
	docker-compose -f docker-compose.backup.yml up -d $(c)

.PHONY: start-dev start-prod start-prod-slave start-backup
start-dev:
	docker-compose -f docker-compose.yml -f docker-compose.dev.yml start $(c)
start-dev-slave:
	docker-compose -f docker-compose.yml -f docker-compose.dev.yml -f docker-compose.slave.dev.yml start $(c)
start-prod:
	docker-compose -f docker-compose.yml -f docker-compose.prod.yml start $(c)
start-prod-slave:
	docker-compose -f docker-compose.yml docker-compose.prod.yml -f docker-compose.slave.prod.yml start $(c)
start-backup:
	docker-compose -f docker-compose.backup.yml start $(c)

.PHONY:
down-dev:
	docker-compose -f docker-compose.yml -f docker-compose.dev.yml down $(c)
down-dev-slave:
	docker-compose -f docker-compose.slave.dev.yml down $(c)
down-prod:
	docker-compose -f docker-compose.yml -f docker-compose.prod.yml down $(c)
down-prod-slave:
	docker-compose -f docker-compose.slave.prod.yml down $(c)
down-backup:
	docker-compose -f docker-compose.backup.yml down $(c)

.PHONY: destroy
destroy:
	docker-compose -f docker-compose.yml -f docker-compose.yml down -v $(c)

.PHONY: stop-dev stop-dev-slave stop-prod stop-prod-slave stop-backup stop-slave
stop-dev:
	docker-compose -f docker-compose.yml -f docker-compose.dev.yml stop $(c)
stop-dev-slave:
	docker-compose -f docker-compose.slave.dev.yml stop $(c)
stop-prod:
	docker-compose -f docker-compose.yml -f docker-compose.prod.yml stop $(c)
stop-prod-slave:
	docker-compose -f docker-compose.slave.prod.yml stop $(c)


.PHONY:
restart:
	docker-compose -f docker-compose.yml stop $(c)
	docker-compose -f docker-compose.yml up -d $(c)

.PHONY: ps
ps:
	docker ps --format \
	"table {{.ID}}\t{{.Status}}\t{{.Names}}"
#Logs
.PHONY: logs-dev logs-dev-slave logs-prod logs-prod-slave logs-ws logs-db-master logs-db-slave
logs-dev:
	docker-compose -f docker-compose.yml logs --tail=100 -f $(c)
logs-dev-slave:
	docker-compose -f docker-compose.slave.dev.yml logs --tail=100 -f $(c)
logs-prod:
	docker-compose -f docker-compose.yml -f docker-compose.prod.yml logs --tail=100 -f $(c)
logs-prod-slave:
	docker-compose -f docker-compose.yml -f docker-compose.prod.yml -f docker-compose.slave.prod.yml logs --tail=100 -f $(c)
logs-ws:
	docker-compose -f docker-compose.yml logs --tail=100 -f server1c-ws
logs-db-master:
	docker-compose -f docker-compose.yml logs --tail=100 -f server1c-db
logs-db-slave:
	docker-compose -f docker-compose.slave.dev.yml logs --tail=100 -f $(c)
logs-backup:
	docker-compose -f docker-compose.backup.yml logs --tail=100 -f server1c-db-backup
#Login to containers
.PHONY: login-server1c login-ws login-db-master login-dev-db-slave login-prod-db-slave db-master-shell
login-server1c:
	docker-compose -f docker-compose.yml exec server1c /bin/bash
login-ws:
	docker-compose -f docker-compose.yml exec server1c-ws /bin/bash
login-db-master:
	docker-compose -f docker-compose.yml exec server1c-db /bin/bash
login-dev-db-slave:
	docker-compose -f docker-compose.slave.dev.yml exec dev-db-slave /bin/bash
login-prod-db-slave:
	docker-compose -f docker-compose.slave.prod.yml exec prod-db-slave /bin/bash
db-master-shell:
	docker-compose -f docker-compose.yml exec server1c-db psql -U postgres

