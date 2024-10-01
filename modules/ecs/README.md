---
tags:
  - component/ecs
  - layer/ecs
  - provider/aws
---

# Component: `ecs`

This component is responsible for provisioning an ECS Cluster and associated load balancer.

## Usage

**Stack Level**: Regional

Here's an example snippet for how to use this component.

The following will create

- ecs cluster
- load balancer with an ACM cert placed on example.com
- r53 record on all \*.example.com which will point to the load balancer

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

        alb_configuration:
          public:
            internal_enabled: false
            # resolves to *.public-platform.<environment>.<stage>.<tenant>.<domain>.<tld>
            route53_record_name: "*.public-platform"
            additional_certs:
              - "my-vanity-domain.com"
          private:
            internal_enabled: true
            route53_record_name: "*.private-platform"
            additional_certs:
              - "my-vanity-domain.com"
```

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_alb"></a> [alb](#module\_alb) | cloudposse/alb/aws | 1.11.1 |
| <a name="module_cluster"></a> [cluster](#module\_cluster) | cloudposse/ecs-cluster/aws | 0.4.1 |
| <a name="module_dns_delegated"></a> [dns\_delegated](#module\_dns\_delegated) | cloudposse/stack-config/yaml//modules/remote-state | 1.5.0 |
| <a name="module_iam_roles"></a> [iam\_roles](#module\_iam\_roles) | ../account-map/modules/iam-roles | n/a |
| <a name="module_target_group_label"></a> [target\_group\_label](#module\_target\_group\_label) | cloudposse/label/null | 0.25.0 |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | cloudposse/stack-config/yaml//modules/remote-state | 1.5.0 |

## Resources

| Name | Type |
|------|------|
| [aws_lb_listener_certificate.additional_certs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_certificate) | resource |
| [aws_route53_record.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_security_group.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress_cidr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress_security_groups](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_acm_certificate.additional_certs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/acm_certificate) | data source |
| [aws_acm_certificate.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/acm_certificate) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acm_certificate_domain"></a> [acm\_certificate\_domain](#input\_acm\_certificate\_domain) | Domain to get the ACM cert to use on the ALB. | `string` | `null` | no |
| <a name="input_acm_certificate_domain_suffix"></a> [acm\_certificate\_domain\_suffix](#input\_acm\_certificate\_domain\_suffix) | Domain suffix to use with dns delegated HZ to get the ACM cert to use on the ALB | `string` | `null` | no |
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br>This is for some rare cases where resources want additional configuration of tags<br>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_alb_configuration"></a> [alb\_configuration](#input\_alb\_configuration) | Map of multiple ALB configurations. | `map(any)` | `{}` | no |
| <a name="input_alb_ingress_cidr_blocks_http"></a> [alb\_ingress\_cidr\_blocks\_http](#input\_alb\_ingress\_cidr\_blocks\_http) | List of CIDR blocks allowed to access environment over HTTP | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_alb_ingress_cidr_blocks_https"></a> [alb\_ingress\_cidr\_blocks\_https](#input\_alb\_ingress\_cidr\_blocks\_https) | List of CIDR blocks allowed to access environment over HTTPS | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_allowed_cidr_blocks"></a> [allowed\_cidr\_blocks](#input\_allowed\_cidr\_blocks) | List of CIDR blocks to be allowed to connect to the ECS cluster | `list(string)` | `[]` | no |
| <a name="input_allowed_security_groups"></a> [allowed\_security\_groups](#input\_allowed\_security\_groups) | List of Security Group IDs to be allowed to connect to the ECS cluster | `list(string)` | `[]` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br>in the order they appear in the list. New attributes are appended to the<br>end of the list. The elements of the list are joined by the `delimiter`<br>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_capacity_providers_ec2"></a> [capacity\_providers\_ec2](#input\_capacity\_providers\_ec2) | EC2 autoscale groups capacity providers | <pre>map(object({<br>    instance_type                        = string<br>    max_size                             = number<br>    security_group_ids                   = optional(list(string), [])<br>    min_size                             = optional(number, 0)<br>    image_id                             = optional(string)<br>    instance_initiated_shutdown_behavior = optional(string, "terminate")<br>    key_name                             = optional(string, "")<br>    user_data                            = optional(string, "")<br>    enable_monitoring                    = optional(bool, true)<br>    instance_warmup_period               = optional(number, 300)<br>    maximum_scaling_step_size            = optional(number, 1)<br>    minimum_scaling_step_size            = optional(number, 1)<br>    target_capacity_utilization          = optional(number, 100)<br>    ebs_optimized                        = optional(bool, false)<br>    block_device_mappings = optional(list(object({<br>      device_name  = string<br>      no_device    = bool<br>      virtual_name = string<br>      ebs = object({<br>        delete_on_termination = bool<br>        encrypted             = bool<br>        iops                  = number<br>        kms_key_id            = string<br>        snapshot_id           = string<br>        volume_size           = number<br>        volume_type           = string<br>      })<br>    })), [])<br>    instance_market_options = optional(object({<br>      market_type = string<br>      spot_options = object({<br>        block_duration_minutes         = number<br>        instance_interruption_behavior = string<br>        max_price                      = number<br>        spot_instance_type             = string<br>        valid_until                    = string<br>      })<br>    }))<br>    instance_refresh = optional(object({<br>      strategy = string<br>      preferences = optional(object({<br>        instance_warmup        = optional(number, null)<br>        min_healthy_percentage = optional(number, null)<br>        skip_matching          = optional(bool, null)<br>        auto_rollback          = optional(bool, null)<br>      }), null)<br>      triggers = optional(list(string), [])<br>    }))<br>    mixed_instances_policy = optional(object({<br>      instances_distribution = object({<br>        on_demand_allocation_strategy            = string<br>        on_demand_base_capacity                  = number<br>        on_demand_percentage_above_base_capacity = number<br>        spot_allocation_strategy                 = string<br>        spot_instance_pools                      = number<br>        spot_max_price                           = string<br>      })<br>      }), {<br>      instances_distribution = null<br>    })<br>    placement = optional(object({<br>      affinity          = string<br>      availability_zone = string<br>      group_name        = string<br>      host_id           = string<br>      tenancy           = string<br>    }))<br>    credit_specification = optional(object({<br>      cpu_credits = string<br>    }))<br>    elastic_gpu_specifications = optional(object({<br>      type = string<br>    }))<br>    disable_api_termination   = optional(bool, false)<br>    default_cooldown          = optional(number, 300)<br>    health_check_grace_period = optional(number, 300)<br>    force_delete              = optional(bool, false)<br>    termination_policies      = optional(list(string), ["Default"])<br>    suspended_processes       = optional(list(string), [])<br>    placement_group           = optional(string, "")<br>    metrics_granularity       = optional(string, "1Minute")<br>    enabled_metrics = optional(list(string), [<br>      "GroupMinSize",<br>      "GroupMaxSize",<br>      "GroupDesiredCapacity",<br>      "GroupInServiceInstances",<br>      "GroupPendingInstances",<br>      "GroupStandbyInstances",<br>      "GroupTerminatingInstances",<br>      "GroupTotalInstances",<br>      "GroupInServiceCapacity",<br>      "GroupPendingCapacity",<br>      "GroupStandbyCapacity",<br>      "GroupTerminatingCapacity",<br>      "GroupTotalCapacity",<br>      "WarmPoolDesiredCapacity",<br>      "WarmPoolWarmedCapacity",<br>      "WarmPoolPendingCapacity",<br>      "WarmPoolTerminatingCapacity",<br>      "WarmPoolTotalCapacity",<br>      "GroupAndWarmPoolDesiredCapacity",<br>      "GroupAndWarmPoolTotalCapacity",<br>    ])<br>    wait_for_capacity_timeout            = optional(string, "10m")<br>    service_linked_role_arn              = optional(string, "")<br>    metadata_http_endpoint_enabled       = optional(bool, true)<br>    metadata_http_put_response_hop_limit = optional(number, 2)<br>    metadata_http_tokens_required        = optional(bool, true)<br>    metadata_http_protocol_ipv6_enabled  = optional(bool, false)<br>    tag_specifications_resource_types    = optional(set(string), ["instance", "volume"])<br>    max_instance_lifetime                = optional(number, null)<br>    capacity_rebalance                   = optional(bool, false)<br>    warm_pool = optional(object({<br>      pool_state                  = string<br>      min_size                    = number<br>      max_group_prepared_capacity = number<br>    }))<br>  }))</pre> | `{}` | no |
| <a name="input_capacity_providers_fargate"></a> [capacity\_providers\_fargate](#input\_capacity\_providers\_fargate) | Use FARGATE capacity provider | `bool` | `true` | no |
| <a name="input_capacity_providers_fargate_spot"></a> [capacity\_providers\_fargate\_spot](#input\_capacity\_providers\_fargate\_spot) | Use FARGATE\_SPOT capacity provider | `bool` | `false` | no |
| <a name="input_container_insights_enabled"></a> [container\_insights\_enabled](#input\_container\_insights\_enabled) | Whether or not to enable container insights | `bool` | `true` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "descriptor_formats": {},<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "labels_as_tags": [<br>    "unset"<br>  ],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {},<br>  "tenant": null<br>}</pre> | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br>Map of maps. Keys are names of descriptors. Values are maps of the form<br>`{<br>   format = string<br>   labels = list(string)<br>}`<br>(Type is `any` so the map values can later be enhanced to provide additional options.)<br>`format` is a Terraform format string to be passed to the `format()` function.<br>`labels` is a list of labels, in order, to pass to `format()` function.<br>Label values will be normalized before being passed to `format()` so they will be<br>identical to how they appear in `id`.<br>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_dns_delegated_component_name"></a> [dns\_delegated\_component\_name](#input\_dns\_delegated\_component\_name) | Use this component name to read from the remote state to get the dns\_delegated zone ID | `string` | `"dns-delegated"` | no |
| <a name="input_dns_delegated_environment_name"></a> [dns\_delegated\_environment\_name](#input\_dns\_delegated\_environment\_name) | Use this environment name to read from the remote state to get the dns\_delegated zone ID | `string` | `"gbl"` | no |
| <a name="input_dns_delegated_stage_name"></a> [dns\_delegated\_stage\_name](#input\_dns\_delegated\_stage\_name) | Use this stage name to read from the remote state to get the dns\_delegated zone ID | `string` | `null` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for keep the existing setting, which defaults to `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_internal_enabled"></a> [internal\_enabled](#input\_internal\_enabled) | Whether to create an internal load balancer for services in this cluster | `bool` | `false` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br>Does not affect keys of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br>set as tag values, and output by this module individually.<br>Does not affect values of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br>Default is to include all labels.<br>Tags with empty values will not be included in the `tags` output.<br>Set to `[]` to suppress all generated tags.<br>**Notes:**<br>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br>  "default"<br>]</pre> | no |
| <a name="input_maintenance_page_path"></a> [maintenance\_page\_path](#input\_maintenance\_page\_path) | The path from this directory to the text/html page to use as the maintenance page. Must be within 1024 characters | `string` | `"templates/503_example.html"` | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br>This is the only ID element not also included as a `tag`.<br>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
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
| <a name="output_alb"></a> [alb](#output\_alb) | ALB outputs |
| <a name="output_cluster_arn"></a> [cluster\_arn](#output\_cluster\_arn) | ECS cluster ARN |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | ECS Cluster Name |
| <a name="output_private_subnet_ids"></a> [private\_subnet\_ids](#output\_private\_subnet\_ids) | Private subnet ids |
| <a name="output_public_subnet_ids"></a> [public\_subnet\_ids](#output\_public\_subnet\_ids) | Public subnet ids |
| <a name="output_records"></a> [records](#output\_records) | Record names |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | Security group id |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | VPC ID |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## References

- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/ecs) -
  Cloud Posse's upstream component

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
