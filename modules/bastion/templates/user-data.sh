#!/bin/bash

# Mount additional volume
echo "Mounting additional volume..."
while [ ! -b $(readlink -f /dev/sdh) ]; do echo 'waiting for device /dev/sdh'; sleep 5 ; done
blkid $(readlink -f /dev/sdh) || mkfs -t ext4 $(readlink -f /dev/sdh)
e2label $(readlink -f /dev/sdh) sdh-volume
grep -q ^LABEL=sdh-volume /etc/fstab || echo 'LABEL=sdh-volume /mnt ext4 defaults' >> /etc/fstab
grep -q \"^$(readlink -f /dev/sdh) /mnt \" /proc/mounts || mount /mnt

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
