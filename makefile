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
	docker run --rm --name $(NAME)-$(INSTANCE) -i -t $(PORTS) $(VOLUMES) $(DEVICES) $(NS)/$(REPO):$(VERSION) /bin/bash
				
start:
	docker run -d --name $(NAME)-$(INSTANCE) $(PORTS) $(VOLUMES) $(DEVICES) $(RUN_FLAG) $(NS)/$(REPO):$(VERSION)
						
stop:
	docker stop $(NAME)-$(INSTANCE)
							
release: build push

container:
	docker volume create $(NAME)-volume

install: pull container start

backup: 
	docker run --rm --volumes-from $(NAME)-$(INSTANCE) --name tmp-backup -v $(HOST_BACKUP_DIR):/backup busybox tar cvf /backup/$(NAME)-backup-$(TIMESTAMP).tar --exclude=data/uploads /data
	cp $(HOST_BACKUP_DIR)/$(NAME)-backup-$(TIMESTAMP).tar $(HOST_BACKUP_DIR)/$(NAME)-backup-latest.tar

restore: stop 
	docker volume rm -f $(NAME)-volume
	docker volume create $(NAME)-volume
	docker run -d $(VOLUMES) -v $(HOME)/backup:/backup busybox /bin/sh -c "cd / && tar xvf /backup/$(NAME)-backup-latest.tar" 

	start

default: build
