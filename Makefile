DOCKER_REGISTRY = index.docker.io
IMAGE_NAME = awscli
IMAGE_VERSION = latest
IMAGE_ORG = flaccid
IMAGE_TAG = $(DOCKER_REGISTRY)/$(IMAGE_ORG)/$(IMAGE_NAME):$(IMAGE_VERSION)

WORKING_DIR := $(shell pwd)

.DEFAULT_GOAL := build

.PHONY: build push

release:: build push ## builds and pushes the docker image to the registry

push:: ## pushes the docker image to the registry
		@docker push $(IMAGE_TAG)

build:: ## builds the docker image locally
		@echo http_proxy=$(HTTP_PROXY) http_proxy=$(HTTPS_PROXY)
		@echo building $(IMAGE_TAG)
		@docker build --pull \
			--build-arg=http_proxy=$(HTTP_PROXY) \
			--build-arg=https_proxy=$(HTTPS_PROXY) \
			-t $(IMAGE_TAG) $(WORKING_DIR)

build-deb:: ## builds the docker image locally (debian)
		@echo http_proxy=$(HTTP_PROXY) http_proxy=$(HTTPS_PROXY)
		@docker build \
			--pull \
		 	--file Dockerfile.debian \
			--build-arg=http_proxy=$(HTTP_PROXY) \
			--build-arg=https_proxy=$(HTTPS_PROXY) \
			-t $(DOCKER_REGISTRY)/$(IMAGE_ORG)/$(IMAGE_NAME):deb $(WORKING_DIR)

push-deb:: ## pushes the debian version of the image
		@docker push $(DOCKER_REGISTRY)/$(IMAGE_ORG)/$(IMAGE_NAME):deb

build-dev:: ## builds the docker image locally (devel version)
		@echo http_proxy=$(HTTP_PROXY) http_proxy=$(HTTPS_PROXY)
		@docker build \
			--pull \
		 	--file Dockerfile.dev \
			--build-arg=http_proxy=$(HTTP_PROXY) \
			--build-arg=https_proxy=$(HTTPS_PROXY) \
			-t $(DOCKER_REGISTRY)/$(IMAGE_ORG)/$(IMAGE_NAME):dev $(WORKING_DIR)

push-dev:: ## pushes the dev version of the image
		@docker push $(DOCKER_REGISTRY)/$(IMAGE_ORG)/$(IMAGE_NAME):dev

run:: ## runs the docker image locally
		@docker run \
			-it \
			--rm \
			--name awscli \
			-e http_proxy=$(HTTP_PROXY) \
			-e https_proxy=$(HTTPS_PROXY) \
			-e no_proxy=localhost,127.0.0.1 \
				$(DOCKER_REGISTRY)/$(IMAGE_ORG)/$(IMAGE_NAME):$(IMAGE_VERSION)

run-dev:: ## runs the dev version of the docker image locally
		@docker run \
			-it \
			--rm \
			--name awscli \
				$(DOCKER_REGISTRY)/$(IMAGE_ORG)/$(IMAGE_NAME):dev

run-full:: ## runs the docker image locally with all opinionated options
		@docker run \
			-it \
			--rm \
			--name awscli \
			-e http_proxy=$(HTTP_PROXY) \
			-e https_proxy=$(HTTPS_PROXY) \
			-e no_proxy=localhost,127.0.0.1 \
			-e awscli_API=true \
			-e TLS_SELF_SIGNED=true \
				$(DOCKER_REGISTRY)/$(IMAGE_ORG)/$(IMAGE_NAME):$(IMAGE_VERSION)

run-test:: ## runs the docker image locally with opinionated options for testing
		@docker run \
			-it \
			--rm \
			--name awscli \
			-e http_proxy=$(HTTP_PROXY) \
			-e https_proxy=$(HTTPS_PROXY) \
			-e no_proxy=localhost,127.0.0.1 \
			-e ENABLE_PAM_EAUTH=true \
			-e awscli_API=true \
			-e awscli_API_SSL=false \
			-e awscli_PASSWORD=awscli \
			-p 8000:8000 \
				$(DOCKER_REGISTRY)/$(IMAGE_ORG)/$(IMAGE_NAME):$(IMAGE_VERSION)

exec-shell:: ## executs a shell on the running docker container
		@docker exec \
			-it \
      awscli \
			/bin/sh

# a help target including self-documenting targets (see the awk statement)
define HELP_TEXT
Usage: make [TARGET]... [MAKEVAR1=SOMETHING]...

Available targets:
endef
export HELP_TEXT
help: ## this help target
	@cat .banner
	@echo
	@echo "$$HELP_TEXT"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / \
		{printf "\033[36m%-30s\033[0m  %s\n", $$1, $$2}' $(MAKEFILE_LIST)
