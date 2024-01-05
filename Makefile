PROJECT_NAME := cpclermont/lighthouse-ci-action
VERSION := 2.0.0
GITSHA:= $(shell echo $$(git describe --always --long --dirty))

export GITSHA
export VERSION

base: Dockerfile
	DOCKER_BUILDKIT=1 docker build -t $(PROJECT_NAME):$(VERSION) -t $(PROJECT_NAME):$(GITSHA) - < Dockerfile.base

push: base
	docker push $(PROJECT_NAME):$(VERSION)

runner: base
	DOCKER_BUILDKIT=1 docker build -t $(PROJECT_NAME)-runner:$(VERSION) -t $(PROJECT_NAME)-runner:$(GITSHA) .

ssh: runner
	docker run -it --entrypoint /bin/bash $(PROJECT_NAME)-runner:$(VERSION)
