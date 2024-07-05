# Component: `github-runners`

This component is responsible for provisioning EC2 instances for GitHub runners.

:::info We also have a similar component based on
[actions-runner-controller](https://github.com/actions-runner-controller/actions-runner-controller) for Kubernetes.

:::

## Requirements

## Usage

**Stack Level**: Regional

Here's an example snippet for how to use this component.

```yaml
components:
  terraform:
    github-runners:
      vars:
        cpu_utilization_high_threshold_percent: 5
        cpu_utilization_low_threshold_percent: 1
        default_cooldown: 300
        github_scope: company
        instance_type: "t3.small"
        max_size: 10
        min_size: 1
        runner_group: default
        scale_down_cooldown_seconds: 2700
        wait_for_capacity_timeout: 10m
        mixed_instances_policy:
          instances_distribution:
            on_demand_allocation_strategy: "prioritized"
            on_demand_base_capacity: 1
            on_demand_percentage_above_base_capacity: 0
            spot_allocation_strategy: "capacity-optimized"
            spot_instance_pools: null
            spot_max_price: null
          override:
            - instance_type: "t4g.large"
              weighted_capacity: null
            - instance_type: "m5.large"
              weighted_capacity: null
            - instance_type: "m5a.large"
              weighted_capacity: null
            - instance_type: "m5n.large"
              weighted_capacity: null
            - instance_type: "m5zn.large"
              weighted_capacity: null
            - instance_type: "m4.large"
              weighted_capacity: null
            - instance_type: "c5.large"
              weighted_capacity: null
            - instance_type: "c5a.large"
              weighted_capacity: null
            - instance_type: "c5n.large"
              weighted_capacity: null
            - instance_type: "c4.large"
              weighted_capacity: null
```

## Configuration

### API Token

Prior to deployment, the API Token must exist in SSM.

To generate the token, please follow [these instructions](https://cloudposse.atlassian.net/l/c/N4dH05ud). Once
generated, write the API token to the SSM key store at the following location within the same AWS account and region
where the GitHub Actions runner pool will reside.

```
assume-role <automation-admin role>
chamber write github/runners/<github-org> registration-token ghp_secretstring
```

## Background

### Registration

Github Actions Self-Hosted runners can be scoped to the Github Organization, a Single Repository, or a group of
Repositories (Github Enterprise-Only). Upon startup, each runner uses a `REGISTRATION_TOKEN` to call the Github API to
register itself with the Organization, Repository, or Runner Group (Github Enterprise).

### Running Workflows

Once a Self-Hosted runner is registered, you will have to update your workflow with the `runs-on` attribute specify it
should run on a self-hosted runner:

```
name: Test Self Hosted Runners
on:
  push:
    branches: [main]
jobs:
  build:
    runs-on: [self-hosted]
```

### Workflow Github Permissions (GITHUB_TOKEN)

Each run of the Github Actions Workflow is assigned a GITHUB_TOKEN, which allows your workflow to perform actions
against Github itself such as cloning a repo, updating the checks API status, etc., and expires at the end of the
workflow run. The GITHUB_TOKEN has two permission "modes" it can operate in `Read and write permissions` ("Permissive"
or "Full Access") and `Read repository contents permission` ("Restricted" or "Read-Only"). By default, the GITHUB_TOKEN
is granted Full Access permissions, but you can change this via the Organization or Repo settings. If you opt for the
Read-Only permissions, you can optionally grant or revoke access to specific APIs via the workflow `yaml` file and a
full list of APIs that can be accessed can be found in the
[documentation](https://docs.github.com/en/actions/security-guides/automatic-token-authentication#permissions-for-the-github_token)
and is shown below in the table. It should be noted that the downside to this permissions model is that any user with
write access to the repository can escalate permissions for the workflow by updating the `yaml` file, however, the APIs
available via this token are limited. Most notably the GITHUB_TOKEN does not have access to the `users`, `repos`,
`apps`, `billing`, or `collaborators` APIs, so the tokens do not have access to modify sensitive settings or add/remove
users from the Organization/Repository.

<img src="/assets/refarch/cleanshot-2022-03-01-at-17.14.02-20220301-234351.png" height="664" width="720" /><br/>

> Example of using escalated permissions for the entire workflow

```
name: Pull request labeler
on: [ pull_request_target ]
permissions:
  contents: read
  pull-requests: write
jobs:
  triage:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/labeler@v2
        with:
          repo-token: ${{ secrets.GITHUB_TOKEN }}
```

> Example of using escalated permissions for a job

```
name: Create issue on commit
on: [ push ]
jobs:
  create_commit:
    runs-on: ubuntu-latest
    permissions:
      issues: write
    steps:
      - name: Create issue using REST API
        run: |
          curl --request POST \
          --url https://api.github.com/repos/${{ github.repository }}/issues \
          --header 'authorization: Bearer ${{ secrets.GITHUB_TOKEN }}' \
          --header 'content-type: application/json' \
          --data '{
            "title": "Automated issue for commit: ${{ github.sha }}",
            "body": "This issue was automatically created by the GitHub Action workflow **${{ github.workflow }}**. \n\n The commit hash was: _${{ github.sha }}_."
            }' \
          --fail
```

### Pre-Requisites for Using This Component

In order to use this component, you will have to obtain the `REGISTRATION_TOKEN` mentioned above from your Github
Organization or Repository and store it in SSM Parameter store. In addition, it is recommended that you set the
permissions “mode” for Self-hosted runners to Read-Only. The instructions for doing both are below.

#### Workflow Permissions

1. Browse to
   [https://github.com/organizations/{Org}/settings/actions](https://github.com/organizations/{Org}/settings/actions)
   (Organization) or
   [https://github.com/{Org}/{Repo}/settings/actions](https://github.com/{Org}/{Repo}/settings/actions) (Repository)

2. Set the default permissions for the GITHUB_TOKEN to Read Only

<img src="/assets/refarch/cleanshot-2022-03-01-at-16.10.02-20220302-005602.png" height="199" width="786" /><br/>

### Creating Registration Token

:::info We highly recommend using a GitHub Application with the github-action-token-rotator module to generate the
Registration Token. This will ensure that the token is rotated and that the token is stored in SSM Parameter Store
encrypted with KMS.

:::

#### GitHub Application

Follow the quickstart with the upstream module,
[cloudposse/terraform-aws-github-action-token-rotator](https://github.com/cloudposse/terraform-aws-github-action-token-rotator#quick-start),
or follow the steps below.

1. Create a new GitHub App
1. Add the following permission:

```diff
# Required Permissions for Repository Runners:
## Repository Permissions
+ Actions (read)
+ Administration (read / write)
+ Metadata (read)

# Required Permissions for Organization Runners:
## Repository Permissions
+ Actions (read)
+ Metadata (read)

## Organization Permissions
+ Self-hosted runners (read / write)
```

1. Generate a Private Key

If you are working with Cloud Posse, upload this Private Key, GitHub App ID, and Github App Installation ID to 1Password
and skip the rest. Otherwise, complete the private key setup in `core-<default-region>-auto`.

1. Convert the private key to a PEM file using the following command:
   `openssl pkcs8 -topk8 -inform PEM -outform PEM -nocrypt -in {DOWNLOADED_FILE_NAME}.pem -out private-key-pkcs8.key`
1. Upload PEM file key to the specified ssm path: `/github/runners/acme/private-key` in `core-<default-region>-auto`
1. Create another sensitive SSM parameter `/github/runners/acme/registration-token` in `core-<default-region>-auto` with
   any basic value, such as "foo". This will be overwritten by the rotator.
1. Update the GitHub App ID and Installation ID in the `github-action-token-rotator` catalog.

:::info

If you change the Private Key saved in SSM, redeploy `github-action-token-rotator`

:::

#### (ClickOps) Obtain the Runner Registration Token

1. Browse to
   [https://github.com/organizations/{Org}/settings/actions/runners](https://github.com/organizations/{Org}/settings/actions/runners)
   (Organization) or
   [https://github.com/{Org}/{Repo}/settings/actions/runners](https://github.com/{Org}/{Repo}/settings/actions/runners)
   (Repository)

2. Click the **New Runner** button (Organization) or **New Self Hosted Runner** button (Repository)

3. Copy the Github Runner token from the next screen. Note that this is the only time you will see this token. Note that
   if you exit the `New {Self Hosted} Runner` screen and then later return by clicking the `New {Self Hosted} Runner`
   button again, the registration token will be invalidated and a new token will be generated.

<img src="/assets/refarch/cleanshot-2022-03-01-at-16.12.26-20220302-005927.png" height="1010" width="833" /><br/>

4. Add the `REGISTRATION_TOKEN` to the `/github/token` SSM parameter in the account where Github runners are hosted
   (usually `automation`), encrypted with KMS.

```
chamber write github token <value>
```

# FAQ

## The GitHub Registration Token is not updated in SSM

The `github-action-token-rotator` runs an AWS Lambda function every 30 minutes. This lambda will attempt to use a
private key in its environment configuration to generate a GitHub Registration Token, and then store that token to AWS
SSM Parameter Store.

If the GitHub Registration Token parameter, `/github/runners/acme/registration-token`, is not updated, read through the
following tips:

1. The private key is stored at the given parameter path:
   `parameter_store_private_key_path: /github/runners/acme/private-key`
1. The private key is Base 64 encoded. If you pull the key from SSM and decode it, it should begin with
   `-----BEGIN PRIVATE KEY-----`
1. If the private key has changed, you must _redeploy_ `github-action-token-rotator`. Run a plan against the component
   to make sure there are not changes required.

## The GitHub Registration Token is valid, but the Runners are not registering with GitHub

If you first deployed the `github-action-token-rotator` component initally with an invalid configuration and then
deployed the `github-runners` component, the instance runners will have failed to register with GitHub.

After you correct `github-action-token-rotator` and have a valid GitHub Registration Token in SSM, _destroy and
recreate_ the `github-runners` component.

If you cannot see the runners registered in GitHub, check the system logs on one of EC2 Instances in AWS in
`core-<default-region>-auto`.

## I cannot assume the role from GitHub Actions after deploying

The following error is very common if the GitHub workflow is missing proper permission.

```bash
Error: User: arn:aws:sts::***:assumed-role/acme-core-use1-auto-actions-runner@actions-runner-system/token-file-web-identity is not authorized to perform: sts:TagSession on resource: arn:aws:iam::999999999999:role/acme-plat-use1-dev-gha
```

In order to use a web identity, GitHub Action pipelines must have the following permission. See
[GitHub Action documentation for more](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services#adding-permissions-settings).

```yaml
permissions:
  id-token: write # This is required for requesting the JWT
  contents: read # This is required for actions/checkout
```

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->



## Version Requirements

| Requirement | Version |
| --- | --- |
| `terraform` | >= 1.0.0 |
| `aws` | >= 4.9.0 |
| `cloudinit` | >= 2.2 |


## Providers

| Provider | Version |
| --- | --- |
| `aws` | >= 4.9.0 |
| `cloudinit` | >= 2.2 |


## Modules

Name | Version | Source | Description
--- | --- | --- | ---
`account_map` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a
`autoscale_group` | 0.35.1 | [`cloudposse/ec2-autoscale-group/aws`](https://registry.terraform.io/modules/cloudposse/ec2-autoscale-group/aws/0.35.1) | n/a
`graceful_scale_in` | latest | [`./modules/graceful_scale_in`](https://registry.terraform.io/modules/./modules/graceful_scale_in/) | n/a
`iam_roles` | latest | [`../account-map/modules/iam-roles`](https://registry.terraform.io/modules/../account-map/modules/iam-roles/) | n/a
`sg` | 1.0.1 | [`cloudposse/security-group/aws`](https://registry.terraform.io/modules/cloudposse/security-group/aws/1.0.1) | n/a
`this` | 0.25.0 | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | n/a
`vpc` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a


## Resources

The following resources are used by this module:

  - [`aws_iam_instance_profile.github_action_runner`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) (resource)(iam.tf#102)
  - [`aws_iam_policy.github_action_runner`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) (resource)(iam.tf#86)
  - [`aws_iam_role.github_action_runner`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) (resource)(iam.tf#93)

## Data Sources

The following data sources are used by this module:

  - [`aws_ami.runner`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) (data source)
  - [`aws_iam_policy_document.github_action_runner`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) (data source)
  - [`aws_iam_policy_document.instance_assume_role_policy`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) (data source)
  - [`aws_partition.current`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) (data source)
  - [`aws_ssm_parameter.github_token`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) (data source)
  - [`cloudinit_config.config`](https://registry.terraform.io/providers/hashicorp/cloudinit/latest/docs/data-sources/config) (data source)

## Outputs

<dl>
  <dt><code>autoscaling_group_arn</code></dt>
  <dd>
  The Amazon Resource Name (ARN) of the Auto Scaling Group.<br/>

  </dd>
  <dt><code>autoscaling_group_name</code></dt>
  <dd>
  The name of the Auto Scaling Group.<br/>

  </dd>
  <dt><code>autoscaling_lifecycle_hook_name</code></dt>
  <dd>
  The name of the Lifecycle Hook for the Auto Scaling Group.<br/>

  </dd>
  <dt><code>eventbridge_rule_arn</code></dt>
  <dd>
  The ARN of the Eventbridge rule for the EC2 lifecycle transition.<br/>

  </dd>
  <dt><code>eventbridge_target_arn</code></dt>
  <dd>
  The ARN of the Eventbridge target corresponding to the Eventbridge rule for the EC2 lifecycle transition.<br/>

  </dd>
  <dt><code>iam_role_arn</code></dt>
  <dd>
  The ARN of the IAM role associated with the Autoscaling Group<br/>

  </dd>
  <dt><code>ssm_document_arn</code></dt>
  <dd>
  The ARN of the SSM document.<br/>

  </dd>
</dl>

## Required Variables

Required variables are the minimum set of variables that must be set to use this module.

> [!IMPORTANT]
>
> To customize the names and tags of the resources created by this module, see the [context variables](#context-variables).
>
### `github_scope` (`string`) <i>required</i>


Scope of the runner (e.g. `cloudposse/example` for repo or `cloudposse` for org)<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>Yes</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>unset</code>
>   </dd>
> </dl>
>


### `max_size` (`number`) <i>required</i>


The maximum size of the autoscale group<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>Yes</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>number</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>unset</code>
>   </dd>
> </dl>
>


### `min_size` (`number`) <i>required</i>


The minimum size of the autoscale group<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>Yes</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>number</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>unset</code>
>   </dd>
> </dl>
>


### `region` (`string`) <i>required</i>


AWS Region<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>Yes</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>unset</code>
>   </dd>
> </dl>
>



## Optional Variables
### `account_map_environment_name` (`string`) <i>optional</i>


The name of the environment where `account_map` is provisioned<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>"gbl"</code>
>   </dd>
> </dl>
>


### `account_map_stage_name` (`string`) <i>optional</i>


The name of the stage where `account_map` is provisioned<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>"root"</code>
>   </dd>
> </dl>
>


### `account_map_tenant_name` (`string`) <i>optional</i>


The name of the tenant where `account_map` is provisioned.<br/>
<br/>
If the `tenant` label is not used, leave this as `null`.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `ami_filter` (`map(list(string))`) <i>optional</i>


Map of lists used to look up the AMI which will be used for the GitHub Actions Runner.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>map(list(string))</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   
>
>   ```hcl
>   {
>     "name": [
>       "amzn2-ami-hvm-2.*-x86_64-ebs"
>     ]
>   }
>   ```
>
>   </dd>
> </dl>
>


### `ami_owners` (`list(string)`) <i>optional</i>


The list of owners used to select the AMI of action runner instances.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   
>
>   ```hcl
>   [
>     "amazon"
>   ]
>   ```
>
>   </dd>
> </dl>
>


### `block_device_mappings` <i>optional</i>


Specify volumes to attach to the instance besides the volumes specified by the AMI<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   
>
>   ```hcl
>   list(object({
    device_name  = string
    no_device    = bool
    virtual_name = string
    ebs = object({
      delete_on_termination = bool
      encrypted             = bool
      iops                  = number
      kms_key_id            = string
      snapshot_id           = string
      volume_size           = number
      volume_type           = string
    })
  }))
>   ```
>
>   
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>[]</code>
>   </dd>
> </dl>
>


### `cpu_utilization_high_evaluation_periods` (`number`) <i>optional</i>


The number of periods over which data is compared to the specified threshold<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>number</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>2</code>
>   </dd>
> </dl>
>


### `cpu_utilization_high_period_seconds` (`number`) <i>optional</i>


The period in seconds over which the specified statistic is applied<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>number</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>300</code>
>   </dd>
> </dl>
>


### `cpu_utilization_high_threshold_percent` (`number`) <i>optional</i>


The value against which the specified statistic is compared<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>number</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>90</code>
>   </dd>
> </dl>
>


### `cpu_utilization_low_evaluation_periods` (`number`) <i>optional</i>


The number of periods over which data is compared to the specified threshold<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>number</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>2</code>
>   </dd>
> </dl>
>


### `cpu_utilization_low_period_seconds` (`number`) <i>optional</i>


The period in seconds over which the specified statistic is applied<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>number</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>300</code>
>   </dd>
> </dl>
>


### `cpu_utilization_low_threshold_percent` (`number`) <i>optional</i>


The value against which the specified statistic is compared<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>number</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>10</code>
>   </dd>
> </dl>
>


### `default_cooldown` (`number`) <i>optional</i>


The amount of time, in seconds, after a scaling activity completes before another scaling activity can start<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>number</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>300</code>
>   </dd>
> </dl>
>


### `docker_compose_version` (`string`) <i>optional</i>


The version of docker-compose to install<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>"1.29.2"</code>
>   </dd>
> </dl>
>


### `instance_type` (`string`) <i>optional</i>


Default instance type for the action runner.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>"m5.large"</code>
>   </dd>
> </dl>
>


### `max_instance_lifetime` (`number`) <i>optional</i>


The maximum amount of time, in seconds, that an instance can be in service, values must be either equal to 0 or between 604800 and 31536000 seconds<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>number</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `mixed_instances_policy` <i>optional</i>


Policy to use a mixed group of on-demand/spot of differing types. Launch template is automatically generated. https://www.terraform.io/docs/providers/aws/r/autoscaling_group.html#mixed_instances_policy-1<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   
>
>   ```hcl
>   object({
    instances_distribution = object({
      on_demand_allocation_strategy            = string
      on_demand_base_capacity                  = number
      on_demand_percentage_above_base_capacity = number
      spot_allocation_strategy                 = string
      spot_instance_pools                      = number
      spot_max_price                           = string
    })
    override = list(object({
      instance_type     = string
      weighted_capacity = number
    }))
  })
>   ```
>
>   
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `runner_group` (`string`) <i>optional</i>


GitHub runner group<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>"default"</code>
>   </dd>
> </dl>
>


### `runner_labels` (`list(string)`) <i>optional</i>


List of labels to add to the GitHub Runner (e.g. 'Amazon Linux 2').<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>[]</code>
>   </dd>
> </dl>
>


### `runner_role_additional_policy_arns` (`list(string)`) <i>optional</i>


List of policy ARNs that will be attached to the runners' default role on creation in addition to the defaults<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>[]</code>
>   </dd>
> </dl>
>


### `runner_version` (`string`) <i>optional</i>


GitHub runner release version<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>"2.288.1"</code>
>   </dd>
> </dl>
>


### `scale_down_cooldown_seconds` (`number`) <i>optional</i>


The amount of time, in seconds, after a scaling activity completes and before the next scaling activity can start<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>number</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>300</code>
>   </dd>
> </dl>
>


### `ssm_parameter_name_format` (`string`) <i>optional</i>


SSM parameter name format<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>"/%s/%s"</code>
>   </dd>
> </dl>
>


### `ssm_path` (`string`) <i>optional</i>


GitHub token SSM path<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>"github"</code>
>   </dd>
> </dl>
>


### `ssm_path_key` (`string`) <i>optional</i>


GitHub token SSM path key<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>"registration-token"</code>
>   </dd>
> </dl>
>


### `userdata_post_install` (`string`) <i>optional</i>


Shell script to run post installation of github action runner<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>""</code>
>   </dd>
> </dl>
>


### `userdata_pre_install` (`string`) <i>optional</i>


Shell script to run before installation of github action runner<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>""</code>
>   </dd>
> </dl>
>


### `wait_for_capacity_timeout` (`string`) <i>optional</i>


A maximum duration that Terraform should wait for ASG instances to be healthy before timing out. (See also Waiting for Capacity below.) Setting this to '0' causes Terraform to skip all Capacity Waiting behavior<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>"10m"</code>
>   </dd>
> </dl>
>



## Context Variables

The following variables are defined in the `context.tf` file of this module and part of the [terraform-null-label](https://registry.terraform.io/modules/cloudposse/label/null) pattern. These are identical in all Cloud Posse modules.

<details>
<summary>Click to expand</summary>


### `additional_tag_map` (`map(string)`) <i>optional</i>


Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br/>
This is for some rare cases where resources want additional configuration of tags<br/>
and therefore take a list of maps with tag key, value, and additional configuration.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>map(string)</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>{}</code>
>   </dd>
> </dl>
>


### `attributes` (`list(string)`) <i>optional</i>


ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br/>
in the order they appear in the list. New attributes are appended to the<br/>
end of the list. The elements of the list are joined by the `delimiter`<br/>
and treated as a single ID element.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>[]</code>
>   </dd>
> </dl>
>


### `context` (`any`) <i>optional</i>


Single object for setting entire context at once.<br/>
See description of individual variables for details.<br/>
Leave string and numeric variables as `null` to use default value.<br/>
Individual variable settings (non-null) override settings in context object,<br/>
except for attributes, tags, and additional_tag_map, which are merged.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>any</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   
>
>   ```hcl
>   {
>     "additional_tag_map": {},
>     "attributes": [],
>     "delimiter": null,
>     "descriptor_formats": {},
>     "enabled": true,
>     "environment": null,
>     "id_length_limit": null,
>     "label_key_case": null,
>     "label_order": [],
>     "label_value_case": null,
>     "labels_as_tags": [
>       "unset"
>     ],
>     "name": null,
>     "namespace": null,
>     "regex_replace_chars": null,
>     "stage": null,
>     "tags": {},
>     "tenant": null
>   }
>   ```
>
>   </dd>
> </dl>
>


### `delimiter` (`string`) <i>optional</i>


Delimiter to be used between ID elements.<br/>
Defaults to `-` (hyphen). Set to `""` to use no delimiter at all.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `descriptor_formats` (`any`) <i>optional</i>


Describe additional descriptors to be output in the `descriptors` output map.<br/>
Map of maps. Keys are names of descriptors. Values are maps of the form<br/>
`{<br/>
   format = string<br/>
   labels = list(string)<br/>
}`<br/>
(Type is `any` so the map values can later be enhanced to provide additional options.)<br/>
`format` is a Terraform format string to be passed to the `format()` function.<br/>
`labels` is a list of labels, in order, to pass to `format()` function.<br/>
Label values will be normalized before being passed to `format()` so they will be<br/>
identical to how they appear in `id`.<br/>
Default is `{}` (`descriptors` output will be empty).<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>any</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>{}</code>
>   </dd>
> </dl>
>


### `enabled` (`bool`) <i>optional</i>


Set to false to prevent the module from creating any resources<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `environment` (`string`) <i>optional</i>


ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT'<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `id_length_limit` (`number`) <i>optional</i>


Limit `id` to this many characters (minimum 6).<br/>
Set to `0` for unlimited length.<br/>
Set to `null` for keep the existing setting, which defaults to `0`.<br/>
Does not affect `id_full`.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>number</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `label_key_case` (`string`) <i>optional</i>


Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br/>
Does not affect keys of tags passed in via the `tags` input.<br/>
Possible values: `lower`, `title`, `upper`.<br/>
Default value: `title`.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `label_order` (`list(string)`) <i>optional</i>


The order in which the labels (ID elements) appear in the `id`.<br/>
Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br/>
You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `label_value_case` (`string`) <i>optional</i>


Controls the letter case of ID elements (labels) as included in `id`,<br/>
set as tag values, and output by this module individually.<br/>
Does not affect values of tags passed in via the `tags` input.<br/>
Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br/>
Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br/>
Default value: `lower`.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `labels_as_tags` (`set(string)`) <i>optional</i>


Set of labels (ID elements) to include as tags in the `tags` output.<br/>
Default is to include all labels.<br/>
Tags with empty values will not be included in the `tags` output.<br/>
Set to `[]` to suppress all generated tags.<br/>
**Notes:**<br/>
  The value of the `name` tag, if included, will be the `id`, not the `name`.<br/>
  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br/>
  changed in later chained modules. Attempts to change it will be silently ignored.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>set(string)</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   
>
>   ```hcl
>   [
>     "default"
>   ]
>   ```
>
>   </dd>
> </dl>
>


### `name` (`string`) <i>optional</i>


ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br/>
This is the only ID element not also included as a `tag`.<br/>
The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `namespace` (`string`) <i>optional</i>


ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `regex_replace_chars` (`string`) <i>optional</i>


Terraform regular expression (regex) string.<br/>
Characters matching the regex will be removed from the ID elements.<br/>
If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `stage` (`string`) <i>optional</i>


ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release'<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `tags` (`map(string)`) <i>optional</i>


Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br/>
Neither the tag keys nor the tag values will be modified by this module.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>map(string)</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>{}</code>
>   </dd>
> </dl>
>


### `tenant` (`string`) <i>optional</i>


ID element _(Rarely used, not included by default)_. A customer identifier, indicating who this instance of a resource is for<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>



</details>
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## FAQ

### Can we scope it to a github org with both private and public repos ?

Yes but this requires Github Enterprise Cloud and the usage of runner groups to scope permissions of runners to specific
repos. If you set the scope to the entire org without runner groups and if the org has both public and private repos,
then the risk of using a self-hosted runner incorrectly is a vulnerability within public repos.

[https://docs.github.com/en/actions/hosting-your-own-runners/managing-access-to-self-hosted-runners-using-groups](https://docs.github.com/en/actions/hosting-your-own-runners/managing-access-to-self-hosted-runners-using-groups)

If you do not have github enterprise cloud and runner groups cannot be utilized, then it’s best to create new github
runners per repo or use the summerwind action-runners-controller via a Github App to set the scope to specific repos.

### How can we see the current spot pricing?

Go to [ec2instances.info](http://ec2instances.info/)

### If we don’t use mixed at all does that mean we can’t do spot?

It’s possible to do spot without using mixed instances but you leave yourself open to zero instance availability with a
single instance type.

For example, if you wanted to use spot and use `t3.xlarge` in `us-east-2` and for some reason, AWS ran out of
`t3.xlarge`, you wouldn't have the option to choose another instance type and so all the GitHub Action runs would stall
until availability returned. If you use on-demand pricing, it’s more expensive, but you’re more likely to get scheduling
priority. For guaranteed availability, reserved instances are required.

### Do the overrides apply to both the on-demand and the spot instances, or only the spot instances?

Since the overrides affect the launch template, I believe they will affect both spot instances and override since
weighted capacity can be set for either or. The override terraform option is on the ASG’s `launch_template`

> List of nested arguments provides the ability to specify multiple instance types. This will override the same
> parameter in the launch template. For on-demand instances, Auto Scaling considers the order of preference of instance
> types to launch based on the order specified in the overrides list. Defined below. And in the terraform resource for
> `instances_distribution`

> `spot_max_price` - (Optional) Maximum price per unit hour that the user is willing to pay for the Spot instances.
> Default: an empty string which means the on-demand price. For a `mixed_instances_policy`, this will do purely
> on-demand

```
        mixed_instances_policy:
          instances_distribution:
            on_demand_allocation_strategy: "prioritized"
            on_demand_base_capacity: 1
            on_demand_percentage_above_base_capacity: 0
            spot_allocation_strategy: "capacity-optimized"
            spot_instance_pools: null
            spot_max_price: []
```

This will always do spot unless instances are unavailable, then switch to on-demand.

```
        mixed_instances_policy:
          instances_distribution:
            # ...
            spot_max_price: 0.05
```

If you want a single instance type, you could still use the mixed instances policy to define that like above, or you can
use these other inputs and comment out the `mixed_instances_policy`

```
        instance_type: "t3.xlarge"
        # the below is optional in order to set the spot max price
        instance_market_options:
          market_type = "spot"
          spot_options:
            block_duration_minutes: 6000
            instance_interruption_behavior: terminate
            max_price: 0.05
            spot_instance_type = persistent
            valid_until: null
```

The `overrides` will override the `instance_type` above.

## References

- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/github-runners) -
  Cloud Posse's upstream component
- [AWS: Auto Scaling groups with multiple instance types and purchase options](https://docs.aws.amazon.com/autoscaling/ec2/userguide/ec2-auto-scaling-mixed-instances-groups.html)
- [InstancesDistribution](https://docs.aws.amazon.com/autoscaling/ec2/APIReference/API_InstancesDistribution.html)

* [MixedInstancesPolicy](https://docs.aws.amazon.com/autoscaling/ec2/APIReference/API_MixedInstancesPolicy.html)
* [Terraform ASG `Override` Attribute](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group#override)

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
