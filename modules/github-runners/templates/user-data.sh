#!/bin/bash -e
exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

# Install docker
amazon-linux-extras install docker
amazon-linux-extras install ruby2.6
amazon-linux-extras enable docker

mkdir -p ~/.docker
echo '{ "credsStore": "ecr-login" }' > ~/.docker/config.json

service docker start
usermod -a -G docker ec2-user

yum install -y curl jq git go gcc mysql-devel ruby-devel rubygems amazon-ecr-credential-helper
gem install bundler

sudo systemctl enable amazon-ssm-agent
sudo systemctl start amazon-ssm-agent

export CONFIG_DESTINATION=/opt/aws/amazon-cloudwatch-agent/bin/config.json
export CONFIG_SOURCE=/tmp/amazon-cloudwatch-agent.json
export DOWNLOAD_URL=https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
export RPM_PATH=/tmp/amazon-cloudwatch-agent.rpm

curl $DOWNLOAD_URL --output $RPM_PATH
sudo rpm -U $RPM_PATH
rm $RPM_PATH
sudo mv $CONFIG_SOURCE $CONFIG_DESTINATION
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:$CONFIG_DESTINATION

export RUNNER_ALLOW_RUNASROOT=true
export RUNNER_CFG_PAT=${github_token}
export USER=root
curl -s https://raw.githubusercontent.com/actions/runner/${runner_version}/scripts/create-latest-svc.sh | bash -s ${github_scope}
