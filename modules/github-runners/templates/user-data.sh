#!/bin/bash -e
exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

# Install dependencies
amazon-linux-extras install docker
amazon-linux-extras install ruby2.6
amazon-linux-extras enable docker

mkdir -p ~/.docker
echo '{ "credsStore": "ecr-login" }' > ~/.docker/config.json

service docker start
usermod -a -G docker ec2-user

yum install -y curl jq git go gcc ruby-devel rubygems amazon-ecr-credential-helper
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

# get instance ID from IMDSv2
imdsv2_token=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
instance_id=$(curl -H "X-aws-ec2-metadata-token: $imdsv2_token" http://169.254.169.254/latest/meta-data/instance-id)
aws_region=$(curl -H "X-aws-ec2-metadata-token: $imdsv2_token" --silent http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)

# Add instance name suffix
runner_name_suffix=$(openssl rand -hex 3)
aws ec2 create-tags --resources $instance_id --tags Key=Name,Value="${runner_name_prefix}-$runner_name_suffix" --region $aws_region

# get GitHub PAT
github_token=$(aws ssm get-parameter --name ${github_token_ssm_path} --region $aws_region --with-decryption | jq -r .Parameter.Value)

# Get Actions Runner Registration Token
registration_token=$(curl -s -X POST https://api.github.com/orgs/${github_org}/actions/runners/registration-token -H "accept: application/vnd.github.everest-preview+json" -H "authorization: token $github_token" | jq -r '.token')

# Install GitHub Actions Runner
mkdir -p /opt/actions-runner
chown -R ec2-user /opt/actions-runner
pushd /opt/actions-runner
curl -O -L https://github.com/actions/runner/releases/download/v${runner_version}/actions-runner-linux-x64-${runner_version}.tar.gz
sudo -u ec2-user tar xzf actions-runner-linux-x64-${runner_version}.tar.gz
sudo -u ec2-user ./config.sh --unattended --url https://github.com/${github_org} --token $registration_token --name "${runner_name_prefix}-$runner_name_suffix" --labels %{ if length(runner_labels) > 0 }-l "${join(",", runner_labels)}"%{ endif }
./svc.sh install
./svc.sh start
popd