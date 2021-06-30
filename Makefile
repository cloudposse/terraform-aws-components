export DOCKER_ORG ?= cloudposse
export DOCKER_IMAGE ?= $(DOCKER_ORG)/terraform-root-modules
export DOCKER_TAG ?= latest
export DOCKER_IMAGE_NAME ?= $(DOCKER_IMAGE):$(DOCKER_TAG)
export DOCKER_BUILD_FLAGS =
export README_DEPS ?= docs/targets.md docs/terraform.md
-include $(shell curl -sSL -o .build-harness "https://git.io/build-harness"; echo .build-harness)

UPSTREAM_PATH := "NONE"
COMPONENT    := "NONE"

all: init deps build install run

deps:
	@exit 0

build:
	@make --no-print-directory docker:build

push:
	docker push $(DOCKER_IMAGE)

run:
	docker run -it ${DOCKER_IMAGE_NAME} sh

## Rebuild README for all Terraform components
rebuild-docs:
	@pre-commit run --all-files terraform_docs

## Upstream a given component
upstream-component:
# Requires:
#   UPSTREAM_PATH -- The relative or absolute path to the upstream project directory
#   COMPONENT     -- The name of the component to upstream into this repository
	@test "$(UPSTREAM_PATH)" != "NONE" || { echo "Please set UPSTREAM_PATH"; exit 1; }
	@test "$(COMPONENT)" != "NONE" || { echo "Please set COMPONENT"; exit 1; }

	@cp -r $(UPSTREAM_PATH)/components/terraform/$(COMPONENT) ./modules/; \
		test -f "./modules/$(COMPONENT)/backend.tf.json" && rm ./modules/$(COMPONENT)/backend.tf.json; \
		test -d "./modules/$(COMPONENT)/.terraform" && rm -r ./modules/$(COMPONENT)/.terraform; \
		echo "Upstreamed ./modules/$(COMPONENT)";
