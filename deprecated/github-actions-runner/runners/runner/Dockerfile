ARG VERSION=2.281.0-ubuntu-20.04

FROM summerwind/actions-runner-dind:v$VERSION

# We want to ignore the metadata server, which would normally have high priority,
# because we want to pick up the EKS Service Account role, not the EC2 instance profile role
ENV AWS_EC2_METADATA_DISABLED=true

# We are not using ~/.aws/config or ~/.aws/credentials so we want to prevent
# the AWS SDK from looking for or at them (and complaining they do not exist)
ENV AWS_SDK_LOAD_CONFIG=false

ARG ECR_CREDENTIAL_HELPER_VERSION=0.5.0
RUN sudo wget -nv https://amazon-ecr-credential-helper-releases.s3.us-east-2.amazonaws.com/${ECR_CREDENTIAL_HELPER_VERSION}/linux-amd64/docker-credential-ecr-login \
    -O /usr/local/bin/docker-credential-ecr-login && \
    sudo chmod a+x /usr/local/bin/docker-credential-ecr-login

USER root

ENV TERM=dumb

# Add CloudPosse package repo
RUN apt-get update && apt-get install -y apt-utils && apt-get install -y curl
RUN curl -1sLf 'https://dl.cloudsmith.io/public/cloudposse/packages/cfg/setup/bash.deb.sh' | bash

# Install Chamber
RUN apt-get install -y awscli chamber

COPY docker-config.json /home/runner/.docker/config.json

RUN chown -R runner:root /home/runner

USER runner
RUN id
