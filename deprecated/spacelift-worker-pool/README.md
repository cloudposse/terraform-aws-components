# Component: `spacelift-worker-pool`

This component is responsible for provisioning Spacelift worker pools.

By default, workers are given pull access to the configured ECR,
permission to assume the `spacelift` team role in the identity account
(although you must also configure the `spacelift` team in the identity
account to allow the workers to assume the role via `trusted_role_arns`),
and have the following AWS managed IAM policies attached:

* AmazonSSMManagedInstanceCore
* AutoScalingReadOnlyAccess
* AWSXRayDaemonWriteAccess
* CloudWatchAgentServerPolicy

Among other things, this allows workers with SSM agent installed to
be accessed via SSM Session Manager.

```bash
aws ssm start-session --target <instance-id>
```

## Usage

**Stack Level**: Regional

Here's an example snippet for how to use this component.

```yaml
components:
  terraform:
    spacelift-worker-pool:
      settings:
        spacelift:
          workspace_enabled: true
      vars:
        enabled: true
        name: "spacelift-worker-pool"
        ec2_instance_type: m6i.large
        ecr_account_name: corp
        ecr_repo_name: infrastructure
        spacelift_api_endpoint: https://<GITHUBORG>.app.spacelift.io
```

## Configuration

### Docker Image on ECR

Build and tag a Docker image for this repository and push to ECR. Ensure the account where this component is deployed has read-only access to the ECR repository.

### API Key

Prior to deployment, the API key must exist in SSM. The key must have admin permissions.

To generate the key, please follow [these instructions](https://docs.spacelift.io/integrations/api.html#spacelift-api-key-token). Once generated, write the API key ID and secret to the SSM key store at the following locations within the same AWS account and region where the Spacelift worker pool will reside.

| Key      | SSM Path                | Type           |
| -------- | ----------------------- | -------------- |
| API ID   | `/spacelift/key_id`     | `SecureString` |
| API Key  | `/spacelift/key_secret` | `SecureString` |

_HINT_: The API key ID is displayed as an upper-case, 16-character alphanumeric value next to the key name in the API key list.

Save the keys using `chamber` using the correct profile for where spacelift worker pool is provisioned

```
AWS_PROFILE=acme-gbl-auto-admin chamber write spacelift key_id 1234567890123456
AWS_PROFILE=acme-gbl-auto-admin chamber write spacelift key_secret abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz
```

### IAM configuration

After provisioning the component, you must give the created instance role permission
to assume the Spacelift worker role. This is done by adding `iam_role_arn` from
the output to the `trusted_role_arns` list for the `spacelift` role in `aws-teams`.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->



## Version Requirements

| Requirement | Version |
| --- | --- |
| `terraform` | >= 1.0.0 |
| `aws` | >= 4.9.0 |
| `cloudinit` | >= 2.2.0 |
| `spacelift` | >= 0.1.2 |


## Providers

| Provider | Version |
| --- | --- |
| `aws` | >= 4.9.0 |
| `cloudinit` | >= 2.2.0 |
| `spacelift` | >= 0.1.2 |


## Modules

Name | Version | Source | Description
--- | --- | --- | ---
`account_map` | 1.4.1 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.4.1) | n/a
`autoscale_group` | 0.34.1 | [`cloudposse/ec2-autoscale-group/aws`](https://registry.terraform.io/modules/cloudposse/ec2-autoscale-group/aws/0.34.1) | n/a
`ecr` | 1.4.1 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.4.1) | n/a
`iam_label` | 0.25.0 | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | n/a
`iam_roles` | latest | [`../account-map/modules/iam-roles`](https://registry.terraform.io/modules/../account-map/modules/iam-roles/) | n/a
`security_group` | 2.0.0-rc1 | [`cloudposse/security-group/aws`](https://registry.terraform.io/modules/cloudposse/security-group/aws/2.0.0-rc1) | n/a
`this` | 0.25.0 | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | n/a
`vpc` | 1.4.1 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.4.1) | n/a


## Resources

The following resources are used by this module:

  - [`aws_iam_instance_profile.default`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) (resource)(iam.tf#80)
  - [`aws_iam_policy.default`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) (resource)(iam.tf#55)
  - [`aws_iam_role.default`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) (resource)(iam.tf#64)
  - [`spacelift_worker_pool.primary`](https://registry.terraform.io/providers/spacelift-io/spacelift/latest/docs/resources/worker_pool) (resource)(main.tf#31)

## Data Sources

The following data sources are used by this module:

  - [`aws_ami.spacelift`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) (data source)
  - [`aws_iam_policy_document.assume_role_policy`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) (data source)
  - [`aws_iam_policy_document.default`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) (data source)
  - [`aws_partition.current`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) (data source)
  - [`aws_ssm_parameter.spacelift_key_id`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) (data source)
  - [`aws_ssm_parameter.spacelift_key_secret`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) (data source)
  - [`cloudinit_config.config`](https://registry.terraform.io/providers/hashicorp/cloudinit/latest/docs/data-sources/config) (data source)

## Outputs

<dl>
  <dt><code>autoscaling_group_arn</code></dt>
  <dd>
    The ARN for this AutoScaling Group<br/>

  </dd>
  <dt><code>autoscaling_group_default_cooldown</code></dt>
  <dd>
    Time between a scaling activity and the succeeding scaling activity<br/>

  </dd>
  <dt><code>autoscaling_group_health_check_grace_period</code></dt>
  <dd>
    Time after instance comes into service before checking health<br/>

  </dd>
  <dt><code>autoscaling_group_health_check_type</code></dt>
  <dd>
    `EC2` or `ELB`. Controls how health checking is done<br/>

  </dd>
  <dt><code>autoscaling_group_id</code></dt>
  <dd>
    The autoscaling group id<br/>

  </dd>
  <dt><code>autoscaling_group_max_size</code></dt>
  <dd>
    The maximum size of the autoscale group<br/>

  </dd>
  <dt><code>autoscaling_group_min_size</code></dt>
  <dd>
    The minimum size of the autoscale group<br/>

  </dd>
  <dt><code>autoscaling_group_name</code></dt>
  <dd>
    The autoscaling group name<br/>

  </dd>
  <dt><code>iam_role_arn</code></dt>
  <dd>
    Spacelift IAM Role ARN<br/>

  </dd>
  <dt><code>iam_role_id</code></dt>
  <dd>
    Spacelift IAM Role ID<br/>

  </dd>
  <dt><code>iam_role_name</code></dt>
  <dd>
    Spacelift IAM Role name<br/>

  </dd>
  <dt><code>launch_template_arn</code></dt>
  <dd>
    The ARN of the launch template<br/>

  </dd>
  <dt><code>launch_template_id</code></dt>
  <dd>
    The ID of the launch template<br/>

  </dd>
  <dt><code>security_group_arn</code></dt>
  <dd>
    Spacelift Security Group ARN<br/>

  </dd>
  <dt><code>security_group_id</code></dt>
  <dd>
    Spacelift Security Group ID<br/>

  </dd>
  <dt><code>security_group_name</code></dt>
  <dd>
    Spacelift Security Group Name<br/>

  </dd>
  <dt><code>worker_pool_id</code></dt>
  <dd>
    Spacelift worker pool ID<br/>

  </dd>
  <dt><code>worker_pool_name</code></dt>
  <dd>
    Spacelift worker pool name<br/>

  </dd>
</dl>

## Required Variables

Required variables are the minimum set of variables that must be set to use this module.

> [!IMPORTANT]
>
> To customize the names and tags of the resources created by this module, see the [context variables](#context-variables).
>
### `cpu_utilization_high_threshold_percent` (`number`) <i>required</i>


CPU utilization high threshold<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>Yes</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>number</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code></code>
>   </dd>
> </dl>
>


### `cpu_utilization_low_threshold_percent` (`number`) <i>required</i>


CPU utilization low threshold<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>Yes</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>number</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code></code>
>   </dd>
> </dl>
>


### `ecr_repo_name` (`string`) <i>required</i>


ECR repository name<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>Yes</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code></code>
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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code></code>
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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code></code>
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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code></code>
>   </dd>
> </dl>
>


### `spacelift_api_endpoint` (`string`) <i>required</i>


The Spacelift API endpoint URL (e.g. https://example.app.spacelift.io)<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>Yes</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code></code>
>   </dd>
> </dl>
>


### `wait_for_capacity_timeout` (`string`) <i>required</i>


A maximum duration that Terraform should wait for ASG instances to be healthy before timing out. (See also Waiting for Capacity below.) Setting this to '0' causes Terraform to skip all Capacity Waiting behavior<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>Yes</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code></code>
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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>"gbl"</code>
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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>"root"</code>
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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `aws_config_file` (`string`) <i>optional</i>


The AWS_CONFIG_FILE used by the worker. Can be overridden by `/.spacelift/config.yml`.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>"/etc/aws-config/aws-config-spacelift"</code>
>   </dd>
> </dl>
>


### `aws_profile` (`string`) <i>optional</i>


The AWS_PROFILE used by the worker. If not specified, `"${var.namespace}-identity"` will be used.<br/>
Can be overridden by `/.spacelift/config.yml`.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>[]</code>
>   </dd>
> </dl>
>


### `custom_spacelift_ami` (`bool`) <i>optional</i>


Custom spacelift AMI<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>false</code>
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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>300</code>
>   </dd>
> </dl>
>


### `desired_capacity` (`number`) <i>optional</i>


The number of Amazon EC2 instances that should be running in the group, if not set will use `min_size` as value<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>number</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `ebs_optimized` (`bool`) <i>optional</i>


If true, the launched EC2 instance will be EBS-optimized<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>false</code>
>   </dd>
> </dl>
>


### `ecr_environment_name` (`string`) <i>optional</i>


The name of the environment where `ecr` is provisioned<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>""</code>
>   </dd>
> </dl>
>


### `ecr_region` (`string`) <i>optional</i>


AWS region that contains the ECR infrastructure repo<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>""</code>
>   </dd>
> </dl>
>


### `ecr_stage_name` (`string`) <i>optional</i>


The name of the stage where `ecr` is provisioned<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>"artifacts"</code>
>   </dd>
> </dl>
>


### `ecr_tenant_name` (`string`) <i>optional</i>


The name of the tenant where `ecr` is provisioned.<br/>
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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `github_netrc_enabled` (`bool`) <i>optional</i>


Whether to create a GitHub .netrc file so Spacelift can clone private GitHub repositories.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>false</code>
>   </dd>
> </dl>
>


### `github_netrc_ssm_path_token` (`string`) <i>optional</i>


If `github_netrc` is enabled, this is the SSM path to retrieve the GitHub token.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>"/github/token"</code>
>   </dd>
> </dl>
>


### `github_netrc_ssm_path_user` (`string`) <i>optional</i>


If `github_netrc` is enabled, this is the SSM path to retrieve the GitHub user<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>"/github/user"</code>
>   </dd>
> </dl>
>


### `health_check_grace_period` (`number`) <i>optional</i>


Time (in seconds) after instance comes into service before checking health<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>number</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>300</code>
>   </dd>
> </dl>
>


### `health_check_type` (`string`) <i>optional</i>


Controls how health checking is done. Valid values are `EC2` or `ELB`<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>"EC2"</code>
>   </dd>
> </dl>
>


### `iam_attributes` (`list(string)`) <i>optional</i>


Additional attributes to add to the IDs of the IAM role and policy<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>[]</code>
>   </dd>
> </dl>
>


### `import_profile_name` (`string`) <i>optional</i>


AWS Profile name to use when importing a resource<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `import_role_arn` (`string`) <i>optional</i>


IAM Role ARN to use when importing a resource<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `infracost_api_token_ssm_path` (`string`) <i>optional</i>


This is the SSM path to retrieve and set the INFRACOST_API_TOKEN environment variable<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>"/infracost/token"</code>
>   </dd>
> </dl>
>


### `infracost_cli_args` (`string`) <i>optional</i>


These are the CLI args passed to infracost<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>""</code>
>   </dd>
> </dl>
>


### `infracost_enabled` (`bool`) <i>optional</i>


Whether to enable infracost for Spacelift stacks<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>false</code>
>   </dd>
> </dl>
>


### `infracost_warn_on_failure` (`bool`) <i>optional</i>


A failure executing Infracost, or a non-zero exit code being returned from the command will cause runs to fail. If this is true, this will only warn instead of failing the stack.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>true</code>
>   </dd>
> </dl>
>


### `instance_refresh` <i>optional</i>


The instance refresh definition. If this block is configured, an Instance Refresh will be started when the Auto Scaling Group is updated<br/>

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
    strategy = string
    preferences = object({
      instance_warmup        = number
      min_healthy_percentage = number
    })
    triggers = list(string)
  })
>   ```
>
>   
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `instance_type` (`string`) <i>optional</i>


EC2 instance type to use for workers<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>"r5n.large"</code>
>   </dd>
> </dl>
>


### `mixed_instances_policy` <i>optional</i>


Policy to use a mixed group of on-demand/spot of different types. Launch template is automatically generated. https://www.terraform.io/docs/providers/aws/r/autoscaling_group.html#mixed_instances_policy-1<br/>

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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>300</code>
>   </dd>
> </dl>
>


### `spacelift_agents_per_node` (`number`) <i>optional</i>


Number of Spacelift agents to run on one worker node<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>number</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>1</code>
>   </dd>
> </dl>
>


### `spacelift_ami_id` (`string`) <i>optional</i>


AMI ID of Spacelift worker pool image<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `spacelift_aws_account_id` (`string`) <i>optional</i>


AWS Account ID owned by Spacelift<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>"643313122712"</code>
>   </dd>
> </dl>
>


### `spacelift_domain_name` (`string`) <i>optional</i>


Top-level domain name to use for pulling the launcher binary<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>"spacelift.io"</code>
>   </dd>
> </dl>
>


### `spacelift_runner_image` (`string`) <i>optional</i>


URL of ECR image to use for Spacelift<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>""</code>
>   </dd>
> </dl>
>


### `termination_policies` (`list(string)`) <i>optional</i>


A list of policies to decide how the instances in the auto scale group should be terminated. The allowed values are `OldestInstance`, `NewestInstance`, `OldestLaunchConfiguration`, `ClosestToNextInstanceHour`, `Default`<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    
>
>    ```hcl
>>
>    [
>
>      "OldestLaunchConfiguration"
>
>    ]
>
>    ```
>
>    
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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>{}</code>
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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>[]</code>
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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    
>
>    ```hcl
>>
>    {
>
>      "additional_tag_map": {},
>
>      "attributes": [],
>
>      "delimiter": null,
>
>      "descriptor_formats": {},
>
>      "enabled": true,
>
>      "environment": null,
>
>      "id_length_limit": null,
>
>      "label_key_case": null,
>
>      "label_order": [],
>
>      "label_value_case": null,
>
>      "labels_as_tags": [
>
>        "unset"
>
>      ],
>
>      "name": null,
>
>      "namespace": null,
>
>      "regex_replace_chars": null,
>
>      "stage": null,
>
>      "tags": {},
>
>      "tenant": null
>
>    }
>
>    ```
>
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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>{}</code>
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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    
>
>    ```hcl
>>
>    [
>
>      "default"
>
>    ]
>
>    ```
>
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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>{}</code>
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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>



</details>
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## References

- [cloudposse/terraform-spacelift-cloud-infrastructure-automation](https://github.com/cloudposse/terraform-spacelift-cloud-infrastructure-automation) - Cloud Posse's related upstream component
- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/master/modules/spacelift-worker-pool) - Cloud Posse's upstream component

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
