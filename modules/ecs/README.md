# Component: `ecs`

This component is responsible for provisioning an ECS Cluster and associated load balancer.

## Usage

**Stack Level**: Regional

Here's an example snippet for how to use this component.

The following will create

- ecs cluster
- load balancer with an ACM cert placed on example.com
- r53 record on all *.example.com which will point to the load balancer

```yaml
components:
  terraform:
    ecs:
      settings:
        spacelift:
          workspace_enabled: true
      vars:
        name: ecs
        enabled: true
        acm_certificate_domain: example.com
        route53_record_name: "*"
        # Create records will be created in each zone
        zone_names:
          - example.com
        capacity_providers_fargate: true
        capacity_providers_fargate_spot: true
        capacity_providers_ec2:
          default:
            instance_type: t3.medium
            max_size: 2
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 4.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cluster"></a> [cluster](#module\_cluster) | cloudposse/ecs-cluster/aws | 0.3.0 |
| <a name="module_gha_assume_role"></a> [gha\_assume\_role](#module\_gha\_assume\_role) | ../account-map/modules/team-assume-role-policy | n/a |
| <a name="module_gha_role_name"></a> [gha\_role\_name](#module\_gha\_role\_name) | cloudposse/label/null | 0.25.0 |
| <a name="module_iam_roles"></a> [iam\_roles](#module\_iam\_roles) | ../account-map/modules/iam-roles | n/a |
| <a name="module_s3_bucket"></a> [s3\_bucket](#module\_s3\_bucket) | cloudposse/s3-bucket/aws | 3.1.1 |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_role.github_actions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_policy_document.github_actions_iam_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acm_certificate_domain"></a> [acm\_certificate\_domain](#input\_acm\_certificate\_domain) | Domain to get the ACM cert to use on the ALB. | `string` | `null` | no |
| <a name="input_acm_certificate_domain_suffix"></a> [acm\_certificate\_domain\_suffix](#input\_acm\_certificate\_domain\_suffix) | Domain suffix to use with dns delegated HZ to get the ACM cert to use on the ALB | `string` | `null` | no |
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br>This is for some rare cases where resources want additional configuration of tags<br>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_alb_configuration"></a> [alb\_configuration](#input\_alb\_configuration) | Map of multiple ALB configurations. | `map(any)` | `{}` | no |
| <a name="input_alb_ingress_cidr_blocks_http"></a> [alb\_ingress\_cidr\_blocks\_http](#input\_alb\_ingress\_cidr\_blocks\_http) | List of CIDR blocks allowed to access environment over HTTP | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_alb_ingress_cidr_blocks_https"></a> [alb\_ingress\_cidr\_blocks\_https](#input\_alb\_ingress\_cidr\_blocks\_https) | List of CIDR blocks allowed to access environment over HTTPS | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_allowed_cidr_blocks"></a> [allowed\_cidr\_blocks](#input\_allowed\_cidr\_blocks) | List of CIDR blocks to be allowed to connect to the EKS cluster | `list(string)` | `[]` | no |
| <a name="input_allowed_security_groups"></a> [allowed\_security\_groups](#input\_allowed\_security\_groups) | List of Security Group IDs to be allowed to connect to the EKS cluster | `list(string)` | `[]` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br>in the order they appear in the list. New attributes are appended to the<br>end of the list. The elements of the list are joined by the `delimiter`<br>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_capacity_providers_ec2"></a> [capacity\_providers\_ec2](#input\_capacity\_providers\_ec2) | EC2 autoscale groups capacity providers | <pre>map(object({<br>    instance_type                        = string<br>    max_size                             = number<br>    security_group_ids                   = optional(list(string), [])<br>    min_size                             = optional(number, 0)<br>    image_id                             = optional(string)<br>    instance_initiated_shutdown_behavior = optional(string, "terminate")<br>    key_name                             = optional(string, "")<br>    user_data                            = optional(string, "")<br>    enable_monitoring                    = optional(bool, true)<br>    instance_warmup_period               = optional(number, 300)<br>    maximum_scaling_step_size            = optional(number, 1)<br>    minimum_scaling_step_size            = optional(number, 1)<br>    target_capacity_utilization          = optional(number, 100)<br>    ebs_optimized                        = optional(bool, false)<br>    block_device_mappings = optional(list(object({<br>      device_name  = string<br>      no_device    = bool<br>      virtual_name = string<br>      ebs = object({<br>        delete_on_termination = bool<br>        encrypted             = bool<br>        iops                  = number<br>        kms_key_id            = string<br>        snapshot_id           = string<br>        volume_size           = number<br>        volume_               = string<br>      })<br>    })), [])<br>    instance_market_options = optional(object({<br>      market_ = string<br>      spot_options = object({<br>        block_duration_minutes         = number<br>        instance_interruption_behavior = string<br>        max_price                      = number<br>        spot_instance_                 = string<br>        valid_until                    = string<br>      })<br>    }))<br>    instance_refresh = optional(object({<br>      strategy = string<br>      preferences = object({<br>        instance_warmup        = number<br>        min_healthy_percentage = number<br>      })<br>      triggers = list(string)<br>    }))<br>    mixed_instances_policy = optional(object({<br>      instances_distribution = object({<br>        on_demand_allocation_strategy            = string<br>        on_demand_base_capacity                  = number<br>        on_demand_percentage_above_base_capacity = number<br>        spot_allocation_strategy                 = string<br>        spot_instance_pools                      = number<br>        spot_max_price                           = string<br>      })<br>      }), {<br>      instances_distribution = null<br>    })<br>    placement = optional(object({<br>      affinity          = string<br>      availability_zone = string<br>      group_name        = string<br>      host_id           = string<br>      tenancy           = string<br>    }))<br>    credit_specification = optional(object({<br>      cpu_credits = string<br>    }))<br>    elastic_gpu_specifications = optional(object({<br>      type = string<br>    }))<br>    disable_api_termination   = optional(bool, false)<br>    default_cooldown          = optional(number, 300)<br>    health_check_grace_period = optional(number, 300)<br>    force_delete              = optional(bool, false)<br>    termination_policies      = optional(list(string), ["Default"])<br>    suspended_processes       = optional(list(string), [])<br>    placement_group           = optional(string, "")<br>    metrics_granularity       = optional(string, "1Minute")<br>    enabled_metrics = optional(list(string), [<br>      "GroupMinSize",<br>      "GroupMaxSize",<br>      "GroupDesiredCapacity",<br>      "GroupInServiceInstances",<br>      "GroupPendingInstances",<br>      "GroupStandbyInstances",<br>      "GroupTerminatingInstances",<br>      "GroupTotalInstances",<br>      "GroupInServiceCapacity",<br>      "GroupPendingCapacity",<br>      "GroupStandbyCapacity",<br>      "GroupTerminatingCapacity",<br>      "GroupTotalCapacity",<br>      "WarmPoolDesiredCapacity",<br>      "WarmPoolWarmedCapacity",<br>      "WarmPoolPendingCapacity",<br>      "WarmPoolTerminatingCapacity",<br>      "WarmPoolTotalCapacity",<br>      "GroupAndWarmPoolDesiredCapacity",<br>      "GroupAndWarmPoolTotalCapacity",<br>    ])<br>    wait_for_capacity_timeout            = optional(string, "10m")<br>    service_linked_role_arn              = optional(string, "")<br>    metadata_http_endpoint_enabled       = optional(bool, true)<br>    metadata_http_put_response_hop_limit = optional(number, 2)<br>    metadata_http_tokens_required        = optional(bool, true)<br>    metadata_http_protocol_ipv6_enabled  = optional(bool, false)<br>    tag_specifications_resource_types    = optional(set(string), ["instance", "volume"])<br>    max_instance_lifetime                = optional(number, null)<br>    capacity_rebalance                   = optional(bool, false)<br>    warm_pool = optional(object({<br>      pool_state                  = string<br>      min_size                    = number<br>      max_group_prepared_capacity = number<br>    }))<br>  }))</pre> | `{}` | no |
| <a name="input_capacity_providers_fargate"></a> [capacity\_providers\_fargate](#input\_capacity\_providers\_fargate) | Use FARGATE capacity provider | `bool` | `true` | no |
| <a name="input_capacity_providers_fargate_spot"></a> [capacity\_providers\_fargate\_spot](#input\_capacity\_providers\_fargate\_spot) | Use FARGATE\_SPOT capacity provider | `bool` | `false` | no |
| <a name="input_container_insights_enabled"></a> [container\_insights\_enabled](#input\_container\_insights\_enabled) | Whether or not to enable container insights | `bool` | `true` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "descriptor_formats": {},<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "labels_as_tags": [<br>    "unset"<br>  ],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {},<br>  "tenant": null<br>}</pre> | no |
| <a name="input_default_capacity_strategy"></a> [default\_capacity\_strategy](#input\_default\_capacity\_strategy) | The capacity provider strategy to use by default for the cluster | <pre>object({<br>    base = object({<br>      provider = string<br>      value    = number<br>    })<br>    weights = map(number)<br>  })</pre> | <pre>{<br>  "base": {<br>    "provider": "FARGATE",<br>    "value": 1<br>  },<br>  "weights": {}<br>}</pre> | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br>Map of maps. Keys are names of descriptors. Values are maps of the form<br>`{<br>   format = string<br>   labels = list(string)<br>}`<br>(Type is `any` so the map values can later be enhanced to provide additional options.)<br>`format` is a Terraform format string to be passed to the `format()` function.<br>`labels` is a list of labels, in order, to pass to `format()` function.<br>Label values will be normalized before being passed to `format()` so they will be<br>identical to how they appear in `id`.<br>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_dns_delegated_environment_name"></a> [dns\_delegated\_environment\_name](#input\_dns\_delegated\_environment\_name) | Use this environment name to read from the remote state to get the dns\_delegated zone ID | `string` | `"gbl"` | no |
| <a name="input_dns_delegated_stage_name"></a> [dns\_delegated\_stage\_name](#input\_dns\_delegated\_stage\_name) | Use this stage name to read from the remote state to get the dns\_delegated zone ID | `string` | `null` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_github_actions_allowed_repos"></a> [github\_actions\_allowed\_repos](#input\_github\_actions\_allowed\_repos) | A list of the GitHub repositories that are allowed to assume this role from GitHub Actions. For example,<br>  ["cloudposse/infra-live"]. Can contain "*" as wildcard.<br>  If org part of repo name is omitted, "cloudposse" will be assumed. | `list(string)` | `[]` | no |
| <a name="input_github_actions_iam_role_attributes"></a> [github\_actions\_iam\_role\_attributes](#input\_github\_actions\_iam\_role\_attributes) | Additional attributes to add to the role name | `list(string)` | `[]` | no |
| <a name="input_github_actions_iam_role_enabled"></a> [github\_actions\_iam\_role\_enabled](#input\_github\_actions\_iam\_role\_enabled) | Flag to toggle creation of an IAM Role that GitHub Actions can assume to access AWS resources | `bool` | `false` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for keep the existing setting, which defaults to `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_import_profile_name"></a> [import\_profile\_name](#input\_import\_profile\_name) | AWS Profile name to use when importing a resource | `string` | `null` | no |
| <a name="input_import_role_arn"></a> [import\_role\_arn](#input\_import\_role\_arn) | IAM Role ARN to use when importing a resource | `string` | `null` | no |
| <a name="input_internal_enabled"></a> [internal\_enabled](#input\_internal\_enabled) | Whether to create an internal load balancer for services in this cluster | `bool` | `false` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | The AWS Key Management Service key ID to encrypt the data between the local client and the container. | `string` | `null` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br>Does not affect keys of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br>set as tag values, and output by this module individually.<br>Does not affect values of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br>Default is to include all labels.<br>Tags with empty values will not be included in the `tags` output.<br>Set to `[]` to suppress all generated tags.<br>**Notes:**<br>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br>  "default"<br>]</pre> | no |
| <a name="input_log_configuration"></a> [log\_configuration](#input\_log\_configuration) | The log configuration for the results of the execute command actions Required when logging is OVERRIDE | <pre>object({<br>    cloud_watch_encryption_enabled = string<br>    cloud_watch_log_group_name     = string<br>    s3_bucket_name                 = string<br>    s3_key_prefix                  = string<br>  })</pre> | `null` | no |
| <a name="input_logging"></a> [logging](#input\_logging) | The AWS Key Management Service key ID to encrypt the data between the local client and the container. (Valid values: 'NONE', 'DEFAULT', 'OVERRIDE') | `string` | `"DEFAULT"` | no |
| <a name="input_maintenance_page_path"></a> [maintenance\_page\_path](#input\_maintenance\_page\_path) | The path from this directory to the text/html page to use as the maintenance page. Must be within 1024 characters | `string` | `"templates/503_example.html"` | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br>This is the only ID element not also included as a `tag`.<br>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_privileged"></a> [privileged](#input\_privileged) | True if the default provider already has access to the backend | `bool` | `false` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br>Characters matching the regex will be removed from the ID elements.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_route53_enabled"></a> [route53\_enabled](#input\_route53\_enabled) | Whether or not to create a route53 record for the ALB | `bool` | `true` | no |
| <a name="input_route53_record_name"></a> [route53\_record\_name](#input\_route53\_record\_name) | The route53 record name | `string` | `"*"` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_arn"></a> [bucket\_arn](#output\_bucket\_arn) | Bucket ARN |
| <a name="output_bucket_id"></a> [bucket\_id](#output\_bucket\_id) | Bucket Name (aka ID) |
| <a name="output_bucket_region"></a> [bucket\_region](#output\_bucket\_region) | Bucket region |
| <a name="output_cluster"></a> [cluster](#output\_cluster) | ECS cluster |
| <a name="output_github_actions_iam_role_arn"></a> [github\_actions\_iam\_role\_arn](#output\_github\_actions\_iam\_role\_arn) | ARN of IAM role for GitHub Actions |
| <a name="output_github_actions_iam_role_name"></a> [github\_actions\_iam\_role\_name](#output\_github\_actions\_iam\_role\_name) | Name of IAM role for GitHub Actions |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## References

* [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/master/modules/ecs) - Cloud Posse's upstream component

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
