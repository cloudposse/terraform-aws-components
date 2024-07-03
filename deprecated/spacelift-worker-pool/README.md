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


## Reference

### Version Requirements

- [`terraform`](https://registry.terraform.io/modules/terraform/>= 1.0.0), version: >= 1.0.0
- [`aws`](https://registry.terraform.io/modules/aws/>= 4.9.0), version: >= 4.9.0
- [`cloudinit`](https://registry.terraform.io/modules/cloudinit/>= 2.2.0), version: >= 2.2.0
- [`spacelift`](https://registry.terraform.io/modules/spacelift/>= 0.1.2), version: >= 0.1.2

https://registry.terraform.io/modules/cloudposse/stack-config/yaml//remote-state

### Providers

- `aws`, version: >= 4.9.0
- `cloudinit`, version: >= 2.2.0
- `spacelift`, version: >= 0.1.2

### Modules

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


### Resources

The following resources are used by this module:

  - [`aws_iam_instance_profile.default`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) (resource)
  - [`aws_iam_policy.default`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) (resource)
  - [`aws_iam_role.default`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) (resource)
  - [`spacelift_worker_pool.primary`](https://registry.terraform.io/providers/spacelift-io/spacelift/latest/docs/resources/worker_pool) (resource)

### Data Sources

The following data sources are used by this module:

  - [`aws_ami.spacelift`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) (data source)
  - [`aws_iam_policy_document.assume_role_policy`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) (data source)
  - [`aws_iam_policy_document.default`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) (data source)
  - [`aws_partition.current`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) (data source)
  - [`aws_ssm_parameter.spacelift_key_id`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) (data source)
  - [`aws_ssm_parameter.spacelift_key_secret`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) (data source)
  - [`cloudinit_config.config`](https://registry.terraform.io/providers/hashicorp/cloudinit/latest/docs/data-sources/config) (data source)

### Context Variables

The following variables are defined in the `context.tf` file of this module and part of the [terraform-null-label](https://registry.terraform.io/modules/cloudposse/label/null) pattern.

<dl>
  <dt>`additional_tag_map` (`map(string)`) <i>optional</i></dt>
  <dd>
    Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br/>
    This is for some rare cases where resources want additional configuration of tags<br/>
    and therefore take a list of maps with tag key, value, and additional configuration.<br/>
    <br/>
    **Required:** No<br/>
    **Type:** `map(string)`
    **Default value:** `{}`
  </dd>
  <dt>`attributes` (`list(string)`) <i>optional</i></dt>
  <dd>
    ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br/>
    in the order they appear in the list. New attributes are appended to the<br/>
    end of the list. The elements of the list are joined by the `delimiter`<br/>
    and treated as a single ID element.<br/>
    <br/>
    **Required:** No<br/>
    **Type:** `list(string)`
    **Default value:** `[]`
  </dd>
  <dt>`context` (`any`) <i>optional</i></dt>
  <dd>
    Single object for setting entire context at once.<br/>
    See description of individual variables for details.<br/>
    Leave string and numeric variables as `null` to use default value.<br/>
    Individual variable settings (non-null) override settings in context object,<br/>
    except for attributes, tags, and additional_tag_map, which are merged.<br/>
    <br/>
    **Required:** No<br/>
    **Type:** `any`
    **Default value:** 
    ```hcl
    {
      "additional_tag_map": {},
      "attributes": [],
      "delimiter": null,
      "descriptor_formats": {},
      "enabled": true,
      "environment": null,
      "id_length_limit": null,
      "label_key_case": null,
      "label_order": [],
      "label_value_case": null,
      "labels_as_tags": [
        "unset"
      ],
      "name": null,
      "namespace": null,
      "regex_replace_chars": null,
      "stage": null,
      "tags": {},
      "tenant": null
    }
    ```
    
  </dd>
  <dt>`delimiter` (`string`) <i>optional</i></dt>
  <dd>
    Delimiter to be used between ID elements.<br/>
    Defaults to `-` (hyphen). Set to `""` to use no delimiter at all.<br/>
    <br/>
    **Required:** No<br/>
    **Type:** `string`
    **Default value:** `null`
  </dd>
  <dt>`descriptor_formats` (`any`) <i>optional</i></dt>
  <dd>
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
    **Required:** No<br/>
    **Type:** `any`
    **Default value:** `{}`
  </dd>
  <dt>`enabled` (`bool`) <i>optional</i></dt>
  <dd>
    Set to false to prevent the module from creating any resources<br/>
    **Required:** No<br/>
    **Type:** `bool`
    **Default value:** `null`
  </dd>
  <dt>`environment` (`string`) <i>optional</i></dt>
  <dd>
    ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT'<br/>
    **Required:** No<br/>
    **Type:** `string`
    **Default value:** `null`
  </dd>
  <dt>`id_length_limit` (`number`) <i>optional</i></dt>
  <dd>
    Limit `id` to this many characters (minimum 6).<br/>
    Set to `0` for unlimited length.<br/>
    Set to `null` for keep the existing setting, which defaults to `0`.<br/>
    Does not affect `id_full`.<br/>
    <br/>
    **Required:** No<br/>
    **Type:** `number`
    **Default value:** `null`
  </dd>
  <dt>`label_key_case` (`string`) <i>optional</i></dt>
  <dd>
    Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br/>
    Does not affect keys of tags passed in via the `tags` input.<br/>
    Possible values: `lower`, `title`, `upper`.<br/>
    Default value: `title`.<br/>
    <br/>
    **Required:** No<br/>
    **Type:** `string`
    **Default value:** `null`
  </dd>
  <dt>`label_order` (`list(string)`) <i>optional</i></dt>
  <dd>
    The order in which the labels (ID elements) appear in the `id`.<br/>
    Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br/>
    You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present.<br/>
    <br/>
    **Required:** No<br/>
    **Type:** `list(string)`
    **Default value:** `null`
  </dd>
  <dt>`label_value_case` (`string`) <i>optional</i></dt>
  <dd>
    Controls the letter case of ID elements (labels) as included in `id`,<br/>
    set as tag values, and output by this module individually.<br/>
    Does not affect values of tags passed in via the `tags` input.<br/>
    Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br/>
    Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br/>
    Default value: `lower`.<br/>
    <br/>
    **Required:** No<br/>
    **Type:** `string`
    **Default value:** `null`
  </dd>
  <dt>`labels_as_tags` (`set(string)`) <i>optional</i></dt>
  <dd>
    Set of labels (ID elements) to include as tags in the `tags` output.<br/>
    Default is to include all labels.<br/>
    Tags with empty values will not be included in the `tags` output.<br/>
    Set to `[]` to suppress all generated tags.<br/>
    **Notes:**<br/>
      The value of the `name` tag, if included, will be the `id`, not the `name`.<br/>
      Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br/>
      changed in later chained modules. Attempts to change it will be silently ignored.<br/>
    <br/>
    **Required:** No<br/>
    **Type:** `set(string)`
    **Default value:** 
    ```hcl
    [
      "default"
    ]
    ```
    
  </dd>
  <dt>`name` (`string`) <i>optional</i></dt>
  <dd>
    ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br/>
    This is the only ID element not also included as a `tag`.<br/>
    The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input.<br/>
    <br/>
    **Required:** No<br/>
    **Type:** `string`
    **Default value:** `null`
  </dd>
  <dt>`namespace` (`string`) <i>optional</i></dt>
  <dd>
    ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique<br/>
    **Required:** No<br/>
    **Type:** `string`
    **Default value:** `null`
  </dd>
  <dt>`regex_replace_chars` (`string`) <i>optional</i></dt>
  <dd>
    Terraform regular expression (regex) string.<br/>
    Characters matching the regex will be removed from the ID elements.<br/>
    If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits.<br/>
    <br/>
    **Required:** No<br/>
    **Type:** `string`
    **Default value:** `null`
  </dd>
  <dt>`stage` (`string`) <i>optional</i></dt>
  <dd>
    ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release'<br/>
    **Required:** No<br/>
    **Type:** `string`
    **Default value:** `null`
  </dd>
  <dt>`tags` (`map(string)`) <i>optional</i></dt>
  <dd>
    Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br/>
    Neither the tag keys nor the tag values will be modified by this module.<br/>
    <br/>
    **Required:** No<br/>
    **Type:** `map(string)`
    **Default value:** `{}`
  </dd>
  <dt>`tenant` (`string`) <i>optional</i></dt>
  <dd>
    ID element _(Rarely used, not included by default)_. A customer identifier, indicating who this instance of a resource is for<br/>
    **Required:** No<br/>
    **Type:** `string`
    **Default value:** `null`
  </dd>
</dl>

### Required Inputs

<dl>
  <dt>`cpu_utilization_high_threshold_percent` (`number`) <i>required</i></dt>
  <dd>
    CPU utilization high threshold<br/>

    **Type:** `number`
    <br/>
    **Default value:** ``

  </dd>
  <dt>`cpu_utilization_low_threshold_percent` (`number`) <i>required</i></dt>
  <dd>
    CPU utilization low threshold<br/>

    **Type:** `number`
    <br/>
    **Default value:** ``

  </dd>
  <dt>`ecr_repo_name` (`string`) <i>required</i></dt>
  <dd>
    ECR repository name<br/>

    **Type:** `string`
    <br/>
    **Default value:** ``

  </dd>
  <dt>`max_size` (`number`) <i>required</i></dt>
  <dd>
    The maximum size of the autoscale group<br/>

    **Type:** `number`
    <br/>
    **Default value:** ``

  </dd>
  <dt>`min_size` (`number`) <i>required</i></dt>
  <dd>
    The minimum size of the autoscale group<br/>

    **Type:** `number`
    <br/>
    **Default value:** ``

  </dd>
  <dt>`region` (`string`) <i>required</i></dt>
  <dd>
    AWS Region<br/>

    **Type:** `string`
    <br/>
    **Default value:** ``

  </dd>
  <dt>`spacelift_api_endpoint` (`string`) <i>required</i></dt>
  <dd>
    The Spacelift API endpoint URL (e.g. https://example.app.spacelift.io)<br/>

    **Type:** `string`
    <br/>
    **Default value:** ``

  </dd>
  <dt>`wait_for_capacity_timeout` (`string`) <i>required</i></dt>
  <dd>
    A maximum duration that Terraform should wait for ASG instances to be healthy before timing out. (See also Waiting for Capacity below.) Setting this to '0' causes Terraform to skip all Capacity Waiting behavior<br/>

    **Type:** `string`
    <br/>
    **Default value:** ``

  </dd>
</dl>

### Optional Inputs

<dl>
  <dt>`account_map_environment_name` (`string`) <i>optional</i></dt>
  <dd>
    The name of the environment where `account_map` is provisioned<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"gbl"`
  </dd>
  <dt>`account_map_stage_name` (`string`) <i>optional</i></dt>
  <dd>
    The name of the stage where `account_map` is provisioned<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"root"`
  </dd>
  <dt>`account_map_tenant_name` (`string`) <i>optional</i></dt>
  <dd>
    The name of the tenant where `account_map` is provisioned.<br/>
    <br/>
    If the `tenant` label is not used, leave this as `null`.<br/>
    <br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`aws_config_file` (`string`) <i>optional</i></dt>
  <dd>
    The AWS_CONFIG_FILE used by the worker. Can be overridden by `/.spacelift/config.yml`.<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"/etc/aws-config/aws-config-spacelift"`
  </dd>
  <dt>`aws_profile` (`string`) <i>optional</i></dt>
  <dd>
    The AWS_PROFILE used by the worker. If not specified, `"${var.namespace}-identity"` will be used.<br/>
    Can be overridden by `/.spacelift/config.yml`.<br/>
    <br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`block_device_mappings` <i>optional</i></dt>
  <dd>
    Specify volumes to attach to the instance besides the volumes specified by the AMI<br/>
    <br/>
    **Type:** 

    ```hcl
    list(object({
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
    ```
    
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`custom_spacelift_ami` (`bool`) <i>optional</i></dt>
  <dd>
    Custom spacelift AMI<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`default_cooldown` (`number`) <i>optional</i></dt>
  <dd>
    The amount of time, in seconds, after a scaling activity completes before another scaling activity can start<br/>
    <br/>
    **Type:** `number`
    <br/>
    **Default value:** `300`
  </dd>
  <dt>`desired_capacity` (`number`) <i>optional</i></dt>
  <dd>
    The number of Amazon EC2 instances that should be running in the group, if not set will use `min_size` as value<br/>
    <br/>
    **Type:** `number`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`ebs_optimized` (`bool`) <i>optional</i></dt>
  <dd>
    If true, the launched EC2 instance will be EBS-optimized<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`ecr_environment_name` (`string`) <i>optional</i></dt>
  <dd>
    The name of the environment where `ecr` is provisioned<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `""`
  </dd>
  <dt>`ecr_region` (`string`) <i>optional</i></dt>
  <dd>
    AWS region that contains the ECR infrastructure repo<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `""`
  </dd>
  <dt>`ecr_stage_name` (`string`) <i>optional</i></dt>
  <dd>
    The name of the stage where `ecr` is provisioned<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"artifacts"`
  </dd>
  <dt>`ecr_tenant_name` (`string`) <i>optional</i></dt>
  <dd>
    The name of the tenant where `ecr` is provisioned.<br/>
    <br/>
    If the `tenant` label is not used, leave this as `null`.<br/>
    <br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`github_netrc_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    Whether to create a GitHub .netrc file so Spacelift can clone private GitHub repositories.<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`github_netrc_ssm_path_token` (`string`) <i>optional</i></dt>
  <dd>
    If `github_netrc` is enabled, this is the SSM path to retrieve the GitHub token.<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"/github/token"`
  </dd>
  <dt>`github_netrc_ssm_path_user` (`string`) <i>optional</i></dt>
  <dd>
    If `github_netrc` is enabled, this is the SSM path to retrieve the GitHub user<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"/github/user"`
  </dd>
  <dt>`health_check_grace_period` (`number`) <i>optional</i></dt>
  <dd>
    Time (in seconds) after instance comes into service before checking health<br/>
    <br/>
    **Type:** `number`
    <br/>
    **Default value:** `300`
  </dd>
  <dt>`health_check_type` (`string`) <i>optional</i></dt>
  <dd>
    Controls how health checking is done. Valid values are `EC2` or `ELB`<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"EC2"`
  </dd>
  <dt>`iam_attributes` (`list(string)`) <i>optional</i></dt>
  <dd>
    Additional attributes to add to the IDs of the IAM role and policy<br/>
    <br/>
    **Type:** `list(string)`
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`import_profile_name` (`string`) <i>optional</i></dt>
  <dd>
    AWS Profile name to use when importing a resource<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`import_role_arn` (`string`) <i>optional</i></dt>
  <dd>
    IAM Role ARN to use when importing a resource<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`infracost_api_token_ssm_path` (`string`) <i>optional</i></dt>
  <dd>
    This is the SSM path to retrieve and set the INFRACOST_API_TOKEN environment variable<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"/infracost/token"`
  </dd>
  <dt>`infracost_cli_args` (`string`) <i>optional</i></dt>
  <dd>
    These are the CLI args passed to infracost<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `""`
  </dd>
  <dt>`infracost_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    Whether to enable infracost for Spacelift stacks<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`infracost_warn_on_failure` (`bool`) <i>optional</i></dt>
  <dd>
    A failure executing Infracost, or a non-zero exit code being returned from the command will cause runs to fail. If this is true, this will only warn instead of failing the stack.<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `true`
  </dd>
  <dt>`instance_refresh` <i>optional</i></dt>
  <dd>
    The instance refresh definition. If this block is configured, an Instance Refresh will be started when the Auto Scaling Group is updated<br/>
    <br/>
    **Type:** 

    ```hcl
    object({
    strategy = string
    preferences = object({
      instance_warmup        = number
      min_healthy_percentage = number
    })
    triggers = list(string)
  })
    ```
    
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`instance_type` (`string`) <i>optional</i></dt>
  <dd>
    EC2 instance type to use for workers<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"r5n.large"`
  </dd>
  <dt>`mixed_instances_policy` <i>optional</i></dt>
  <dd>
    Policy to use a mixed group of on-demand/spot of different types. Launch template is automatically generated. https://www.terraform.io/docs/providers/aws/r/autoscaling_group.html#mixed_instances_policy-1<br/>
    <br/>
    **Type:** 

    ```hcl
    object({
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
    ```
    
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`scale_down_cooldown_seconds` (`number`) <i>optional</i></dt>
  <dd>
    The amount of time, in seconds, after a scaling activity completes and before the next scaling activity can start<br/>
    <br/>
    **Type:** `number`
    <br/>
    **Default value:** `300`
  </dd>
  <dt>`spacelift_agents_per_node` (`number`) <i>optional</i></dt>
  <dd>
    Number of Spacelift agents to run on one worker node<br/>
    <br/>
    **Type:** `number`
    <br/>
    **Default value:** `1`
  </dd>
  <dt>`spacelift_ami_id` (`string`) <i>optional</i></dt>
  <dd>
    AMI ID of Spacelift worker pool image<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`spacelift_aws_account_id` (`string`) <i>optional</i></dt>
  <dd>
    AWS Account ID owned by Spacelift<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"643313122712"`
  </dd>
  <dt>`spacelift_domain_name` (`string`) <i>optional</i></dt>
  <dd>
    Top-level domain name to use for pulling the launcher binary<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"spacelift.io"`
  </dd>
  <dt>`spacelift_runner_image` (`string`) <i>optional</i></dt>
  <dd>
    URL of ECR image to use for Spacelift<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `""`
  </dd>
  <dt>`termination_policies` (`list(string)`) <i>optional</i></dt>
  <dd>
    A list of policies to decide how the instances in the auto scale group should be terminated. The allowed values are `OldestInstance`, `NewestInstance`, `OldestLaunchConfiguration`, `ClosestToNextInstanceHour`, `Default`<br/>
    <br/>
    **Type:** `list(string)`
    <br/>
    **Default value:** 
    ```hcl
    [
      "OldestLaunchConfiguration"
    ]
    ```
    
  </dd></dl>


### Outputs

<dl>
  <dt>`autoscaling_group_arn`</dt>
  <dd>
    The ARN for this AutoScaling Group<br/>
  </dd>
  <dt>`autoscaling_group_default_cooldown`</dt>
  <dd>
    Time between a scaling activity and the succeeding scaling activity<br/>
  </dd>
  <dt>`autoscaling_group_health_check_grace_period`</dt>
  <dd>
    Time after instance comes into service before checking health<br/>
  </dd>
  <dt>`autoscaling_group_health_check_type`</dt>
  <dd>
    `EC2` or `ELB`. Controls how health checking is done<br/>
  </dd>
  <dt>`autoscaling_group_id`</dt>
  <dd>
    The autoscaling group id<br/>
  </dd>
  <dt>`autoscaling_group_max_size`</dt>
  <dd>
    The maximum size of the autoscale group<br/>
  </dd>
  <dt>`autoscaling_group_min_size`</dt>
  <dd>
    The minimum size of the autoscale group<br/>
  </dd>
  <dt>`autoscaling_group_name`</dt>
  <dd>
    The autoscaling group name<br/>
  </dd>
  <dt>`iam_role_arn`</dt>
  <dd>
    Spacelift IAM Role ARN<br/>
  </dd>
  <dt>`iam_role_id`</dt>
  <dd>
    Spacelift IAM Role ID<br/>
  </dd>
  <dt>`iam_role_name`</dt>
  <dd>
    Spacelift IAM Role name<br/>
  </dd>
  <dt>`launch_template_arn`</dt>
  <dd>
    The ARN of the launch template<br/>
  </dd>
  <dt>`launch_template_id`</dt>
  <dd>
    The ID of the launch template<br/>
  </dd>
  <dt>`security_group_arn`</dt>
  <dd>
    Spacelift Security Group ARN<br/>
  </dd>
  <dt>`security_group_id`</dt>
  <dd>
    Spacelift Security Group ID<br/>
  </dd>
  <dt>`security_group_name`</dt>
  <dd>
    Spacelift Security Group Name<br/>
  </dd>
  <dt>`worker_pool_id`</dt>
  <dd>
    Spacelift worker pool ID<br/>
  </dd>
  <dt>`worker_pool_name`</dt>
  <dd>
    Spacelift worker pool name<br/>
  </dd>
</dl>
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## References

- [cloudposse/terraform-spacelift-cloud-infrastructure-automation](https://github.com/cloudposse/terraform-spacelift-cloud-infrastructure-automation) - Cloud Posse's related upstream component
- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/master/modules/spacelift-worker-pool) - Cloud Posse's upstream component

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
