include env_make

NS = soflo1
VERSION = 1.0
REPO = octoprint
NAME = docker-octoprint
INSTANCE = default

.PHONY: build pull push sell run start stop rm release container install

build:
	docker build -t $(NS)/$(REPO):$(VERSION) --build-arg arch=$(TARGET) --build-arg version=$(OCTOPRINT-VERSION) .

push:
	docker push $(NS)/$(REPO):$(VERSION)

pull:
	docker pull $(NS)/$(REPO):$(VERSION)
	
shell:
	docker run --rm --name $(NAME)-$(INSTANCE) -i -t $(PORTS) $(MOUNTS) $(DEVNCES) $(NS)/$(REPO):$(VERSION) /bin/bash
				
start:
	docker run -d --name $(NAME)-$(INSTANCE) $(PORTS) $(MOUNTS) $(DEVICES) $(NS)/$(REPO):$(VERSION)
						
stop:
	docker stop $(NAME)-$(INSTANCE)
							
release: build push

container:
	docker volume create $(NAME)-volume

install: pull container start

backup: 
	docker run --rm --volumes-from $(NAME)-$(INSTANCE) --name tmp-backup -v ${CURDIR}:/backup $(TARGET)/python:2.7-slim-stretch tar cvf /backup/backup.tar --exclude=/data/uploads /data
	docker run -d -v ${CURDIR}:/backup --name $(NAME)-volume-backup $(TARGET)/python:2.7-slim-stretch /bin/sh -c "cd / && tar xvf /backup/backup.tar"
	docker commit $(NAME)-volume-backup $(NS)/$(REPO)-volume-backup:$(VERSION)-$(TIMESTAMP)
	docker commit $(NAME)-volume-backup $(NS)/$(REPO)-volume-backup:latest
	docker push $(NS)/$(REPO)-volume-backup:$(VERSION)-$(TIMESTAMP)
	docker push $(NS)/$(REPO)-volume-backup:latest
	docker rm $(NAME)-volume-backup 
	rm -f backup.tar

restore: pull
	mocker pull $(NS)/$(REPO)-volume-backup:latest
	docker run -i -t --name $(REPO)-backup $(NS)/$(REPO)-volume-backup:$(VERSION) /bin/sh
	docker run -d ---volumes-from $(REPO)-backup -name $(NAME)-$(INSTANCE) $(PORTS) $(DEVICES) $(NS)/$(REPO):$(VERSION)

default: build
