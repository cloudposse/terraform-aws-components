# Component: `github-runners`

This component is responsible for provisioning EC2 instances for GitHub runners.

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

To generate the token, please follow [these instructions](https://cloudposse.atlassian.net/l/c/N4dH05ud). Once generated, write the API token to the SSM key store at the following location within the same AWS account and region where the GitHub Actions runner pool will reside.

```
assume-role <automation-admin role>
chamber write github/runners/<github-org> registration-token ghp_secretstring
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.9.0 |
| <a name="requirement_cloudinit"></a> [cloudinit](#requirement\_cloudinit) | >= 2.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.9.0 |
| <a name="provider_cloudinit"></a> [cloudinit](#provider\_cloudinit) | >= 2.2 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_account_map"></a> [account\_map](#module\_account\_map) | cloudposse/stack-config/yaml//modules/remote-state | 1.4.1 |
| <a name="module_autoscale_group"></a> [autoscale\_group](#module\_autoscale\_group) | cloudposse/ec2-autoscale-group/aws | 0.30.1 |
| <a name="module_graceful_scale_in"></a> [graceful\_scale\_in](#module\_graceful\_scale\_in) | ./modules/graceful_scale_in | n/a |
| <a name="module_iam_roles"></a> [iam\_roles](#module\_iam\_roles) | ../account-map/modules/iam-roles | n/a |
| <a name="module_sg"></a> [sg](#module\_sg) | cloudposse/security-group/aws | 1.0.1 |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | cloudposse/stack-config/yaml//modules/remote-state | 1.4.1 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_instance_profile.github_action_runner](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.github_action_runner](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.github_action_runner](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_ami.runner](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_iam_policy_document.github_action_runner](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.instance_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_ssm_parameter.github_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [cloudinit_config.config](https://registry.terraform.io/providers/hashicorp/cloudinit/latest/docs/data-sources/config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_map_environment_name"></a> [account\_map\_environment\_name](#input\_account\_map\_environment\_name) | The name of the environment where `account_map` is provisioned | `string` | `"gbl"` | no |
| <a name="input_account_map_stage_name"></a> [account\_map\_stage\_name](#input\_account\_map\_stage\_name) | The name of the stage where `account_map` is provisioned | `string` | `"root"` | no |
| <a name="input_account_map_tenant_name"></a> [account\_map\_tenant\_name](#input\_account\_map\_tenant\_name) | The name of the tenant where `account_map` is provisioned.<br><br>If the `tenant` label is not used, leave this as `null`. | `string` | `null` | no |
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br>This is for some rare cases where resources want additional configuration of tags<br>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_ami_filter"></a> [ami\_filter](#input\_ami\_filter) | Map of lists used to look up the AMI which will be used for the GitHub Actions Runner. | `map(list(string))` | <pre>{<br>  "name": [<br>    "amzn2-ami-hvm-2.*-x86_64-ebs"<br>  ]<br>}</pre> | no |
| <a name="input_ami_owners"></a> [ami\_owners](#input\_ami\_owners) | The list of owners used to select the AMI of action runner instances. | `list(string)` | <pre>[<br>  "amazon"<br>]</pre> | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br>in the order they appear in the list. New attributes are appended to the<br>end of the list. The elements of the list are joined by the `delimiter`<br>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_block_device_mappings"></a> [block\_device\_mappings](#input\_block\_device\_mappings) | Specify volumes to attach to the instance besides the volumes specified by the AMI | <pre>list(object({<br>    device_name  = string<br>    no_device    = bool<br>    virtual_name = string<br>    ebs = object({<br>      delete_on_termination = bool<br>      encrypted             = bool<br>      iops                  = number<br>      kms_key_id            = string<br>      snapshot_id           = string<br>      volume_size           = number<br>      volume_type           = string<br>    })<br>  }))</pre> | `[]` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "descriptor_formats": {},<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "labels_as_tags": [<br>    "unset"<br>  ],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {},<br>  "tenant": null<br>}</pre> | no |
| <a name="input_cpu_utilization_high_evaluation_periods"></a> [cpu\_utilization\_high\_evaluation\_periods](#input\_cpu\_utilization\_high\_evaluation\_periods) | The number of periods over which data is compared to the specified threshold | `number` | `2` | no |
| <a name="input_cpu_utilization_high_period_seconds"></a> [cpu\_utilization\_high\_period\_seconds](#input\_cpu\_utilization\_high\_period\_seconds) | The period in seconds over which the specified statistic is applied | `number` | `300` | no |
| <a name="input_cpu_utilization_high_threshold_percent"></a> [cpu\_utilization\_high\_threshold\_percent](#input\_cpu\_utilization\_high\_threshold\_percent) | The value against which the specified statistic is compared | `number` | `90` | no |
| <a name="input_cpu_utilization_low_evaluation_periods"></a> [cpu\_utilization\_low\_evaluation\_periods](#input\_cpu\_utilization\_low\_evaluation\_periods) | The number of periods over which data is compared to the specified threshold | `number` | `2` | no |
| <a name="input_cpu_utilization_low_period_seconds"></a> [cpu\_utilization\_low\_period\_seconds](#input\_cpu\_utilization\_low\_period\_seconds) | The period in seconds over which the specified statistic is applied | `number` | `300` | no |
| <a name="input_cpu_utilization_low_threshold_percent"></a> [cpu\_utilization\_low\_threshold\_percent](#input\_cpu\_utilization\_low\_threshold\_percent) | The value against which the specified statistic is compared | `number` | `10` | no |
| <a name="input_default_cooldown"></a> [default\_cooldown](#input\_default\_cooldown) | The amount of time, in seconds, after a scaling activity completes before another scaling activity can start | `number` | `300` | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br>Map of maps. Keys are names of descriptors. Values are maps of the form<br>`{<br>   format = string<br>   labels = list(string)<br>}`<br>(Type is `any` so the map values can later be enhanced to provide additional options.)<br>`format` is a Terraform format string to be passed to the `format()` function.<br>`labels` is a list of labels, in order, to pass to `format()` function.<br>Label values will be normalized before being passed to `format()` so they will be<br>identical to how they appear in `id`.<br>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_docker_compose_version"></a> [docker\_compose\_version](#input\_docker\_compose\_version) | The version of docker-compose to install | `string` | `"1.29.2"` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_github_scope"></a> [github\_scope](#input\_github\_scope) | Scope of the runner (e.g. `cloudposse/example` for repo or `cloudposse` for org) | `string` | n/a | yes |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for keep the existing setting, which defaults to `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_import_profile_name"></a> [import\_profile\_name](#input\_import\_profile\_name) | AWS Profile name to use when importing a resource | `string` | `null` | no |
| <a name="input_import_role_arn"></a> [import\_role\_arn](#input\_import\_role\_arn) | IAM Role ARN to use when importing a resource | `string` | `null` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Default instance type for the action runner. | `string` | `"m5.large"` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br>Does not affect keys of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br>set as tag values, and output by this module individually.<br>Does not affect values of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br>Default is to include all labels.<br>Tags with empty values will not be included in the `tags` output.<br>Set to `[]` to suppress all generated tags.<br>**Notes:**<br>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br>  "default"<br>]</pre> | no |
| <a name="input_max_instance_lifetime"></a> [max\_instance\_lifetime](#input\_max\_instance\_lifetime) | The maximum amount of time, in seconds, that an instance can be in service, values must be either equal to 0 or between 604800 and 31536000 seconds | `number` | `null` | no |
| <a name="input_max_size"></a> [max\_size](#input\_max\_size) | The maximum size of the autoscale group | `number` | n/a | yes |
| <a name="input_min_size"></a> [min\_size](#input\_min\_size) | The minimum size of the autoscale group | `number` | n/a | yes |
| <a name="input_mixed_instances_policy"></a> [mixed\_instances\_policy](#input\_mixed\_instances\_policy) | Policy to use a mixed group of on-demand/spot of differing types. Launch template is automatically generated. https://www.terraform.io/docs/providers/aws/r/autoscaling_group.html#mixed_instances_policy-1 | <pre>object({<br>    instances_distribution = object({<br>      on_demand_allocation_strategy            = string<br>      on_demand_base_capacity                  = number<br>      on_demand_percentage_above_base_capacity = number<br>      spot_allocation_strategy                 = string<br>      spot_instance_pools                      = number<br>      spot_max_price                           = string<br>    })<br>    override = list(object({<br>      instance_type     = string<br>      weighted_capacity = number<br>    }))<br>  })</pre> | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br>This is the only ID element not also included as a `tag`.<br>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br>Characters matching the regex will be removed from the ID elements.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_runner_group"></a> [runner\_group](#input\_runner\_group) | GitHub runner group | `string` | `"default"` | no |
| <a name="input_runner_labels"></a> [runner\_labels](#input\_runner\_labels) | List of labels to add to the GitHub Runner (e.g. 'Amazon Linux 2'). | `list(string)` | `[]` | no |
| <a name="input_runner_role_additional_policy_arns"></a> [runner\_role\_additional\_policy\_arns](#input\_runner\_role\_additional\_policy\_arns) | List of policy ARNs that will be attached to the runners' default role on creation in addition to the defaults | `list(string)` | `[]` | no |
| <a name="input_runner_version"></a> [runner\_version](#input\_runner\_version) | GitHub runner release version | `string` | `"2.288.1"` | no |
| <a name="input_scale_down_cooldown_seconds"></a> [scale\_down\_cooldown\_seconds](#input\_scale\_down\_cooldown\_seconds) | The amount of time, in seconds, after a scaling activity completes and before the next scaling activity can start | `number` | `300` | no |
| <a name="input_ssm_parameter_name_format"></a> [ssm\_parameter\_name\_format](#input\_ssm\_parameter\_name\_format) | SSM parameter name format | `string` | `"/%s/%s"` | no |
| <a name="input_ssm_path"></a> [ssm\_path](#input\_ssm\_path) | GitHub token SSM path | `string` | `"github"` | no |
| <a name="input_ssm_path_key"></a> [ssm\_path\_key](#input\_ssm\_path\_key) | GitHub token SSM path key | `string` | `"registration-token"` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |
| <a name="input_userdata_post_install"></a> [userdata\_post\_install](#input\_userdata\_post\_install) | Shell script to run post installation of github action runner | `string` | `""` | no |
| <a name="input_userdata_pre_install"></a> [userdata\_pre\_install](#input\_userdata\_pre\_install) | Shell script to run before installation of github action runner | `string` | `""` | no |
| <a name="input_wait_for_capacity_timeout"></a> [wait\_for\_capacity\_timeout](#input\_wait\_for\_capacity\_timeout) | A maximum duration that Terraform should wait for ASG instances to be healthy before timing out. (See also Waiting for Capacity below.) Setting this to '0' causes Terraform to skip all Capacity Waiting behavior | `string` | `"10m"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_autoscaling_group_arn"></a> [autoscaling\_group\_arn](#output\_autoscaling\_group\_arn) | The Amazon Resource Name (ARN) of the Auto Scaling Group. |
| <a name="output_autoscaling_group_name"></a> [autoscaling\_group\_name](#output\_autoscaling\_group\_name) | The name of the Auto Scaling Group. |
| <a name="output_autoscaling_lifecycle_hook_name"></a> [autoscaling\_lifecycle\_hook\_name](#output\_autoscaling\_lifecycle\_hook\_name) | The name of the Lifecycle Hook for the Auto Scaling Group. |
| <a name="output_eventbridge_rule_arn"></a> [eventbridge\_rule\_arn](#output\_eventbridge\_rule\_arn) | The ARN of the Eventbridge rule for the EC2 lifecycle transition. |
| <a name="output_eventbridge_target_arn"></a> [eventbridge\_target\_arn](#output\_eventbridge\_target\_arn) | The ARN of the Eventbridge target corresponding to the Eventbridge rule for the EC2 lifecycle transition. |
| <a name="output_iam_role_arn"></a> [iam\_role\_arn](#output\_iam\_role\_arn) | The ARN of the IAM role associated with the Autoscaling Group |
| <a name="output_ssm_document_arn"></a> [ssm\_document\_arn](#output\_ssm\_document\_arn) | The ARN of the SSM document. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## References
* [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/master/modules/github-runners) - Cloud Posse's upstream component

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
