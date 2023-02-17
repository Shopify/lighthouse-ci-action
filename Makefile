USER_NAME := shopify
PROJECT_NAME := $(USER_NAME)/gha-lighthouse-ci
VERSION := 2.0.0
GITSHA := $(shell echo $$(git describe --always --long --dirty))
DOCKER_COMMAND := podman
PACKAGE_REGISTRY_URL := ghcr.io

export GITSHA
export VERSION

# Make sure to create an access token and save it under `CR_PAT` before running the login command. Instructions:
# https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token
# You will need scopes `read:packages`, `write:packages`, `delete:packages`

base: Dockerfile
	DOCKER_BUILDKIT=1 $(DOCKER_COMMAND) build -t $(PROJECT_NAME):$(VERSION) -t $(PROJECT_NAME):$(GITSHA) - < Dockerfile.base

login:
	echo $(CR_PAT) | $(DOCKER_COMMAND) login $(PACKAGE_REGISTRY_URL) -u $(USER_NAME) --password-stdin

push: base
	$(DOCKER_COMMAND) push $(PROJECT_NAME):$(VERSION) $(PACKAGE_REGISTRY_URL)/$(PROJECT_NAME)

runner: base
	DOCKER_BUILDKIT=1 $(DOCKER_COMMAND) build -t $(PROJECT_NAME)-runner:$(VERSION) -t $(PROJECT_NAME)-runner:$(GITSHA) .

ssh: runner
	$(DOCKER_COMMAND) run -it --entrypoint /bin/bash $(PROJECT_NAME)-runner:$(VERSION)

# echo $CR_PAT | docker/podman login ghcr.io -u shopify --password-stdin
