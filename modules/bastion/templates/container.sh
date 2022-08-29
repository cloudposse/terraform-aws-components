#!/bin/bash
REGION=${ region }
REPOSITORY=${ image_repository }
IMAGE=$REPOSITORY/${ image_container }

aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $REPOSITORY

docker pull $IMAGE
docker run --rm \
  -it $IMAGE bash -c "${ container_command }"
