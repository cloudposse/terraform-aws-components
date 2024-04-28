export DOCKER_ORG ?= cloudposse
export DOCKER_IMAGE ?= $(DOCKER_ORG)/terraform-root-modules
export DOCKER_TAG ?= latest
export DOCKER_IMAGE_NAME ?= $(DOCKER_IMAGE):$(DOCKER_TAG)
export DOCKER_BUILD_FLAGS =
export README_DEPS ?= docs/targets.md docs/terraform.md
-include $(shell curl -sSL -o .build-harness "https://cloudposse.tools/build-harness"; echo .build-harness)

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

## Rebuild README for Terraform Mixins
rebuild-mixins-docs:
	bin/rebuild-mixins-docs.sh

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

update-providers:
	@find . -maxdepth 3 -name providers.tf | grep -Ev './deprecated|./modules/account|./modules/tfstate-backend/|./modules/datadog|./modules/aws-saml/|./modules/aws-sso|./modules/aws-inspector2/|./modules/aws-team-roles/|./modules/aws-teams/|./modules/eks/cluster/|./modules/github-oidc-provider/|./modules/guardduty/|./modules/security-hub/|./modules/spacelift/admin-stack|./modules/spacelift/spaces/' | rev | cut -d'/' -f2- | rev | while read paths; do cp ./mixins/providers.depth-1.tf $$paths/providers.tf; done
	@find . -mindepth 4 -maxdepth 4 -name providers.tf | grep -Ev './deprecated|./modules/account|./modules/tfstate-backend|./modules/datadog|./modules/aws-saml/|./modules/eks/cluster/|./modules/spacelift/' | rev | cut -d'/' -f2- | rev | while read paths; do cp ./mixins/providers.depth-2.tf $$paths/providers.tf; done
