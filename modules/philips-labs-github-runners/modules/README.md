# Modules

## `webhook-github-app`

This is a fork of https://github.com/philips-labs/terraform-aws-github-runner/tree/main/modules/webhook-github-app.

We customized it until this PR is resolved as it does not update the github app webhook until this is merged.
 * https://github.com/philips-labs/terraform-aws-github-runner/pull/3625

This module also requires an environment variable
  * `GH_TOKEN` - a github token be set

This module also requires the `gh` cli to be installed. Your Dockerfile can be updated to include the following to install it:
```dockerfile
ARG GH_CLI_VERSION=2.39.1
# ...
ARG GH_CLI_VERSION
RUN apt-get update && apt-get install -y --allow-downgrades \
    gh="${GH_CLI_VERSION}-*"
```

You can disable this module with `enable_update_github_app_webhook` set to `false`. This means you must manually
