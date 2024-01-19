# Component: `aws-shield`

This component is responsible for enabling AWS Shield Advanced Protection for the following resources:

* Application Load Balancers (ALBs)
* CloudFront Distributions
* Elastic IPs
* Route53 Hosted Zones

This component assumes that resources it is configured to protect are not already protected by other components
that have their `xxx_aws_shield_protection_enabled` variable set to `true`.

This component also requires that the account where the component is being provisioned to has
been [subscribed to AWS Shield Advanced](https://docs.aws.amazon.com/waf/latest/developerguide/enable-ddos-prem.html).

## Usage

**Stack Level**: Global or Regional

The following snippet shows how to use all of this component's features in a stack configuration:

```yaml
components:
  terraform:
    aws-shield:
      settings:
        spacelift:
          workspace_enabled: true
      vars:
        enabled: true
        route53_zone_names:
          - test.ue1.example.net
        alb_names:
          - k8s-common-2c5f23ff99
        cloudfront_distribution_ids:
          - EDFDVBD632BHDS5
        eips:
          - 3.214.128.240
          - 35.172.208.150
          - 35.171.70.50
```

A typical global configuration will only include the `route53_zone_names` and `cloudfront_distribution_ids` variables,
as global Route53 Hosted Zones may exist in that account, and because CloudFront is a global AWS service.

A global stack configuration will not have a VPC, and hence `alb_names` and `eips` should not be defined:

```yaml
components:
  terraform:
    aws-shield:
      settings:
        spacelift:
          workspace_enabled: true
      vars:
        enabled: true
        route53_zone_names:
          - test.example.net
        cloudfront_distribution_ids:
          - EDFDVBD632BHDS5
```

Regional stack configurations will typically make use of all resources except for `cloudfront_distribution_ids`:

```yaml
components:
  terraform:
    aws-shield:
      settings:
        spacelift:
          workspace_enabled: true
      vars:
        route53_zone_names:
          - test.ue1.example.net
        alb_names:
          - k8s-common-2c5f23ff99
        eips:
          - 3.214.128.240
          - 35.172.208.150
          - 35.171.70.50
```

Stack configurations which rely on components with a `xxx_aws_shield_protection_enabled` variable should set that variable to `true`
and leave the corresponding variable for this component as empty, relying on that component's AWS Shield Advanced functionality instead.
This leads to more simplified inter-component dependencies and minimizes the need for maintaining the provisioning order during a cold-start.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_alb"></a> [alb](#module\_alb) | cloudposse/stack-config/yaml//modules/remote-state | 1.5.0 |
| <a name="module_iam_roles"></a> [iam\_roles](#module\_iam\_roles) | ../account-map/modules/iam-roles | n/a |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |

## Resources

| Name | Type |
|------|------|
| [aws_shield_protection.alb_shield_protection](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/shield_protection) | resource |
| [aws_shield_protection.cloudfront_shield_protection](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/shield_protection) | resource |
| [aws_shield_protection.eip_shield_protection](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/shield_protection) | resource |
| [aws_shield_protection.route53_zone_protection](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/shield_protection) | resource |
| [aws_alb.alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/alb) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_cloudfront_distribution.cloudfront_distribution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/cloudfront_distribution) | data source |
| [aws_eip.eip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eip) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_route53_zone.route53_zone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br>This is for some rare cases where resources want additional configuration of tags<br>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_alb_names"></a> [alb\_names](#input\_alb\_names) | list of ALB names which will be protected with AWS Shield Advanced | `list(string)` | `[]` | no |
| <a name="input_alb_protection_enabled"></a> [alb\_protection\_enabled](#input\_alb\_protection\_enabled) | Enable ALB protection. By default, ALB names are read from the EKS cluster ALB control group | `bool` | `false` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br>in the order they appear in the list. New attributes are appended to the<br>end of the list. The elements of the list are joined by the `delimiter`<br>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_cloudfront_distribution_ids"></a> [cloudfront\_distribution\_ids](#input\_cloudfront\_distribution\_ids) | list of CloudFront Distribution IDs which will be protected with AWS Shield Advanced | `list(string)` | `[]` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "descriptor_formats": {},<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "labels_as_tags": [<br>    "unset"<br>  ],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {},<br>  "tenant": null<br>}</pre> | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br>Map of maps. Keys are names of descriptors. Values are maps of the form<br>`{<br>   format = string<br>   labels = list(string)<br>}`<br>(Type is `any` so the map values can later be enhanced to provide additional options.)<br>`format` is a Terraform format string to be passed to the `format()` function.<br>`labels` is a list of labels, in order, to pass to `format()` function.<br>Label values will be normalized before being passed to `format()` so they will be<br>identical to how they appear in `id`.<br>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_eips"></a> [eips](#input\_eips) | List of Elastic IPs which will be protected with AWS Shield Advanced | `list(string)` | `[]` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for keep the existing setting, which defaults to `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br>Does not affect keys of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br>set as tag values, and output by this module individually.<br>Does not affect values of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br>Default is to include all labels.<br>Tags with empty values will not be included in the `tags` output.<br>Set to `[]` to suppress all generated tags.<br>**Notes:**<br>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br>  "default"<br>]</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br>This is the only ID element not also included as a `tag`.<br>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br>Characters matching the regex will be removed from the ID elements.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_route53_zone_names"></a> [route53\_zone\_names](#input\_route53\_zone\_names) | List of Route53 Hosted Zone names which will be protected with AWS Shield Advanced | `list(string)` | `[]` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_application_load_balancer_protections"></a> [application\_load\_balancer\_protections](#output\_application\_load\_balancer\_protections) | AWS Shield Advanced Protections for ALBs |
| <a name="output_cloudfront_distribution_protections"></a> [cloudfront\_distribution\_protections](#output\_cloudfront\_distribution\_protections) | AWS Shield Advanced Protections for CloudFront Distributions |
| <a name="output_elastic_ip_protections"></a> [elastic\_ip\_protections](#output\_elastic\_ip\_protections) | AWS Shield Advanced Protections for Elastic IPs |
| <a name="output_route53_hosted_zone_protections"></a> [route53\_hosted\_zone\_protections](#output\_route53\_hosted\_zone\_protections) | AWS Shield Advanced Protections for Route53 Hosted Zones |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## References

* [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/aws-shield) - Cloud Posse's upstream component

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
