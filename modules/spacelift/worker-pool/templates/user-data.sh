#!/bin/bash -e

spacelift() { (
  set -e

  echo "Updating packages (security)" | tee -a /var/log/spacelift/info.log
  yum update-minimal --security -y 1>>/var/log/spacelift/info.log 2>>/var/log/spacelift/error.log

  if ! which docker-credential-ecr-login; then
    yum install -y amazon-ecr-credential-helper
  fi
  # Due to https://github.com/docker/cli/issues/2738
  # we need to create the config.json file for all users
  for home in /root $(ls /home); do
    mkdir -p $home/.docker
    echo '{"credsStore": "ecr-login"}' >$home/.docker/config.json
  done
  docker pull ${spacelift_runner_image}

  %{ if github_netrc_enabled }
  export GITHUB_TOKEN=$(aws ssm get-parameters --region=${region} --name ${github_netrc_ssm_path_token} --with-decryption --query "Parameters[0].Value" --output text)
  export GITHUB_USER=$(aws ssm get-parameters --region=${region} --name ${github_netrc_ssm_path_user} --with-decryption --query "Parameters[0].Value" --output text)

  # Allows downloading terraform modules using a GitHub PAT
  NETRC_FILE="/root/.netrc"
  echo "Creating $NETRC_FILE"
  printf "machine github.com\n" >"$NETRC_FILE"
  printf "login %s\n" "$GITHUB_USER" >>"$NETRC_FILE"
  printf "password %s\n" "$GITHUB_TOKEN" >>"$NETRC_FILE"
  echo "Created $NETRC_FILE"

  # Converts ssh clones into https clones to take advantage of the GitHub PAT
  ## NOTE: --system cannot be used as HOME is unset during the cloud-init userdata portion
  ## so --file has to be passed in manually.
  yum install git -y
  GIT_CONFIG="/root/.gitconfig"
  echo "Creating $GIT_CONFIG"
  git config --file $GIT_CONFIG url."https://github.com/".insteadOf "git@github.com:"
  git config --file $GIT_CONFIG url."https://github.com/".insteadOf "ssh://git@github.com/" --add
  echo "Created $GIT_CONFIG"
  yum remove git -y

  # Mount the .netrc and .gitconfig files into the container
  export SPACELIFT_WORKER_EXTRA_MOUNTS=$NETRC_FILE:/conf/.netrc,$GIT_CONFIG:/conf/.gitconfig
  %{ endif }

  %{ if infracost_enabled }
  export INFRACOST_API_KEY=$(aws ssm get-parameters --region=${region} --name ${infracost_api_token_ssm_path} --with-decryption --query "Parameters[0].Value" --output text)
  export INFRACOST_CLI_ARGS=${infracost_cli_args}
  export INFRACOST_WARN_ON_FAILURE=${infracost_warn_on_failure}
  %{ endif }

  export SPACELIFT_POOL_PRIVATE_KEY=${spacelift_worker_pool_private_key}
  export SPACELIFT_TOKEN=${spacelift_worker_pool_config}
  # This is a comma separated list of all the environment variables to read from the env file
  export SPACELIFT_WHITELIST_ENVS=AWS_ACCESS_KEY_ID,AWS_SECRET_ACCESS_KEY,AWS_SESSION_TOKEN,AWS_SDK_LOAD_CONFIG,AWS_CONFIG_FILE,AWS_PROFILE,GITHUB_TOKEN,INFRACOST_API_KEY,ATMOS_BASE_PATH,TF_VAR_terraform_user
  # This is a comma separated list of all the sensitive environment variables that will show up masked if printed during a run
  export SPACELIFT_MASK_ENVS=AWS_ACCESS_KEY_ID,AWS_SECRET_ACCESS_KEY,AWS_SESSION_TOKEN,GITHUB_TOKEN,INFRACOST_API_KEY
  export SPACELIFT_LAUNCHER_LOGS_TIMEOUT=30m
  export SPACELIFT_LAUNCHER_RUN_TIMEOUT=120m
  # These vars are prefixed with TMP_ so they do not conflict with AWS_ specific vars
  export TMP_AWS_SDK_LOAD_CONFIG=true
  export TMP_AWS_CONFIG_FILE=${aws_config_file}
  export TMP_AWS_PROFILE=${aws_profile}

  echo "Turning on swap" | tee -a /var/log/spacelift/info.log
  dd if=/dev/zero of=/swapfile bs=128M count=32 2>/var/log/spacelift/error.log
  chmod 600 /swapfile 2>/var/log/spacelift/error.log
  mkswap /swapfile 2>/var/log/spacelift/error.log
  swapon /swapfile 2>/var/log/spacelift/error.log
  swapon -s | tee -a /var/log/spacelift/info.log

  echo "Downloading Spacelift launcher" | tee -a /var/log/spacelift/info.log
  curl https://downloads.${spacelift_domain_name}/spacelift-launcher --output /usr/bin/spacelift-launcher 2>>/var/log/spacelift/error.log

  echo "Making the Spacelift launcher executable" | tee -a /var/log/spacelift/info.log
  chmod 755 /usr/bin/spacelift-launcher 2>>/var/log/spacelift/error.log

  echo "Retrieving EC2 instance ID" | tee -a /var/log/spacelift/info.log
  export SPACELIFT_METADATA_instance_id=$(ec2-metadata --instance-id | cut -d ' ' -f2)

  echo "Retrieving EC2 ASG ID" | tee -a /var/log/spacelift/info.log
  export SPACELIFT_METADATA_asg_id=$(aws autoscaling --region=${region} describe-auto-scaling-instances --instance-ids "$SPACELIFT_METADATA_instance_id" | jq -r '.AutoScalingInstances[0].AutoScalingGroupName')

  echo "Preparing Spacelift ENV variables" | tee -a /var/log/spacelift/info.log
  env_file="/etc/spacelift/spacelift.env"
  sudo mkdir -p "/etc/spacelift"
  sudo touch "$env_file"
  sudo chmod 744 "$env_file"
  printf "SPACELIFT_POOL_PRIVATE_KEY=%s\n" "$SPACELIFT_POOL_PRIVATE_KEY" >"$env_file"
  printf "SPACELIFT_TOKEN=%s\n" "$SPACELIFT_TOKEN" >>"$env_file"
  printf "SPACELIFT_WHITELIST_ENVS=%s\n" "$SPACELIFT_WHITELIST_ENVS" >>"$env_file"
  printf "SPACELIFT_MASK_ENVS=%s\n" "$SPACELIFT_MASK_ENVS" >>"$env_file"
  printf "SPACELIFT_LAUNCHER_LOGS_TIMEOUT=%s\n" "$SPACELIFT_LAUNCHER_LOGS_TIMEOUT" >>"$env_file"
  printf "SPACELIFT_LAUNCHER_RUN_TIMEOUT=%s\n" "$SPACELIFT_LAUNCHER_RUN_TIMEOUT" >>"$env_file"
  printf "SPACELIFT_METADATA_instance_id=%s\n" "$SPACELIFT_METADATA_instance_id" >>"$env_file"
  printf "SPACELIFT_METADATA_asg_id=%s\n" "$SPACELIFT_METADATA_asg_id" >>"$env_file"
  printf "AWS_SDK_LOAD_CONFIG=%s\n" "$TMP_AWS_SDK_LOAD_CONFIG" >>"$env_file"
  printf "AWS_CONFIG_FILE=%s\n" "$TMP_AWS_CONFIG_FILE" >>"$env_file"
  printf "AWS_PROFILE=%s\n" "$TMP_AWS_PROFILE" >>"$env_file"
  printf "ATMOS_BASE_PATH=%s\n" "/mnt/workspace/source" >>"$env_file"
  printf "TF_VAR_terraform_user=%s\n" "spacelift" >>"$env_file"
  [[ ! -z "$GITHUB_TOKEN" ]] && printf "GITHUB_TOKEN=%s\n" "$GITHUB_TOKEN" >>"$env_file"
  [[ ! -z "$GITHUB_USER" ]] && printf "GITHUB_USER=%s\n" "$GITHUB_USER" >>"$env_file"
  [[ ! -z "$SPACELIFT_WORKER_EXTRA_MOUNTS" ]] && printf "SPACELIFT_WORKER_EXTRA_MOUNTS=%s\n" "$SPACELIFT_WORKER_EXTRA_MOUNTS" >>"$env_file"
  [[ ! -z "$INFRACOST_API_KEY" ]] && printf "INFRACOST_API_KEY=%s\n" "$INFRACOST_API_KEY" >>"$env_file"

  echo "Enabling Spacelift agent services" | tee -a /var/log/spacelift/info.log
  sudo systemctl enable spacelift@{1..${spacelift_agents_per_node}}.service

  echo "Enabling Amazon SSM agent" | tee -a /var/log/spacelift/info.log
  sudo systemctl enable amazon-ssm-agent

  echo "Reloading systemd daemon" | tee -a /var/log/spacelift/info.log
  sudo systemctl daemon-reload

  echo "Starting Amazon SSM agent" | tee -a /var/log/spacelift/info.log
  sudo systemctl start amazon-ssm-agent

  echo "Starting Spacelift agents" | tee -a /var/log/spacelift/info.log
  sudo systemctl start spacelift@{1..${spacelift_agents_per_node}}.service

); }

spacelift
