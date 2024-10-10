---
tags:
  - component/runs-on
  - layer/github
  - provider/aws
---

# Component: `runs-on`

This component is responsible for provisioning an RunsOn (https://runs-on.com/).

After deploying this component, you will need to install the RunsOn app to GitHub. See the
[RunsOn documentation](https://runs-on.com/guides/install/#3-github-app-registration) for more information.

## Usage

**Stack Level**: Regional

The following is an example snippet for how to use this component:

(`runs-on.yaml`)

```yaml
import:
  - orgs/acme/core/auto/_defaults
  - mixins/region/us-east-1

components:
  terraform:
    runs-on:
      metadata:
        component: runs-on
      vars:
        name: runs-on
        enabled: true
        capabilities: ["CAPABILITY_IAM"]
        on_failure: "ROLLBACK"
        timeout_in_minutes: 30
        template_url: https://runs-on.s3.eu-west-1.amazonaws.com/cloudformation/template.yaml
        parameters:
          AppCPU: 512
          AppMemory: 1024
          EmailAddress: devops@acme.com
          Environment: core-auto
          GithubOrganization: ACME
          LicenseKey: <LICENSE>
          Private: always # always | true | false - Always will default place in private subnet, true will place in private subnet if tag `private=true` present on workflow, false will place in public subnet
          VpcCidrBlock: 10.100.0.0/16
```

### Setting up with Transit Gateway

This assumes you are using the Cloud Posse Components for Transit Gateway
([tgw/hub](https://docs.cloudposse.com/components/library/aws/tgw/hub/) &
[tgw/spoke](https://docs.cloudposse.com/components/library/aws/tgw/spoke/)).

The outputs of this component contain the same outputs as the `vpc` component. This is because the runs-on
cloudformation stack creates a VPC and subnets.

First we need to update the TGW/Hub - this stores information about the VPCs that are allowed to be used by TGW Spokes.

Assuming your TGW/Hub lives in the `core-network` account and your Runs-On is deployed to `core-auto` (`tgw-hub.yaml`)

```yaml
vars:
  connections:
    - account:
        tenant: core
        stage: auto
      vpc_component_names:
        - vpc
        - runs-on
```

<details><summary>Click to show full stack configuration</summary>

```yaml
components:
terraform:
  tgw/hub/defaults:
    metadata:
      type: abstract
      component: tgw/hub
    vars:
      enabled: true
      name: tgw-hub
      tags:
        Team: sre
        Service: tgw-hub

  tgw/hub:
    metadata:
      inherits:
        - tgw/hub/defaults
      component: tgw/hub
    vars:
      connections:
        - account:
            tenant: core
            stage: network
        - account:
            tenant: core
            stage: auto
          vpc_component_names:
            - vpc
            - runs-on
        - account:
            tenant: plat
            stage: sandbox
        - account:
            tenant: plat
            stage: dev
        - account:
            tenant: plat
            stage: staging
        - account:
            tenant: plat
            stage: prod
```

We then need to create a spoke that refers to the VPC created by Runs-On.

(`tgw-spoke.yaml`)

```yaml
tgw/spoke/runs-on:
  metadata:
    component: tgw/spoke
    inherits:
      - tgw/spoke-defaults
  vars:
    own_vpc_component_name: runs-on
    attributes:
      - "runs-on"
    connections:
      - account:
          tenant: core
          stage: network
      - account:
          tenant: core
          stage: auto
        vpc_component_names:
          - vpc
          - runs-on
      - account:
          tenant: plat
          stage: sandbox
      - account:
          tenant: plat
          stage: dev
      - account:
          tenant: plat
          stage: staging
      - account:
          tenant: plat
          stage: prod
```

Finally we need to update the spokes of the TGW/Spokes to allow Runs-On traffic to the other accounts.

Typically this includes `core-auto`, `core-network`, and your platform accounts.

(`tgw-spoke.yaml`)

```yaml
  tgw/spoke:
    metadata:
      inherits:
        - tgw/spoke-defaults
    vars:
      connections:
        ...
            vpc_component_names:
              - vpc
              - runs-on
        ...
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
| <a name="module_cloudformation_stack"></a> [cloudformation\_stack](#module\_cloudformation\_stack) | cloudposse/cloudformation-stack/aws | v0.7.1 |
| <a name="module_iam_policy"></a> [iam\_policy](#module\_iam\_policy) | cloudposse/iam-policy/aws | v2.0.1 |
| <a name="module_iam_roles"></a> [iam\_roles](#module\_iam\_roles) | ../account-map/modules/iam-roles | n/a |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | cloudposse/stack-config/yaml//modules/remote-state | 1.5.0 |

## Resources

| Name | Type |
|------|------|
| [aws_nat_gateways.ngws](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/nat_gateways) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br/>This is for some rare cases where resources want additional configuration of tags<br/>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br/>in the order they appear in the list. New attributes are appended to the<br/>end of the list. The elements of the list are joined by the `delimiter`<br/>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_capabilities"></a> [capabilities](#input\_capabilities) | A list of capabilities. Valid values: CAPABILITY\_IAM, CAPABILITY\_NAMED\_IAM, CAPABILITY\_AUTO\_EXPAND | `list(string)` | `[]` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br/>See description of individual variables for details.<br/>Leave string and numeric variables as `null` to use default value.<br/>Individual variable settings (non-null) override settings in context object,<br/>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br/>  "additional_tag_map": {},<br/>  "attributes": [],<br/>  "delimiter": null,<br/>  "descriptor_formats": {},<br/>  "enabled": true,<br/>  "environment": null,<br/>  "id_length_limit": null,<br/>  "label_key_case": null,<br/>  "label_order": [],<br/>  "label_value_case": null,<br/>  "labels_as_tags": [<br/>    "unset"<br/>  ],<br/>  "name": null,<br/>  "namespace": null,<br/>  "regex_replace_chars": null,<br/>  "stage": null,<br/>  "tags": {},<br/>  "tenant": null<br/>}</pre> | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br/>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br/>Map of maps. Keys are names of descriptors. Values are maps of the form<br/>`{<br/>   format = string<br/>   labels = list(string)<br/>}`<br/>(Type is `any` so the map values can later be enhanced to provide additional options.)<br/>`format` is a Terraform format string to be passed to the `format()` function.<br/>`labels` is a list of labels, in order, to pass to `format()` function.<br/>Label values will be normalized before being passed to `format()` so they will be<br/>identical to how they appear in `id`.<br/>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br/>Set to `0` for unlimited length.<br/>Set to `null` for keep the existing setting, which defaults to `0`.<br/>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br/>Does not affect keys of tags passed in via the `tags` input.<br/>Possible values: `lower`, `title`, `upper`.<br/>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br/>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br/>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br/>set as tag values, and output by this module individually.<br/>Does not affect values of tags passed in via the `tags` input.<br/>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br/>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br/>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br/>Default is to include all labels.<br/>Tags with empty values will not be included in the `tags` output.<br/>Set to `[]` to suppress all generated tags.<br/>**Notes:**<br/>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br/>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br/>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br/>  "default"<br/>]</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br/>This is the only ID element not also included as a `tag`.<br/>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_on_failure"></a> [on\_failure](#input\_on\_failure) | Action to be taken if stack creation fails. This must be one of: `DO_NOTHING`, `ROLLBACK`, or `DELETE` | `string` | `"ROLLBACK"` | no |
| <a name="input_parameters"></a> [parameters](#input\_parameters) | Key-value map of input parameters for the Stack Set template. (\_e.g.\_ map("BusinessUnit","ABC") | `map(string)` | `{}` | no |
| <a name="input_policy_body"></a> [policy\_body](#input\_policy\_body) | Structure containing the stack policy body | `string` | `""` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br/>Characters matching the regex will be removed from the ID elements.<br/>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br/>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_template_url"></a> [template\_url](#input\_template\_url) | Amazon S3 bucket URL location of a file containing the CloudFormation template body. Maximum file size: 460,800 bytes | `string` | n/a | yes |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |
| <a name="input_timeout_in_minutes"></a> [timeout\_in\_minutes](#input\_timeout\_in\_minutes) | The amount of time that can pass before the stack status becomes `CREATE_FAILED` | `number` | `30` | no |
| <a name="input_vpc_peering_component"></a> [vpc\_peering\_component](#input\_vpc\_peering\_component) | The component name of the VPC Peering Connection | <pre>object({<br/>    component   = string<br/>    environment = optional(string)<br/>    tenant      = optional(string)<br/>    stage       = optional(string)<br/>  })</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | ID of the CloudFormation Stack |
| <a name="output_name"></a> [name](#output\_name) | Name of the CloudFormation Stack |
| <a name="output_nat_gateway_ids"></a> [nat\_gateway\_ids](#output\_nat\_gateway\_ids) | NAT Gateway IDs |
| <a name="output_nat_instance_ids"></a> [nat\_instance\_ids](#output\_nat\_instance\_ids) | NAT Instance IDs |
| <a name="output_outputs"></a> [outputs](#output\_outputs) | Outputs of the CloudFormation Stack |
| <a name="output_private_route_table_ids"></a> [private\_route\_table\_ids](#output\_private\_route\_table\_ids) | Private subnet route table IDs |
| <a name="output_private_subnet_ids"></a> [private\_subnet\_ids](#output\_private\_subnet\_ids) | Private subnet IDs |
| <a name="output_public_subnet_ids"></a> [public\_subnet\_ids](#output\_public\_subnet\_ids) | Public subnet IDs |
| <a name="output_vpc_cidr"></a> [vpc\_cidr](#output\_vpc\_cidr) | CIDR of the VPC created by RunsOn CloudFormation Stack |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | ID of the VPC created by RunsOn CloudFormation Stack |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## References

- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/cloudtrail) -
  Cloud Posse's upstream component

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
