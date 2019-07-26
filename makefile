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
	docker volume create my-vol
			
shell:
	docker run --rm --name $(NAME)-$(INSTANCE) -i -t $(PORTS) $(MOUNTS) $(DEVICES) $(NS)/$(REPO):$(VERSION) /bin/bash
				
run:
	docker run --rm --name $(NAME)-$(INSTANCE) $(PORTS) $(MOUNTS) $(DEVICES) $(NS)/$(REPO):$(VERSION)
		
start:
	docker run -d --name $(NAME)-$(INSTANCE) $(PORTS) $(MOUNTS) $(DEVICES) $(NS)/$(REPO):$(VERSION)
						
stop:
	docker stop $(NAME)-$(INSTANCE)
							
rm:
	docker rm $(NAME)-$(INSTANCE)
								
release: build
	make push -e VERSION=$(VERSION)

container:
	docker volume create $(NAME)-volume

backup: 
	docker run --rm --volumes-from $(NAME)-$(INSTANCE) --name tmp-backup -v ${CURDIR}:/backup $(TARGET)/python:2.7-slim-stretch tar cvf /backup/backup.tar /data
	docker run -d -v ${CURDIR}:/backup --name $(NAME)-volume-backup $(TARGET)/python:2.7-slim-stretch /bin/sh -c "cd / && tar xvf /backup/backup.tar"
	docker commit $(NAME)-volume-backup $(NS)/$(REPO)-volume-backup:$(VERSION)
	docker push $(NS)/$(REPO)-volume-backup:$(VERSION)
	docker rm $(NAME)-volume-backup 
	rm backup.tar

install: pull container start
									
default: build
