BUCKET ?= # vst-platform-usw2-dev-lambda-source
AWS_PROFILE ?= # vst-platform-gbl-dev-admin

all: deps build zip s3-cp
	@exit 0

## Install dependencies (if any)
deps:
	go get github.com/aws/aws-lambda-go/lambda

build:
	GOOS=linux go build hello_world.go

zip:
	@zip hello-world-go.zip hello_world

s3-cp:
	@aws --profile $(AWS_PROFILE) s3 cp hello-world-go.zip s3://$(BUCKET)/hello-world-go.zip --sse AES256
