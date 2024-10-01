# Component: `cross-region-spoke`

This component is responsible for provisioning an [AWS Transit Gateway Attachment](https://aws.amazon.com/transit-gateway) to connect VPCs from different accounts and/or regions through a central hub.

## Usage

**Stack Level**: Regional

This component is deployed after the `spoke` component. It is deployed in the same region as a `cross-region-hub-connector` and points to your default (`home`) region.

e.g. if you primarily deploy to us-east-1, and this is a connection to us-east-2, this component would be deployed to us-east-2 pointing to us-east-1 in the `home_region`.

Here's an example snippet for how to configure and use this component:


```yaml
components:
  terraform:
    tgw/cross-region-spoke:
      vars:
        enabled: true
        account_map_tenant_name: core
        this_region:
          tgw_stage_name: network
          tgw_tenant_name: core
          connections:
            - platform-dev
        home_region:
          connections:
            - core-corp
            - core-automation
            - platform-dev
          tgw_name_format: "%s-%s"
          tgw_stage_name: network
          tgw_tenant_name: core
          region: us-east-1

```


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_account_map"></a> [account\_map](#module\_account\_map) | cloudposse/stack-config/yaml//modules/remote-state | 1.4.1 |
| <a name="module_az_abbreviation"></a> [az\_abbreviation](#module\_az\_abbreviation) | cloudposse/utils/aws | 1.0.0 |
| <a name="module_iam_role_tgw_home_region"></a> [iam\_role\_tgw\_home\_region](#module\_iam\_role\_tgw\_home\_region) | ../../account-map/modules/iam-roles | n/a |
| <a name="module_iam_role_tgw_this_region"></a> [iam\_role\_tgw\_this\_region](#module\_iam\_role\_tgw\_this\_region) | ../../account-map/modules/iam-roles | n/a |
| <a name="module_iam_roles"></a> [iam\_roles](#module\_iam\_roles) | ../../account-map/modules/iam-roles | n/a |
| <a name="module_tgw_cross_region_connector"></a> [tgw\_cross\_region\_connector](#module\_tgw\_cross\_region\_connector) | cloudposse/stack-config/yaml//modules/remote-state | 1.4.1 |
| <a name="module_tgw_home_region"></a> [tgw\_home\_region](#module\_tgw\_home\_region) | cloudposse/stack-config/yaml//modules/remote-state | 1.4.1 |
| <a name="module_tgw_routes_home_region"></a> [tgw\_routes\_home\_region](#module\_tgw\_routes\_home\_region) | ./modules/tgw_routes | n/a |
| <a name="module_tgw_routes_this_region"></a> [tgw\_routes\_this\_region](#module\_tgw\_routes\_this\_region) | ./modules/tgw_routes | n/a |
| <a name="module_tgw_this_region"></a> [tgw\_this\_region](#module\_tgw\_this\_region) | cloudposse/stack-config/yaml//modules/remote-state | 1.4.1 |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |
| <a name="module_vpc_routes_home"></a> [vpc\_routes\_home](#module\_vpc\_routes\_home) | ./modules/vpc_routes | n/a |
| <a name="module_vpc_routes_this"></a> [vpc\_routes\_this](#module\_vpc\_routes\_this) | ./modules/vpc_routes | n/a |
| <a name="module_vpcs_home_region"></a> [vpcs\_home\_region](#module\_vpcs\_home\_region) | cloudposse/stack-config/yaml//modules/remote-state | 1.4.1 |
| <a name="module_vpcs_this_region"></a> [vpcs\_this\_region](#module\_vpcs\_this\_region) | cloudposse/stack-config/yaml//modules/remote-state | 1.4.1 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_map_tenant_name"></a> [account\_map\_tenant\_name](#input\_account\_map\_tenant\_name) | The name of the tenant where `account_map` is provisioned.<br><br>If the `tenant` label is not used, leave this as `null`. | `string` | `null` | no |
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br>This is for some rare cases where resources want additional configuration of tags<br>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br>in the order they appear in the list. New attributes are appended to the<br>end of the list. The elements of the list are joined by the `delimiter`<br>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_aws_region_abbreviation"></a> [aws\_region\_abbreviation](#input\_aws\_region\_abbreviation) | AWS Region Abbreviation method, must be one of: `to_fixed`, `to_short`, `from_fixed`, `from_short`, `identity` | `string` | n/a | yes |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "descriptor_formats": {},<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "labels_as_tags": [<br>    "unset"<br>  ],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {},<br>  "tenant": null<br>}</pre> | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br>Map of maps. Keys are names of descriptors. Values are maps of the form<br>`{<br>   format = string<br>   labels = list(string)<br>}`<br>(Type is `any` so the map values can later be enhanced to provide additional options.)<br>`format` is a Terraform format string to be passed to the `format()` function.<br>`labels` is a list of labels, in order, to pass to `format()` function.<br>Label values will be normalized before being passed to `format()` so they will be<br>identical to how they appear in `id`.<br>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_home_region"></a> [home\_region](#input\_home\_region) | Acceptors region config. Describe the transit gateway that should accept the peering | <pre>object({<br>    connections     = set(string)<br>    tgw_name_format = string<br>    tgw_stage_name  = string<br>    tgw_tenant_name = string<br>    region          = string<br>  })</pre> | n/a | yes |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for keep the existing setting, which defaults to `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_import_profile_name"></a> [import\_profile\_name](#input\_import\_profile\_name) | AWS Profile name to use when importing a resource | `string` | `null` | no |
| <a name="input_import_role_arn"></a> [import\_role\_arn](#input\_import\_role\_arn) | IAM Role ARN to use when importing a resource | `string` | `null` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br>Does not affect keys of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br>set as tag values, and output by this module individually.<br>Does not affect values of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br>Default is to include all labels.<br>Tags with empty values will not be included in the `tags` output.<br>Set to `[]` to suppress all generated tags.<br>**Notes:**<br>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br>  "default"<br>]</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br>This is the only ID element not also included as a `tag`.<br>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br>Characters matching the regex will be removed from the ID elements.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |
| <a name="input_this_region"></a> [this\_region](#input\_this\_region) | Initiators region config. Describe the transit gateway that should originate the peering | <pre>object({<br>    connections     = set(string)<br>    tgw_stage_name  = string<br>    tgw_tenant_name = string<br>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_tgw_routes_home_region"></a> [tgw\_routes\_home\_region](#output\_tgw\_routes\_home\_region) | TGW Routes to the primary region |
| <a name="output_tgw_routes_in_region"></a> [tgw\_routes\_in\_region](#output\_tgw\_routes\_in\_region) | TGW routes in this region |
| <a name="output_vpc_routes_home"></a> [vpc\_routes\_home](#output\_vpc\_routes\_home) | VPC routes to the primary VPC |
| <a name="output_vpc_routes_this"></a> [vpc\_routes\_this](#output\_vpc\_routes\_this) | This modules VPC routes |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## References

- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/master/modules/TODO) - Cloud Posse's upstream component

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
