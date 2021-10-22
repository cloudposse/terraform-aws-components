ECR_PROFILE ?= vymd-gbl-automation-ops
DOCKER_REGION := us-east-2
DOCKER_REPO := 475282536323.dkr.ecr.us-east-2.amazonaws.com
DOCKER_IMAGE := summerwind/actions-runner
DOCKER_TAG = $(TAG)

help: TAG ?= xxx
help:
	@echo '** Read the README.md file for more details. **'
	@echo
	@echo 'Build the docker image with:'
	@echo
	@echo '  make TAG=$(TAG) build'
	@echo
	@echo 'Push the docker image:'
	@echo
	@echo '  make TAG=$(TAG) push'
	@echo
	@echo 'Update components/helmfile/github-runners/defaults.yaml with the newest image:'
	@echo
	@echo '  runners_image: "$(DOCKER_REPO)/$(DOCKER_IMAGE):$(TAG)"'
	@echo
	@echo 'Deploy the Helmfile:'
	@echo
	@echo '  atmos helmfile deploy github-runners -s ue1-auto'

auth: export AWS_PROFILE = $(ECR_PROFILE)
auth:
	@echo $$AWS_PROFILE
	@aws ecr get-login-password --region $(DOCKER_REGION) | docker login --username AWS --password-stdin $(DOCKER_REPO)

build:
	docker build -t $(DOCKER_REPO)/$(DOCKER_IMAGE):$(DOCKER_TAG) --progress plain .

list-tags:
	@echo
	echo && \
	AWS_PROFILE=$(ECR_PROFILE) \
	aws ecr describe-images --repository-name $(DOCKER_IMAGE) \
		--query 'sort_by(imageDetails,& imagePushedAt)[-80:].imageTags[*]' | jq -rc '.[]'
	@echo

push: export AWS_PROFILE = $(ECR_PROFILE)
push:
	docker push $(DOCKER_REPO)/$(DOCKER_IMAGE):$(DOCKER_TAG)

.DEFAULT_GOAL: help
.PHONY: help list-tags build push

