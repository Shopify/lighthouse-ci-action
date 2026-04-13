PROJECT_NAME := lighthouse-ci-action
GITSHA := $(shell git describe --always --long --dirty)

build:
	DOCKER_BUILDKIT=1 docker build -t $(PROJECT_NAME):$(GITSHA) -t $(PROJECT_NAME):local .

ssh: build
	docker run -it --entrypoint /bin/bash $(PROJECT_NAME):local
