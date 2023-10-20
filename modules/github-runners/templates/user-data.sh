#!/bin/bash -e
exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

${pre_install}

# Install docker
dnf -y install docker

# Enable docker unit
systemctl enable docker

mkdir -p /root/.docker
echo '{ "credsStore": "ecr-login" }' >/root/.docker/config.json
mkdir -p /home/ec2-user/.docker
echo '{ "credsStore": "ecr-login" }' >/home/ec2-user/.docker/config.json

service docker start
usermod -a -G docker ec2-user

echo "Installing required packages..."
yum install -y \
	git \
	libicu \
	amazon-ecr-credential-helper \
	amazon-cloudwatch-agent

echo "Configuring CloudWatch Agent..."
# Configure cloudwatch agent
export CONFIG_DESTINATION=/opt/aws/amazon-cloudwatch-agent/bin/config.json
export CONFIG_SOURCE=/tmp/amazon-cloudwatch-agent.json

sudo cp $CONFIG_SOURCE $CONFIG_DESTINATION
amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:$CONFIG_DESTINATION

echo "Installing runner..."
export REGION=$(TOKEN=$(curl -sX PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600") && curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/placement/region)
export RUNNER_TOKEN=$(aws --region $REGION ssm get-parameter --with-decryption --name ${github_token_ssm_path} | jq -r .Parameter.Value)
export AMI_ID=$(TOKEN=$(curl -sX PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600") && curl -H "X-aws-ec2-metadata-token: $TOKEN" -v http://169.254.169.254/latest/meta-data/ami-id)
export INSTANCE_TYPE=$(TOKEN=$(curl -sX PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600") && curl -H "X-aws-ec2-metadata-token: $TOKEN" -v http://169.254.169.254/latest/meta-data/instance-type)
export INSTANCE_ID=$(TOKEN=$(curl -sX PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600") && curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)
export DATESTAMP=$(date +"%Y-%m-%d")
# e.g. i-02f6ddaed897352c2_2099-06-23
export NODE_NAME="$INSTANCE_ID"_"$DATESTAMP"
# region is omitted here since the abbreviated region is part of the context
export LABELS="${labels},$INSTANCE_TYPE,$AMI_ID"
export RUNNER_ALLOW_RUNASROOT=true
export USER=root

${post_install}

ls -la /tmp
/tmp/create-latest-svc.sh ${github_scope} "" $NODE_NAME $USER $LABELS ${runner_group}
