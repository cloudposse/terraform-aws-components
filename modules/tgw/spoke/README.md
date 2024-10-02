---
tags:
  - component/tgw/spoke
  - layer/network
  - provider/aws
---

# Component: `tgw/spoke`

This component is responsible for provisioning [AWS Transit Gateway](https://aws.amazon.com/transit-gateway) attachments
to connect VPCs in a `spoke` account to different accounts through a central `hub`.

## Usage

**Stack Level**: Regional

Here's an example snippet for how to configure and use this component:

stacks/catalog/tgw/spoke.yaml

```yaml
components:
  terraform:
    tgw/spoke-defaults:
      metadata:
        type: abstract
        component: tgw/spoke
      vars:
        enabled: true
        name: tgw-spoke
        tags:
          Team: sre
          Service: tgw-spoke
        expose_eks_sg: false
        tgw_hub_tenant_name: core
        tgw_hub_environment_name: ue1

    tgw/spoke:
      metadata:
        inherits:
          - tgw/spoke-defaults
      vars:
        # This is what THIS spoke is allowed to connect to.
        # since this is deployed to each plat account (dev->prod),
        # we allow connections to network and auto.
        connections:
          - account:
              tenant: core
              stage: network
            # Set this value if the vpc component has a different name in this account
            vpc_component_names:
              - vpc-dev
          - account:
              tenant: core
              stage: auto
```

stacks/ue2/dev.yaml

```yaml
import:
  - catalog/tgw/spoke

components:
  terraform:
    tgw/spoke:
      vars:
        # use when there is not an EKS cluster in the stack
        expose_eks_sg: false
        # override default connections
        connections:
          - account:
              tenant: core
              stage: network
            vpc_component_names:
              - vpc-dev
          - account:
              tenant: core
              stage: auto
          - account:
              tenant: plat
              stage: dev
            eks_component_names:
              - eks/cluster
          - account:
              tenant: plat
              stage: qa
            eks_component_names:
              - eks/cluster
```

To provision the attachments for a spoke account:

```sh
atmos terraform plan tgw/spoke -s <tenant>-<environment>-<stage>
atmos terraform apply tgw/spoke -s <tenant>-<environment>-<stage>
```

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.1 |
| <a name="provider_aws.tgw-hub"></a> [aws.tgw-hub](#provider\_aws.tgw-hub) | >= 4.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cross_region_hub_connector"></a> [cross\_region\_hub\_connector](#module\_cross\_region\_hub\_connector) | cloudposse/stack-config/yaml//modules/remote-state | 1.5.0 |
| <a name="module_iam_roles"></a> [iam\_roles](#module\_iam\_roles) | ../../account-map/modules/iam-roles | n/a |
| <a name="module_tgw_hub"></a> [tgw\_hub](#module\_tgw\_hub) | cloudposse/stack-config/yaml//modules/remote-state | 1.5.0 |
| <a name="module_tgw_hub_role"></a> [tgw\_hub\_role](#module\_tgw\_hub\_role) | ../../account-map/modules/iam-roles | n/a |
| <a name="module_tgw_hub_routes"></a> [tgw\_hub\_routes](#module\_tgw\_hub\_routes) | cloudposse/transit-gateway/aws | 0.10.0 |
| <a name="module_tgw_spoke_vpc_attachment"></a> [tgw\_spoke\_vpc\_attachment](#module\_tgw\_spoke\_vpc\_attachment) | ./modules/standard_vpc_attachment | n/a |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | cloudposse/stack-config/yaml//modules/remote-state | 1.5.0 |

## Resources

| Name | Type |
|------|------|
| [aws_route.back_route](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.default_route](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br>This is for some rare cases where resources want additional configuration of tags<br>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br>in the order they appear in the list. New attributes are appended to the<br>end of the list. The elements of the list are joined by the `delimiter`<br>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_connections"></a> [connections](#input\_connections) | A list of objects to define each TGW connections.<br><br>By default, each connection will look for only the default `vpc` component. | <pre>list(object({<br>    account = object({<br>      stage       = string<br>      environment = optional(string, "")<br>      tenant      = optional(string, "")<br>    })<br>    vpc_component_names = optional(list(string), ["vpc"])<br>    eks_component_names = optional(list(string), [])<br>  }))</pre> | `[]` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "descriptor_formats": {},<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "labels_as_tags": [<br>    "unset"<br>  ],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {},<br>  "tenant": null<br>}</pre> | no |
| <a name="input_cross_region_hub_connector_components"></a> [cross\_region\_hub\_connector\_components](#input\_cross\_region\_hub\_connector\_components) | A map of cross-region hub connector components that provide this spoke with the appropriate Transit Gateway attachments IDs.<br>- The key should be the environment that the remote VPC is located in.<br>- The component is the name of the component in the remote region (e.g. `tgw/cross-region-hub-connector`)<br>- The environment is the region that the cross-region-hub-connector is deployed in.<br>e.g. the following would configure a component called `tgw/cross-region-hub-connector/use1` that is deployed in the<br>If use2 is the primary region, the following would be its configuration:<br>use1:<br>  component: "tgw/cross-region-hub-connector"<br>  environment: "use1" (the remote region)<br>and in the alternate region, the following would be its configuration:<br>use2:<br>  component: "tgw/cross-region-hub-connector"<br>  environment: "use1" (our own region) | `map(object({ component = string, environment = string }))` | `{}` | no |
| <a name="input_default_route_enabled"></a> [default\_route\_enabled](#input\_default\_route\_enabled) | Enable default routing via transit gateway, requires also nat gateway and instance to be disabled in vpc component. Default is disabled. | `bool` | `false` | no |
| <a name="input_default_route_outgoing_account_name"></a> [default\_route\_outgoing\_account\_name](#input\_default\_route\_outgoing\_account\_name) | The account name which is used for outgoing traffic, when using the transit gateway as default route. | `string` | `null` | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br>Map of maps. Keys are names of descriptors. Values are maps of the form<br>`{<br>   format = string<br>   labels = list(string)<br>}`<br>(Type is `any` so the map values can later be enhanced to provide additional options.)<br>`format` is a Terraform format string to be passed to the `format()` function.<br>`labels` is a list of labels, in order, to pass to `format()` function.<br>Label values will be normalized before being passed to `format()` so they will be<br>identical to how they appear in `id`.<br>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_expose_eks_sg"></a> [expose\_eks\_sg](#input\_expose\_eks\_sg) | Set true to allow EKS clusters to accept traffic from source accounts | `bool` | `true` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for keep the existing setting, which defaults to `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br>Does not affect keys of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br>set as tag values, and output by this module individually.<br>Does not affect values of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br>Default is to include all labels.<br>Tags with empty values will not be included in the `tags` output.<br>Set to `[]` to suppress all generated tags.<br>**Notes:**<br>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br>  "default"<br>]</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br>This is the only ID element not also included as a `tag`.<br>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_own_eks_component_names"></a> [own\_eks\_component\_names](#input\_own\_eks\_component\_names) | The name of the eks components in the owning account. | `list(string)` | `[]` | no |
| <a name="input_own_vpc_component_name"></a> [own\_vpc\_component\_name](#input\_own\_vpc\_component\_name) | The name of the vpc component in the owning account. Defaults to "vpc" | `string` | `"vpc"` | no |
| <a name="input_peered_region"></a> [peered\_region](#input\_peered\_region) | Set `true` if this region is not the primary region | `bool` | `false` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br>Characters matching the regex will be removed from the ID elements.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_static_routes"></a> [static\_routes](#input\_static\_routes) | A list of static routes to add to the transit gateway, pointing at this VPC as a destination. | <pre>set(object({<br>    blackhole              = bool<br>    destination_cidr_block = string<br>  }))</pre> | `[]` | no |
| <a name="input_static_tgw_routes"></a> [static\_tgw\_routes](#input\_static\_tgw\_routes) | A list of static routes to add to the local routing table with the transit gateway as a destination. | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |
| <a name="input_tgw_hub_component_name"></a> [tgw\_hub\_component\_name](#input\_tgw\_hub\_component\_name) | The name of the transit-gateway component | `string` | `"tgw/hub"` | no |
| <a name="input_tgw_hub_stage_name"></a> [tgw\_hub\_stage\_name](#input\_tgw\_hub\_stage\_name) | The name of the stage where `tgw/hub` is provisioned | `string` | `"network"` | no |
| <a name="input_tgw_hub_tenant_name"></a> [tgw\_hub\_tenant\_name](#input\_tgw\_hub\_tenant\_name) | The name of the tenant where `tgw/hub` is provisioned.<br><br>If the `tenant` label is not used, leave this as `null`. | `string` | `null` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## References

- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/tgw) -
  Cloud Posse's upstream component

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
