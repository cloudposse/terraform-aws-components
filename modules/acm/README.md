---
tags:
  - component/acm
  - layer/network
  - provider/aws
---

# Component: `acm`

This component is responsible for requesting an ACM certificate for a domain and adding a CNAME record to the DNS zone
to complete certificate validation.

The ACM component is to manage an unlimited number of certificates, predominantly for vanity domains. While the
[dns-primary](https://docs.cloudposse.com/components/library/aws/dns-primary) component has the ability to generate ACM
certificates, it is very opinionated and can only manage one zone. In reality, companies have many branded domains
associated with a load balancer, so we need to be able to generate more complicated certificates.

We have, as a convenience, the ability to create an ACM certificate as part of creating a DNS zone, whether primary or
delegated. That convenience is limited to creating `example.com` and `*.example.com` when creating a zone for
`example.com`. For example, Acme has delegated `acct.acme.com` and in addition to `*.acct.acme.com` needed an ACM
certificate for `*.usw2.acct.acme.com`, so we use the ACM component to provision that, rather than extend the DNS
primary or delegated components to take a list of additional certificates. Both are different views on the Single
Responsibility Principle.

## Usage

**Stack Level**: Global or Regional

Here's an example snippet for how to use this component.

```yaml
components:
  terraform:
    acm:
      settings:
        spacelift:
          workspace_enabled: true
      vars:
        enabled: true
        domain_name: acme.com
        process_domain_validation_options: false
        validation_method: DNS
        # NOTE: The following subject alternative name is automatically added by the module.
        #       Additional entries can be added by providing this input.
        # subject_alternative_names:
        #   - "*.acme.com"
```

ACM using a private CA

```yaml
components:
  terraform:
    acm:
      settings:
        spacelift:
          workspace_enabled: true
      vars:
        enabled: true
        domain_name: acme.com
        process_domain_validation_options: false
        dns_private_zone_enabled: true
        certificate_authority_component_name: private-ca-subordinate
        certificate_authority_stage_name: pca
        certificate_authority_environment_name: use2
        certificate_authority_component_key: subordinate
```

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.9.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.9.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_acm"></a> [acm](#module\_acm) | cloudposse/acm-request-certificate/aws | 0.16.3 |
| <a name="module_dns_delegated"></a> [dns\_delegated](#module\_dns\_delegated) | cloudposse/stack-config/yaml//modules/remote-state | 1.5.0 |
| <a name="module_iam_roles"></a> [iam\_roles](#module\_iam\_roles) | ../account-map/modules/iam-roles | n/a |
| <a name="module_private_ca"></a> [private\_ca](#module\_private\_ca) | cloudposse/stack-config/yaml//modules/remote-state | 1.5.0 |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |

## Resources

| Name | Type |
|------|------|
| [aws_ssm_parameter.acm_arn](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_route53_zone.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br>This is for some rare cases where resources want additional configuration of tags<br>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br>in the order they appear in the list. New attributes are appended to the<br>end of the list. The elements of the list are joined by the `delimiter`<br>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_certificate_authority_component_key"></a> [certificate\_authority\_component\_key](#input\_certificate\_authority\_component\_key) | Use this component key e.g. `root` or `mgmt` to read from the remote state to get the certificate\_authority\_arn if using an authority type of SUBORDINATE | `string` | `null` | no |
| <a name="input_certificate_authority_component_name"></a> [certificate\_authority\_component\_name](#input\_certificate\_authority\_component\_name) | Use this component name to read from the remote state to get the certificate\_authority\_arn if using an authority type of SUBORDINATE | `string` | `null` | no |
| <a name="input_certificate_authority_enabled"></a> [certificate\_authority\_enabled](#input\_certificate\_authority\_enabled) | Whether to use the certificate authority or not | `bool` | `false` | no |
| <a name="input_certificate_authority_environment_name"></a> [certificate\_authority\_environment\_name](#input\_certificate\_authority\_environment\_name) | Use this environment name to read from the remote state to get the certificate\_authority\_arn if using an authority type of SUBORDINATE | `string` | `null` | no |
| <a name="input_certificate_authority_stage_name"></a> [certificate\_authority\_stage\_name](#input\_certificate\_authority\_stage\_name) | Use this stage name to read from the remote state to get the certificate\_authority\_arn if using an authority type of SUBORDINATE | `string` | `null` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "descriptor_formats": {},<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "labels_as_tags": [<br>    "unset"<br>  ],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {},<br>  "tenant": null<br>}</pre> | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br>Map of maps. Keys are names of descriptors. Values are maps of the form<br>`{<br>   format = string<br>   labels = list(string)<br>}`<br>(Type is `any` so the map values can later be enhanced to provide additional options.)<br>`format` is a Terraform format string to be passed to the `format()` function.<br>`labels` is a list of labels, in order, to pass to `format()` function.<br>Label values will be normalized before being passed to `format()` so they will be<br>identical to how they appear in `id`.<br>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_dns_delegated_component_name"></a> [dns\_delegated\_component\_name](#input\_dns\_delegated\_component\_name) | Use this component name to read from the remote state to get the dns\_delegated zone ID | `string` | `"dns-delegated"` | no |
| <a name="input_dns_delegated_environment_name"></a> [dns\_delegated\_environment\_name](#input\_dns\_delegated\_environment\_name) | Use this environment name to read from the remote state to get the dns\_delegated zone ID | `string` | `"gbl"` | no |
| <a name="input_dns_delegated_stage_name"></a> [dns\_delegated\_stage\_name](#input\_dns\_delegated\_stage\_name) | Use this stage name to read from the remote state to get the dns\_delegated zone ID | `string` | `null` | no |
| <a name="input_dns_private_zone_enabled"></a> [dns\_private\_zone\_enabled](#input\_dns\_private\_zone\_enabled) | Whether to set the zone to public or private | `bool` | `false` | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | Root domain name | `string` | `""` | no |
| <a name="input_domain_name_prefix"></a> [domain\_name\_prefix](#input\_domain\_name\_prefix) | Root domain name prefix to use with DNS delegated remote state | `string` | `""` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for keep the existing setting, which defaults to `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br>Does not affect keys of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br>set as tag values, and output by this module individually.<br>Does not affect values of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br>Default is to include all labels.<br>Tags with empty values will not be included in the `tags` output.<br>Set to `[]` to suppress all generated tags.<br>**Notes:**<br>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br>  "default"<br>]</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br>This is the only ID element not also included as a `tag`.<br>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_process_domain_validation_options"></a> [process\_domain\_validation\_options](#input\_process\_domain\_validation\_options) | Flag to enable/disable processing of the record to add to the DNS zone to complete certificate validation | `bool` | `false` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br>Characters matching the regex will be removed from the ID elements.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_subject_alternative_names"></a> [subject\_alternative\_names](#input\_subject\_alternative\_names) | A list of domains that should be SANs in the issued certificate | `list(string)` | `[]` | no |
| <a name="input_subject_alternative_names_prefixes"></a> [subject\_alternative\_names\_prefixes](#input\_subject\_alternative\_names\_prefixes) | A list of domain prefixes to use with DNS delegated remote state that should be SANs in the issued certificate | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |
| <a name="input_validation_method"></a> [validation\_method](#input\_validation\_method) | Method to use for validation, DNS or EMAIL | `string` | `"DNS"` | no |
| <a name="input_zone_name"></a> [zone\_name](#input\_zone\_name) | Name of the zone in which to place the DNS validation records to validate the certificate.<br>Typically a domain name. Default of `""` actually defaults to `domain_name`. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the certificate |
| <a name="output_domain_name"></a> [domain\_name](#output\_domain\_name) | Certificate domain name |
| <a name="output_domain_validation_options"></a> [domain\_validation\_options](#output\_domain\_validation\_options) | CNAME records that are added to the DNS zone to complete certificate validation |
| <a name="output_id"></a> [id](#output\_id) | The ID of the certificate |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## References

- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/acm) -
  Cloud Posse's upstream component

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
