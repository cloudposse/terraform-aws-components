# Component: `network-firewall`

This component is responsible for provisioning [AWS Network Firewall](https://aws.amazon.com/network-firewal) resources, 
including Network Firewall, firewall policy, rule groups, and logging configuration.

## Usage

**Stack Level**: Regional

Here's an example snippet for how to use this component.

```yaml
components:
  terraform:
    network-firewall:
      settings:
        spacelift:
          workspace_enabled: true
      vars:
        enabled: true
        name: network-firewall
        # The name of a VPC component where the Network Firewall is provisioned
        vpc_component_name: vpc
        stateful_default_actions:
          - "aws:alert_strict"
        stateless_default_actions:
          - "aws:forward_to_sfe"
        stateless_fragment_default_actions:
          - "aws:forward_to_sfe"
        stateless_custom_actions: []
        delete_protection: false
        firewall_policy_change_protection: false
        subnet_change_protection: false
        logging_config: []
        rule_group_config:
          stateful-packet-inspection:
            capacity: 50
            name: stateful-packet-inspection
            description: "Stateful inspection of packets"
            type: "STATEFUL"
            rule_group:
              stateful_rule_options:
                rule_order: "STRICT_ORDER"
              rules_source:
                stateful_rule:
                  - action: "DROP"
                    header:
                      destination: "124.1.1.24/32"
                      destination_port: 53
                      direction: "ANY"
                      protocol: "TCP"
                      source: "1.2.3.4/32"
                      source_port: 53
                    rule_option:
                      keyword: "sid:1"
                  - action: "PASS"
                    header:
                      destination: "ANY"
                      destination_port: "ANY"
                      direction: "ANY"
                      protocol: "TCP"
                      source: "10.10.192.0/19"
                      source_port: "ANY"
                    rule_option:
                      keyword: "sid:2"
                  - action: "PASS"
                    header:
                      destination: "ANY"
                      destination_port: "ANY"
                      direction: "ANY"
                      protocol: "TCP"
                      source: "10.10.224.0/19"
                      source_port: "ANY"
                    rule_option:
                      keyword: "sid:3"
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.9.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_alert_logs_bucket"></a> [alert\_logs\_bucket](#module\_alert\_logs\_bucket) | cloudposse/stack-config/yaml//modules/remote-state | 1.4.1 |
| <a name="module_flow_logs_bucket"></a> [flow\_logs\_bucket](#module\_flow\_logs\_bucket) | cloudposse/stack-config/yaml//modules/remote-state | 1.4.1 |
| <a name="module_iam_roles"></a> [iam\_roles](#module\_iam\_roles) | ../account-map/modules/iam-roles | n/a |
| <a name="module_network_firewall"></a> [network\_firewall](#module\_network\_firewall) | cloudposse/network-firewall/aws | 0.3.2 |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | cloudposse/stack-config/yaml//modules/remote-state | 1.4.1 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br>This is for some rare cases where resources want additional configuration of tags<br>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_alert_logs_bucket_component_name"></a> [alert\_logs\_bucket\_component\_name](#input\_alert\_logs\_bucket\_component\_name) | Alert logs bucket component name | `string` | `null` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br>in the order they appear in the list. New attributes are appended to the<br>end of the list. The elements of the list are joined by the `delimiter`<br>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "descriptor_formats": {},<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "labels_as_tags": [<br>    "unset"<br>  ],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {},<br>  "tenant": null<br>}</pre> | no |
| <a name="input_delete_protection"></a> [delete\_protection](#input\_delete\_protection) | A boolean flag indicating whether it is possible to delete the firewall | `bool` | `false` | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br>Map of maps. Keys are names of descriptors. Values are maps of the form<br>`{<br>   format = string<br>   labels = list(string)<br>}`<br>(Type is `any` so the map values can later be enhanced to provide additional options.)<br>`format` is a Terraform format string to be passed to the `format()` function.<br>`labels` is a list of labels, in order, to pass to `format()` function.<br>Label values will be normalized before being passed to `format()` so they will be<br>identical to how they appear in `id`.<br>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_firewall_policy_change_protection"></a> [firewall\_policy\_change\_protection](#input\_firewall\_policy\_change\_protection) | A boolean flag indicating whether it is possible to change the associated firewall policy | `bool` | `false` | no |
| <a name="input_firewall_subnet_name"></a> [firewall\_subnet\_name](#input\_firewall\_subnet\_name) | Firewall subnet name | `string` | `"firewall"` | no |
| <a name="input_flow_logs_bucket_component_name"></a> [flow\_logs\_bucket\_component\_name](#input\_flow\_logs\_bucket\_component\_name) | Flow logs bucket component name | `string` | `null` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for keep the existing setting, which defaults to `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_import_profile_name"></a> [import\_profile\_name](#input\_import\_profile\_name) | AWS Profile name to use when importing a resource | `string` | `null` | no |
| <a name="input_import_role_arn"></a> [import\_role\_arn](#input\_import\_role\_arn) | IAM Role ARN to use when importing a resource | `string` | `null` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br>Does not affect keys of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br>set as tag values, and output by this module individually.<br>Does not affect values of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br>Default is to include all labels.<br>Tags with empty values will not be included in the `tags` output.<br>Set to `[]` to suppress all generated tags.<br>**Notes:**<br>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br>  "default"<br>]</pre> | no |
| <a name="input_logging_enabled"></a> [logging\_enabled](#input\_logging\_enabled) | Flag to enable/disable Network Firewall Flow and Alert Logs | `bool` | `false` | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br>This is the only ID element not also included as a `tag`.<br>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_network_firewall_description"></a> [network\_firewall\_description](#input\_network\_firewall\_description) | AWS Network Firewall description. If not provided, the Network Firewall name will be used | `string` | `null` | no |
| <a name="input_network_firewall_name"></a> [network\_firewall\_name](#input\_network\_firewall\_name) | Friendly name to give the Network Firewall. If not provided, the name will be derived from the context.<br>Changing the name will cause the Firewall to be deleted and recreated. | `string` | `null` | no |
| <a name="input_network_firewall_policy_name"></a> [network\_firewall\_policy\_name](#input\_network\_firewall\_policy\_name) | Friendly name to give the Network Firewall policy. If not provided, the name will be derived from the context.<br>Changing the name will cause the policy to be deleted and recreated. | `string` | `null` | no |
| <a name="input_policy_stateful_engine_options_rule_order"></a> [policy\_stateful\_engine\_options\_rule\_order](#input\_policy\_stateful\_engine\_options\_rule\_order) | Indicates how to manage the order of stateful rule evaluation for the policy. Valid values: DEFAULT\_ACTION\_ORDER, STRICT\_ORDER | `string` | `null` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br>Characters matching the regex will be removed from the ID elements.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_rule_group_config"></a> [rule\_group\_config](#input\_rule\_group\_config) | Rule group configuration. Refer to [networkfirewall\_rule\_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_rule_group) for configuration details | `any` | n/a | yes |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_stateful_default_actions"></a> [stateful\_default\_actions](#input\_stateful\_default\_actions) | Default stateful actions | `list(string)` | <pre>[<br>  "aws:alert_strict"<br>]</pre> | no |
| <a name="input_stateless_custom_actions"></a> [stateless\_custom\_actions](#input\_stateless\_custom\_actions) | Set of configuration blocks describing the custom action definitions that are available for use in the firewall policy's `stateless_default_actions` | <pre>list(object({<br>    action_name = string<br>    dimensions  = list(string)<br>  }))</pre> | `[]` | no |
| <a name="input_stateless_default_actions"></a> [stateless\_default\_actions](#input\_stateless\_default\_actions) | Default stateless actions | `list(string)` | <pre>[<br>  "aws:forward_to_sfe"<br>]</pre> | no |
| <a name="input_stateless_fragment_default_actions"></a> [stateless\_fragment\_default\_actions](#input\_stateless\_fragment\_default\_actions) | Default stateless actions for fragmented packets | `list(string)` | <pre>[<br>  "aws:forward_to_sfe"<br>]</pre> | no |
| <a name="input_subnet_change_protection"></a> [subnet\_change\_protection](#input\_subnet\_change\_protection) | A boolean flag indicating whether it is possible to change the associated subnet(s) | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |
| <a name="input_vpc_component_name"></a> [vpc\_component\_name](#input\_vpc\_component\_name) | The name of a VPC component where the Network Firewall is provisioned | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_az_subnet_endpoint_stats"></a> [az\_subnet\_endpoint\_stats](#output\_az\_subnet\_endpoint\_stats) | List of objects with each object having three items: AZ, subnet ID, VPC endpoint ID |
| <a name="output_network_firewall_arn"></a> [network\_firewall\_arn](#output\_network\_firewall\_arn) | Network Firewall ARN |
| <a name="output_network_firewall_name"></a> [network\_firewall\_name](#output\_network\_firewall\_name) | Network Firewall name |
| <a name="output_network_firewall_policy_arn"></a> [network\_firewall\_policy\_arn](#output\_network\_firewall\_policy\_arn) | Network Firewall policy ARN |
| <a name="output_network_firewall_policy_name"></a> [network\_firewall\_policy\_name](#output\_network\_firewall\_policy\_name) | Network Firewall policy name |
| <a name="output_network_firewall_status"></a> [network\_firewall\_status](#output\_network\_firewall\_status) | Nested list of information about the current status of the Network Firewall |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## References

- [Deploy centralized traffic filtering using AWS Network Firewall](https://aws.amazon.com/blogs/networking-and-content-delivery/deploy-centralized-traffic-filtering-using-aws-network-firewall)
- [AWS Network Firewall – New Managed Firewall Service in VPC](https://aws.amazon.com/blogs/aws/aws-network-firewall-new-managed-firewall-service-in-vpc)
- [Deployment models for AWS Network Firewall](https://aws.amazon.com/blogs/networking-and-content-delivery/deployment-models-for-aws-network-firewall)
- [Deployment models for AWS Network Firewall with VPC routing enhancements](https://aws.amazon.com/blogs/networking-and-content-delivery/deployment-models-for-aws-network-firewall-with-vpc-routing-enhancements)
- [Inspection Deployment Models with AWS Network Firewall](https://d1.awsstatic.com/architecture-diagrams/ArchitectureDiagrams/inspection-deployment-models-with-AWS-network-firewall-ra.pdf)
- [How to deploy AWS Network Firewall by using AWS Firewall Manager](https://aws.amazon.com/blogs/security/how-to-deploy-aws-network-firewall-by-using-aws-firewall-manager)
- [A Deep Dive into AWS Transit Gateway](https://www.youtube.com/watch?v=a55Iud-66q0)
- [Appliance in a shared services VPC](https://docs.aws.amazon.com/vpc/latest/tgw/transit-gateway-appliance-scenario.html)
- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/master/modules/TODO) - Cloud Posse's upstream component

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
