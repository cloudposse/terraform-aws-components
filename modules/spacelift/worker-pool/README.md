---
tags:
  - component/spacelift/worker-pool
  - layer/spacelift
  - provider/aws
  - provider/spacelift
---

# Component: `spacelift/worker-pool`

This component is responsible for provisioning Spacelift worker pools.

By default, workers are given pull access to the configured ECR, permission to assume the `spacelift` team role in the
identity account (although you must also configure the `spacelift` team in the identity account to allow the workers to
assume the role via `trusted_role_arns`), and have the following AWS managed IAM policies attached:

- AmazonSSMManagedInstanceCore
- AutoScalingReadOnlyAccess
- AWSXRayDaemonWriteAccess
- CloudWatchAgentServerPolicy

Among other things, this allows workers with SSM agent installed to be accessed via SSM Session Manager.

```bash
aws ssm start-session --target <instance-id>
```

## Usage

**Stack Level**: Regional

Here's an example snippet for how to use this component.

```yaml
# stacks/catalog/spacelift/worker-pool.yaml
components:
  terraform:
    spacelift/worker-pool:
      settings:
        spacelift:
          administrative: true
          space_name: root
      vars:
        enabled: true
        spacelift_api_endpoint: https://<GITHUBORG>.app.spacelift.io
        spacelift_spaces_tenant_name: "acme"
        spacelift_spaces_environment_name: "gbl"
        spacelift_spaces_stage_name: "root"
        account_map_tenant_name: core
        ecr_environment_name: ue1
        ecr_repo_name: infrastructure
        ecr_stage_name: artifacts
        ecr_tenant_name: core
        # Set a low scaling threshold to ensure new workers are launched as soon as the current one(s) are busy
        cpu_utilization_high_threshold_percent: 10
        cpu_utilization_low_threshold_percent: 5
        default_cooldown: 300
        desired_capacity: null
        health_check_grace_period: 300
        health_check_type: EC2
        infracost_enabled: true
        instance_type: t3.small
        max_size: 3
        min_size: 1
        name: spacelift-worker-pool
        scale_down_cooldown_seconds: 2700
        spacelift_agents_per_node: 1
        wait_for_capacity_timeout: 5m
        block_device_mappings:
          - device_name: "/dev/xvda"
            no_device: null
            virtual_name: null
            ebs:
              delete_on_termination: null
              encrypted: false
              iops: null
              kms_key_id: null
              snapshot_id: null
              volume_size: 100
              volume_type: "gp2"
```

### Impacts on billing

While scaling the workload for Spacelift, keep in mind that each agent connection counts against your quota of
self-hosted workers. The number of EC2 instances you have running is _not_ going to affect your Spacelift bill. As an
example, if you had 3 EC2 instances in your Spacelift worker pool, and you configured `spacelift_agents_per_node` to be
`3`, you would see your Spacelift bill report 9 agents being run. Take care while configuring the worker pool for your
Spacelift infrastructure.

## Configuration

### Docker Image on ECR

Build and tag a Docker image for this repository and push to ECR. Ensure the account where this component is deployed
has read-only access to the ECR repository.

### API Key

Prior to deployment, the API key must exist in SSM. The key must have admin permissions.

To generate the key, please follow
[these instructions](https://docs.spacelift.io/integrations/api.html#spacelift-api-key-token). Once generated, write the
API key ID and secret to the SSM key store at the following locations within the same AWS account and region where the
Spacelift worker pool will reside.

| Key     | SSM Path                | Type           |
| ------- | ----------------------- | -------------- |
| API ID  | `/spacelift/key_id`     | `SecureString` |
| API Key | `/spacelift/key_secret` | `SecureString` |

_HINT_: The API key ID is displayed as an upper-case, 16-character alphanumeric value next to the key name in the API
key list.

Save the keys using `chamber` using the correct profile for where Spacelift worker pool is provisioned

```
AWS_PROFILE=acme-gbl-auto-admin chamber write spacelift key_id 1234567890123456
AWS_PROFILE=acme-gbl-auto-admin chamber write spacelift key_secret abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz
```

### IAM configuration

After provisioning the component, you must give the created instance role permission to assume the Spacelift worker
role. This is done by adding `iam_role_arn` from the output to the `trusted_role_arns` list for the `spacelift` role in
`aws-teams`.

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.9.0 |
| <a name="requirement_cloudinit"></a> [cloudinit](#requirement\_cloudinit) | >= 2.2.0 |
| <a name="requirement_spacelift"></a> [spacelift](#requirement\_spacelift) | >= 0.1.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.9.0 |
| <a name="provider_cloudinit"></a> [cloudinit](#provider\_cloudinit) | >= 2.2.0 |
| <a name="provider_spacelift"></a> [spacelift](#provider\_spacelift) | >= 0.1.2 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_account_map"></a> [account\_map](#module\_account\_map) | cloudposse/stack-config/yaml//modules/remote-state | 1.5.0 |
| <a name="module_autoscale_group"></a> [autoscale\_group](#module\_autoscale\_group) | cloudposse/ec2-autoscale-group/aws | 0.35.1 |
| <a name="module_ecr"></a> [ecr](#module\_ecr) | cloudposse/stack-config/yaml//modules/remote-state | 1.5.0 |
| <a name="module_iam_label"></a> [iam\_label](#module\_iam\_label) | cloudposse/label/null | 0.25.0 |
| <a name="module_iam_roles"></a> [iam\_roles](#module\_iam\_roles) | ../../account-map/modules/iam-roles | n/a |
| <a name="module_security_group"></a> [security\_group](#module\_security\_group) | cloudposse/security-group/aws | 2.2.0 |
| <a name="module_spaces"></a> [spaces](#module\_spaces) | cloudposse/stack-config/yaml//modules/remote-state | 1.5.0 |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | cloudposse/stack-config/yaml//modules/remote-state | 1.5.0 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_instance_profile.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [spacelift_worker_pool.primary](https://registry.terraform.io/providers/spacelift-io/spacelift/latest/docs/resources/worker_pool) | resource |
| [aws_ami.spacelift](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_iam_policy_document.assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_ssm_parameter.spacelift_key_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.spacelift_key_secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [cloudinit_config.config](https://registry.terraform.io/providers/hashicorp/cloudinit/latest/docs/data-sources/config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_map_environment_name"></a> [account\_map\_environment\_name](#input\_account\_map\_environment\_name) | The name of the environment where `account_map` is provisioned | `string` | `"gbl"` | no |
| <a name="input_account_map_stage_name"></a> [account\_map\_stage\_name](#input\_account\_map\_stage\_name) | The name of the stage where `account_map` is provisioned | `string` | `"root"` | no |
| <a name="input_account_map_tenant_name"></a> [account\_map\_tenant\_name](#input\_account\_map\_tenant\_name) | The name of the tenant where `account_map` is provisioned.<br><br>If the `tenant` label is not used, leave this as `null`. | `string` | `null` | no |
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br>This is for some rare cases where resources want additional configuration of tags<br>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_architecture"></a> [architecture](#input\_architecture) | OS architecture of the EC2 instance AMI | `list(string)` | <pre>[<br>  "x86_64"<br>]</pre> | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br>in the order they appear in the list. New attributes are appended to the<br>end of the list. The elements of the list are joined by the `delimiter`<br>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_aws_config_file"></a> [aws\_config\_file](#input\_aws\_config\_file) | The AWS\_CONFIG\_FILE used by the worker. Can be overridden by `/.spacelift/config.yml`. | `string` | `"/etc/aws-config/aws-config-spacelift"` | no |
| <a name="input_aws_profile"></a> [aws\_profile](#input\_aws\_profile) | The AWS\_PROFILE used by the worker. If not specified, `"${var.namespace}-identity"` will be used.<br>Can be overridden by `/.spacelift/config.yml`. | `string` | `null` | no |
| <a name="input_block_device_mappings"></a> [block\_device\_mappings](#input\_block\_device\_mappings) | Specify volumes to attach to the instance besides the volumes specified by the AMI | <pre>list(object({<br>    device_name  = string<br>    no_device    = bool<br>    virtual_name = string<br>    ebs = object({<br>      delete_on_termination = bool<br>      encrypted             = bool<br>      iops                  = number<br>      kms_key_id            = string<br>      snapshot_id           = string<br>      volume_size           = number<br>      volume_type           = string<br>    })<br>  }))</pre> | `[]` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "descriptor_formats": {},<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "labels_as_tags": [<br>    "unset"<br>  ],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {},<br>  "tenant": null<br>}</pre> | no |
| <a name="input_cpu_utilization_high_threshold_percent"></a> [cpu\_utilization\_high\_threshold\_percent](#input\_cpu\_utilization\_high\_threshold\_percent) | CPU utilization high threshold | `number` | n/a | yes |
| <a name="input_cpu_utilization_low_threshold_percent"></a> [cpu\_utilization\_low\_threshold\_percent](#input\_cpu\_utilization\_low\_threshold\_percent) | CPU utilization low threshold | `number` | n/a | yes |
| <a name="input_custom_spacelift_ami"></a> [custom\_spacelift\_ami](#input\_custom\_spacelift\_ami) | Custom spacelift AMI | `bool` | `false` | no |
| <a name="input_default_cooldown"></a> [default\_cooldown](#input\_default\_cooldown) | The amount of time, in seconds, after a scaling activity completes before another scaling activity can start | `number` | `300` | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br>Map of maps. Keys are names of descriptors. Values are maps of the form<br>`{<br>   format = string<br>   labels = list(string)<br>}`<br>(Type is `any` so the map values can later be enhanced to provide additional options.)<br>`format` is a Terraform format string to be passed to the `format()` function.<br>`labels` is a list of labels, in order, to pass to `format()` function.<br>Label values will be normalized before being passed to `format()` so they will be<br>identical to how they appear in `id`.<br>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_desired_capacity"></a> [desired\_capacity](#input\_desired\_capacity) | The number of Amazon EC2 instances that should be running in the group, if not set will use `min_size` as value | `number` | `null` | no |
| <a name="input_ebs_optimized"></a> [ebs\_optimized](#input\_ebs\_optimized) | If true, the launched EC2 instance will be EBS-optimized | `bool` | `false` | no |
| <a name="input_ecr_environment_name"></a> [ecr\_environment\_name](#input\_ecr\_environment\_name) | The name of the environment where `ecr` is provisioned | `string` | `""` | no |
| <a name="input_ecr_region"></a> [ecr\_region](#input\_ecr\_region) | AWS region that contains the ECR infrastructure repo | `string` | `""` | no |
| <a name="input_ecr_repo_name"></a> [ecr\_repo\_name](#input\_ecr\_repo\_name) | ECR repository name | `string` | n/a | yes |
| <a name="input_ecr_stage_name"></a> [ecr\_stage\_name](#input\_ecr\_stage\_name) | The name of the stage where `ecr` is provisioned | `string` | `"artifacts"` | no |
| <a name="input_ecr_tenant_name"></a> [ecr\_tenant\_name](#input\_ecr\_tenant\_name) | The name of the tenant where `ecr` is provisioned.<br><br>If the `tenant` label is not used, leave this as `null`. | `string` | `null` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_github_netrc_enabled"></a> [github\_netrc\_enabled](#input\_github\_netrc\_enabled) | Whether to create a GitHub .netrc file so Spacelift can clone private GitHub repositories. | `bool` | `false` | no |
| <a name="input_github_netrc_ssm_path_token"></a> [github\_netrc\_ssm\_path\_token](#input\_github\_netrc\_ssm\_path\_token) | If `github_netrc` is enabled, this is the SSM path to retrieve the GitHub token. | `string` | `"/github/token"` | no |
| <a name="input_github_netrc_ssm_path_user"></a> [github\_netrc\_ssm\_path\_user](#input\_github\_netrc\_ssm\_path\_user) | If `github_netrc` is enabled, this is the SSM path to retrieve the GitHub user | `string` | `"/github/user"` | no |
| <a name="input_health_check_grace_period"></a> [health\_check\_grace\_period](#input\_health\_check\_grace\_period) | Time (in seconds) after instance comes into service before checking health | `number` | `300` | no |
| <a name="input_health_check_type"></a> [health\_check\_type](#input\_health\_check\_type) | Controls how health checking is done. Valid values are `EC2` or `ELB` | `string` | `"EC2"` | no |
| <a name="input_iam_attributes"></a> [iam\_attributes](#input\_iam\_attributes) | Additional attributes to add to the IDs of the IAM role and policy | `list(string)` | `[]` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for keep the existing setting, which defaults to `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_infracost_api_token_ssm_path"></a> [infracost\_api\_token\_ssm\_path](#input\_infracost\_api\_token\_ssm\_path) | This is the SSM path to retrieve and set the INFRACOST\_API\_TOKEN environment variable | `string` | `"/infracost/token"` | no |
| <a name="input_infracost_cli_args"></a> [infracost\_cli\_args](#input\_infracost\_cli\_args) | These are the CLI args passed to infracost | `string` | `""` | no |
| <a name="input_infracost_enabled"></a> [infracost\_enabled](#input\_infracost\_enabled) | Whether to enable infracost for Spacelift stacks | `bool` | `false` | no |
| <a name="input_infracost_warn_on_failure"></a> [infracost\_warn\_on\_failure](#input\_infracost\_warn\_on\_failure) | A failure executing Infracost, or a non-zero exit code being returned from the command will cause runs to fail. If this is true, this will only warn instead of failing the stack. | `bool` | `true` | no |
| <a name="input_instance_lifetime"></a> [instance\_lifetime](#input\_instance\_lifetime) | Number of seconds after which the instance will be terminated. The default is set to 14 days. | `number` | `1209600` | no |
| <a name="input_instance_refresh"></a> [instance\_refresh](#input\_instance\_refresh) | The instance refresh definition. If this block is configured, an Instance Refresh will be started when the Auto Scaling Group is updated | <pre>object({<br>    strategy = string<br>    preferences = object({<br>      instance_warmup        = optional(number, null)<br>      min_healthy_percentage = optional(number, null)<br>      skip_matching          = optional(bool, null)<br>      auto_rollback          = optional(bool, null)<br>    })<br>    triggers = optional(list(string), [])<br>  })</pre> | `null` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | EC2 instance type to use for workers | `string` | `"r5n.large"` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br>Does not affect keys of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br>set as tag values, and output by this module individually.<br>Does not affect values of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br>Default is to include all labels.<br>Tags with empty values will not be included in the `tags` output.<br>Set to `[]` to suppress all generated tags.<br>**Notes:**<br>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br>  "default"<br>]</pre> | no |
| <a name="input_launch_template_version"></a> [launch\_template\_version](#input\_launch\_template\_version) | Launch template version to use for workers. Note that instance refresh settings are IGNORED unless template version is empty | `string` | `"$Latest"` | no |
| <a name="input_max_size"></a> [max\_size](#input\_max\_size) | The maximum size of the autoscale group | `number` | n/a | yes |
| <a name="input_min_size"></a> [min\_size](#input\_min\_size) | The minimum size of the autoscale group | `number` | n/a | yes |
| <a name="input_mixed_instances_policy"></a> [mixed\_instances\_policy](#input\_mixed\_instances\_policy) | Policy to use a mixed group of on-demand/spot of different types. Launch template is automatically generated. https://www.terraform.io/docs/providers/aws/r/autoscaling_group.html#mixed_instances_policy-1 | <pre>object({<br>    instances_distribution = object({<br>      on_demand_allocation_strategy            = string<br>      on_demand_base_capacity                  = number<br>      on_demand_percentage_above_base_capacity = number<br>      spot_allocation_strategy                 = string<br>      spot_instance_pools                      = number<br>      spot_max_price                           = string<br>    })<br>    override = list(object({<br>      instance_type     = string<br>      weighted_capacity = number<br>    }))<br>  })</pre> | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br>This is the only ID element not also included as a `tag`.<br>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br>Characters matching the regex will be removed from the ID elements.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_scale_down_cooldown_seconds"></a> [scale\_down\_cooldown\_seconds](#input\_scale\_down\_cooldown\_seconds) | The amount of time, in seconds, after a scaling activity completes and before the next scaling activity can start | `number` | `300` | no |
| <a name="input_space_name"></a> [space\_name](#input\_space\_name) | The name of the Space to create the worker pool in | `string` | `"root"` | no |
| <a name="input_spacelift_agents_per_node"></a> [spacelift\_agents\_per\_node](#input\_spacelift\_agents\_per\_node) | Number of Spacelift agents to run on one worker node. NOTE: This affects billable units. Spacelift charges per agent. | `number` | `1` | no |
| <a name="input_spacelift_ami_id"></a> [spacelift\_ami\_id](#input\_spacelift\_ami\_id) | AMI ID of Spacelift worker pool image | `string` | `null` | no |
| <a name="input_spacelift_api_endpoint"></a> [spacelift\_api\_endpoint](#input\_spacelift\_api\_endpoint) | The Spacelift API endpoint URL (e.g. https://example.app.spacelift.io) | `string` | n/a | yes |
| <a name="input_spacelift_aws_account_id"></a> [spacelift\_aws\_account\_id](#input\_spacelift\_aws\_account\_id) | AWS Account ID owned by Spacelift | `string` | `"643313122712"` | no |
| <a name="input_spacelift_domain_name"></a> [spacelift\_domain\_name](#input\_spacelift\_domain\_name) | Top-level domain name to use for pulling the launcher binary | `string` | `"spacelift.io"` | no |
| <a name="input_spacelift_runner_image"></a> [spacelift\_runner\_image](#input\_spacelift\_runner\_image) | URL of ECR image to use for Spacelift | `string` | `""` | no |
| <a name="input_spacelift_spaces_component_name"></a> [spacelift\_spaces\_component\_name](#input\_spacelift\_spaces\_component\_name) | The name of the spacelift spaces component | `string` | `"spacelift/spaces"` | no |
| <a name="input_spacelift_spaces_environment_name"></a> [spacelift\_spaces\_environment\_name](#input\_spacelift\_spaces\_environment\_name) | The environment name of the spacelift spaces component | `string` | `null` | no |
| <a name="input_spacelift_spaces_stage_name"></a> [spacelift\_spaces\_stage\_name](#input\_spacelift\_spaces\_stage\_name) | The stage name of the spacelift spaces component | `string` | `null` | no |
| <a name="input_spacelift_spaces_tenant_name"></a> [spacelift\_spaces\_tenant\_name](#input\_spacelift\_spaces\_tenant\_name) | The tenant name of the spacelift spaces component | `string` | `null` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |
| <a name="input_termination_policies"></a> [termination\_policies](#input\_termination\_policies) | A list of policies to decide how the instances in the auto scale group should be terminated. The allowed values are `OldestInstance`, `NewestInstance`, `OldestLaunchConfiguration`, `ClosestToNextInstanceHour`, `Default` | `list(string)` | <pre>[<br>  "OldestLaunchConfiguration"<br>]</pre> | no |
| <a name="input_wait_for_capacity_timeout"></a> [wait\_for\_capacity\_timeout](#input\_wait\_for\_capacity\_timeout) | A maximum duration that Terraform should wait for ASG instances to be healthy before timing out. (See also Waiting for Capacity below.) Setting this to '0' causes Terraform to skip all Capacity Waiting behavior | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_autoscaling_group_arn"></a> [autoscaling\_group\_arn](#output\_autoscaling\_group\_arn) | The ARN for this AutoScaling Group |
| <a name="output_autoscaling_group_default_cooldown"></a> [autoscaling\_group\_default\_cooldown](#output\_autoscaling\_group\_default\_cooldown) | Time between a scaling activity and the succeeding scaling activity |
| <a name="output_autoscaling_group_health_check_grace_period"></a> [autoscaling\_group\_health\_check\_grace\_period](#output\_autoscaling\_group\_health\_check\_grace\_period) | Time after instance comes into service before checking health |
| <a name="output_autoscaling_group_health_check_type"></a> [autoscaling\_group\_health\_check\_type](#output\_autoscaling\_group\_health\_check\_type) | `EC2` or `ELB`. Controls how health checking is done |
| <a name="output_autoscaling_group_id"></a> [autoscaling\_group\_id](#output\_autoscaling\_group\_id) | The autoscaling group id |
| <a name="output_autoscaling_group_max_size"></a> [autoscaling\_group\_max\_size](#output\_autoscaling\_group\_max\_size) | The maximum size of the autoscale group |
| <a name="output_autoscaling_group_min_size"></a> [autoscaling\_group\_min\_size](#output\_autoscaling\_group\_min\_size) | The minimum size of the autoscale group |
| <a name="output_autoscaling_group_name"></a> [autoscaling\_group\_name](#output\_autoscaling\_group\_name) | The autoscaling group name |
| <a name="output_iam_role_arn"></a> [iam\_role\_arn](#output\_iam\_role\_arn) | Spacelift IAM Role ARN |
| <a name="output_iam_role_id"></a> [iam\_role\_id](#output\_iam\_role\_id) | Spacelift IAM Role ID |
| <a name="output_iam_role_name"></a> [iam\_role\_name](#output\_iam\_role\_name) | Spacelift IAM Role name |
| <a name="output_launch_template_arn"></a> [launch\_template\_arn](#output\_launch\_template\_arn) | The ARN of the launch template |
| <a name="output_launch_template_id"></a> [launch\_template\_id](#output\_launch\_template\_id) | The ID of the launch template |
| <a name="output_security_group_arn"></a> [security\_group\_arn](#output\_security\_group\_arn) | Spacelift Security Group ARN |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | Spacelift Security Group ID |
| <a name="output_security_group_name"></a> [security\_group\_name](#output\_security\_group\_name) | Spacelift Security Group Name |
| <a name="output_worker_pool_id"></a> [worker\_pool\_id](#output\_worker\_pool\_id) | Spacelift worker pool ID |
| <a name="output_worker_pool_name"></a> [worker\_pool\_name](#output\_worker\_pool\_name) | Spacelift worker pool name |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## References

- [cloudposse/terraform-spacelift-cloud-infrastructure-automation](https://github.com/cloudposse/terraform-spacelift-cloud-infrastructure-automation) -
  Cloud Posse's related upstream component
- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/spacelift-worker-pool) -
  Cloud Posse's upstream component

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
