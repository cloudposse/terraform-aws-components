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
echo "Installing postgresql11..."
amazon-linux-extras install postgresql11
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

curl -1sLf 'https://dl.cloudsmith.io/public/cloudposse/packages/setup.rpm.sh' | sudo -E bash
yum install -y chamber

%{ if ssh_pub_keys == true ~}
for user_name in $(chamber list bastion/ssh_pub_keys  | cut -d$'\t' -f1 | tail -n +2);
do
	groupadd $user_name;
	useradd -m -g $user_name $user_name
	mkdir /home/$user_name/.ssh
	chmod 700 /home/$user_name/.ssh
	cd /home/$user_name/.ssh
	touch authorized_keys
	chmod 600 authorized_keys
	chamber read bastion/ssh_pub_keys $user_name -q > authorized_keys
	chown $user_name:$user_name -R /home/$user_name
done
%{~ endif }

echo "-----------------------"
echo "END OF CUSTOM USER DATA"
echo "-----------------------"
