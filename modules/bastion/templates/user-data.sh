#!/bin/bash

# Install docker
echo "Installing docker..."
amazon-linux-extras install docker
amazon-linux-extras enable docker

mkdir -p ~/.docker
echo '{ "credsStore": "ecr-login" }' > ~/.docker/config.json

service docker start
usermod -a -G docker ec2-user

# Additional Packages
echo "Installing Additional Packages"
yum install -y curl jq git gcc amazon-ecr-credential-helper

# Script
echo "Moving script to /usr/bin/container.sh"
sudo mv /tmp/container.sh /usr/bin/container.sh

echo "-----------------------"
echo "END OF CUSTOM USER DATA"
echo "-----------------------"
