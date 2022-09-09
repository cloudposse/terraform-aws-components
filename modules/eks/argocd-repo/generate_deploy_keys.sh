#!/bin/bash
set -e

environments=(
)

function main {
    for environment in "${environments[@]}"; do
        echo $environment
        SPLIT=(${environment//// })
        tenant=${SPLIT[0]}
        environment_stage=${SPLIT[1]}

        # Generate public and private key pair
        private_key_file=$tenant-$environment_stage
        public_key_file=$tenant-$environment_stage.pub
        ssh-keygen -q -t ed25519 -f ./$private_key_file -C "" -N "" <<<y >/dev/null 2>&1

        # Store the public and private key data in SSM via chamber
        private_key=$(<$private_key_file)
        echo "$private_key" | AWS_PROFILE=acme-tenant-gbl-corp-admin CHAMBER_KMS_KEY_ALIAS=aws/ssm chamber --verbose write argocd/deploy_keys/$tenant $environment_stage -
        public_key=$(<$public_key_file)
        echo "$public_key" | AWS_PROFILE=acme-tenant-gbl-corp-admin CHAMBER_KMS_KEY_ALIAS=aws/ssm chamber --verbose write argocd/deploy_keys/$tenant $environment_stage.pub -

        # Delete the public and private key files
        rm $private_key_file
        rm $public_key_file
    done
}

main
