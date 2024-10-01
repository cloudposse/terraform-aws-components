---
tags:
  - component/account-quotas
  - layer/foundation
  - provider/aws
---

# Component: `account-quotas`

This component is responsible for requesting service quota increases. We recommend making requests here rather than in
`account-settings` because `account-settings` is a restricted component that can only be applied by SuperAdmin.

## Usage

**Stack Level**: Global and Regional (depending on quota)

Global resources must be provisioned in `us-east-1`. Put them in the `gbl` stack, but set `region: us-east-1` in the
`vars` section.

You can refer to services either by their exact full name (e.g.
`service_name: "Amazon Elastic Compute Cloud (Amazon EC2)"`) or by the service code (e.g. `service_code: "ec2"`).
Similarly, you can refer to quota names either by their exact full name (e.g. `quota_name: "EC2-VPC Elastic IPs"`) or by
the quota code (e.g. `quota_code: "L-0263D0A3"`).

You can find service codes and full names via the AWS CLI (be sure to use the correct region):

```bash
aws --region us-east-1 service-quotas list-services
```

You can find quota codes and full names, and also whether the quotas are adjustable or global, via the AWS CLI, but you
will need the service code from the previous step:

```bash
aws --region us-east-1 service-quotas list-service-quotas --service-code ec2
```

If you make a request to raise a quota, the output will show the requested value as `value` while the request is
pending.

### Special usage Notes

Even though the Terraform will submit the support request, you may need to follow up with AWS support to get the request
approved, via the AWS console or email.

#### Resources are destroyed on change

Because the AWS API often returns default values rather than configured or applicable values for a given quota, we have
to ignore the value returned by the API or else face perpetual drift. To allow us to change the value in the future,
even though we are ignoring it, we encode the value in the resource key, so that a change of value will result in a new
resource being created and the old one being destroyed. Destroying the old resource has no actual effect (it does not
even close an open request), so it is safe to do.

### Example

Here's an example snippet for how to use this component.

```yaml
components:
  terraform:
    account-quotas:
      vars:
        quotas:
          vpcs-per-region:
            service_code: vpc
            quota_name: "VPCs per Region"
            value: 10
          vpc-elastic-ips:
            service_code: ec2
            quota_name: "EC2-VPC Elastic IPs"
            value: 10
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
| <a name="module_iam_roles"></a> [iam\_roles](#module\_iam\_roles) | ../account-map/modules/iam-roles | n/a |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |

## Resources

| Name | Type |
|------|------|
| [aws_servicequotas_service_quota.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/servicequotas_service_quota) | resource |
| [aws_servicequotas_service.by_name](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/servicequotas_service) | data source |
| [aws_servicequotas_service_quota.by_name](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/servicequotas_service_quota) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br>This is for some rare cases where resources want additional configuration of tags<br>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br>in the order they appear in the list. New attributes are appended to the<br>end of the list. The elements of the list are joined by the `delimiter`<br>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "descriptor_formats": {},<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "labels_as_tags": [<br>    "unset"<br>  ],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {},<br>  "tenant": null<br>}</pre> | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br>Map of maps. Keys are names of descriptors. Values are maps of the form<br>`{<br>   format = string<br>   labels = list(string)<br>}`<br>(Type is `any` so the map values can later be enhanced to provide additional options.)<br>`format` is a Terraform format string to be passed to the `format()` function.<br>`labels` is a list of labels, in order, to pass to `format()` function.<br>Label values will be normalized before being passed to `format()` so they will be<br>identical to how they appear in `id`.<br>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for keep the existing setting, which defaults to `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br>Does not affect keys of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br>set as tag values, and output by this module individually.<br>Does not affect values of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br>Default is to include all labels.<br>Tags with empty values will not be included in the `tags` output.<br>Set to `[]` to suppress all generated tags.<br>**Notes:**<br>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br>  "default"<br>]</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br>This is the only ID element not also included as a `tag`.<br>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_quotas"></a> [quotas](#input\_quotas) | Map of quotas to set. Map keys are arbitrary and are used to allow Atmos to merge configurations.<br>Delete an inherited quota by setting its key's value to null.<br>You only need to provide one of either name or code for each of "service" and "quota".<br>If you provide both, the code will be used. | <pre>map(object({<br>    service_name = optional(string)<br>    service_code = optional(string)<br>    quota_name   = optional(string)<br>    quota_code   = optional(string)<br>    value        = number<br>  }))</pre> | `{}` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br>Characters matching the regex will be removed from the ID elements.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_quotas"></a> [quotas](#output\_quotas) | Full report on all service quotas managed by this component. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## References

- [AWS Service Quotas](https://docs.aws.amazon.com/general/latest/gr/aws_service_limits.html)
- AWS CLI
  [command to list service codes](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/service-quotas/list-services.html):
  `aws service-quotas list-services`
- AWS CLI
  [command to list service quotas](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/service-quotas/list-service-quotas.html)
  `aws service-quotas list-service-quotas`. Note where it says "For some quotas, only the default values are available."
- [Medium article](https://medium.com/@jsonk/the-limit-does-not-exist-hidden-visibility-of-aws-service-limits-4b786f846bc0)
  explaining how many AWS service limits are not available.

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
