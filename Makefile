export DOCKER_ORG ?= cloudposse
export DOCKER_IMAGE ?= $(DOCKER_ORG)/terraform-root-modules
export DOCKER_TAG ?= latest
export DOCKER_IMAGE_NAME ?= $(DOCKER_IMAGE):$(DOCKER_TAG)
export DOCKER_BUILD_FLAGS = 

-include $(shell curl -sSL -o .build-harness "https://git.io/build-harness"; echo .build-harness)

all: init deps build install run

deps:
	@exit 0

build:
	@make --no-print-directory docker:build

push:
	docker push $(DOCKER_IMAGE)

run:
	docker run -it ${DOCKER_IMAGE_NAME} sh
