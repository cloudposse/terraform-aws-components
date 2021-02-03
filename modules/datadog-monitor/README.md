# Component: `datadog-monitor`

This component is responsible for provisioning global DataDog monitors. It's required that the DataDog API and App secret keys are available in the consuming account at the `var.datadog_api_secret_key` and `var.datadog_app_secret_key` paths in either AWS Secrets Manager or the AWS SSM Parameter Store.

## Usage

**Stack Level**: Regional

Here's an example snippet for how to use this component. This component should only be applied once as the monitors it creates are global across all accounts. By convention, this is typically done via the corp stack (e.g. `uw2-corp.yaml`).

```yaml
components:
  terraform:
    datadog-monitor:
      vars:
        secrets_store_type: ASM
        alert_tags:
          - "@opsgenie-on-call"
          - "@slack-alerts"
        datadog_monitors_config_paths:
          - https://raw.githubusercontent.com/cloudposse/terraform-datadog-monitor/0.11.0/catalog/monitors/ec2.yaml
          - https://raw.githubusercontent.com/cloudposse/terraform-datadog-monitor/0.11.0/catalog/monitors/k8s.yaml
          - https://raw.githubusercontent.com/cloudposse/terraform-datadog-monitor/0.11.0/catalog/monitors/aurora.yaml
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12 |
| aws | >= 2.0 |
| datadog | >= 2.15.0 |
| local | >= 1.3 |
| template | >= 2.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 2.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| additional\_tag\_map | Additional tags for appending to tags\_as\_list\_of\_maps. Not added to `tags`. | `map(string)` | `{}` | no |
| alert\_tags | List of alert tags to add to all alert messages, e.g. `["@opsgenie"]` or `["@devops", "@opsgenie"]` | `list(string)` | `null` | no |
| alert\_tags\_separator | Separator for the alert tags. All strings from the `alert_tags` variable will be joined into one string using the separator and then added to the alert message | `string` | `"\n"` | no |
| attributes | Additional attributes (e.g. `1`) | `list(string)` | `[]` | no |
| context | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | <pre>object({<br>    enabled             = bool<br>    namespace           = string<br>    environment         = string<br>    stage               = string<br>    name                = string<br>    delimiter           = string<br>    attributes          = list(string)<br>    tags                = map(string)<br>    additional_tag_map  = map(string)<br>    regex_replace_chars = string<br>    label_order         = list(string)<br>    id_length_limit     = number<br>  })</pre> | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_order": [],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {}<br>}</pre> | no |
| datadog\_monitors\_config\_paths | List of paths to Datadog monitor configurations | `list(string)` | n/a | yes |
| delimiter | Delimiter to be used between `namespace`, `environment`, `stage`, `name` and `attributes`.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| enabled | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| environment | Environment, e.g. 'uw2', 'us-west-2', OR 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| id\_length\_limit | Limit `id` to this many characters.<br>Set to `0` for unlimited length.<br>Set to `null` for default, which is `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| import\_role\_arn | IAM Role ARN to use when importing a resource | `string` | `null` | no |
| label\_order | The naming order of the id output and Name tag.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 5 elements, but at least one must be present. | `list(string)` | `null` | no |
| name | Solution name, e.g. 'app' or 'jenkins' | `string` | `null` | no |
| namespace | Namespace, which could be your organization name or abbreviation, e.g. 'eg' or 'cp' | `string` | `null` | no |
| regex\_replace\_chars | Regex to replace chars with empty string in `namespace`, `environment`, `stage` and `name`.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| region | AWS Region | `string` | n/a | yes |
| ssm\_parameter\_name\_format | SSM parameter name format | `string` | `"/%s/%s"` | no |
| ssm\_path | SSM path | `string` | `"datadog"` | no |
| stage | Stage, e.g. 'prod', 'staging', 'dev', OR 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| tags | Additional tags (e.g. `map('BusinessUnit','XYZ')` | `map(string)` | `{}` | no |
| tfstate\_account\_id | The ID of the account where the Terraform remote state backend is provisioned | `string` | `""` | no |
| tfstate\_assume\_role | Set to false to use the caller's role to access the Terraform remote state | `bool` | `true` | no |
| tfstate\_bucket\_environment\_name | The name of the environment for Terraform state bucket | `string` | `""` | no |
| tfstate\_bucket\_stage\_name | The name of the stage for Terraform state bucket | `string` | `"root"` | no |
| tfstate\_existing\_role\_arn | The ARN of the existing IAM Role to access the Terraform remote state. If not provided and `remote_state_assume_role` is `true`, a role will be constructed from `remote_state_role_arn_template` | `string` | `""` | no |
| tfstate\_role\_arn\_template | IAM Role ARN template for accessing the Terraform remote state | `string` | `"arn:aws:iam::%s:role/%s-%s-%s-%s"` | no |
| tfstate\_role\_environment\_name | The name of the environment for Terraform state IAM role | `string` | `"gbl"` | no |
| tfstate\_role\_name | IAM Role name for accessing the Terraform remote state | `string` | `"terraform"` | no |
| tfstate\_role\_stage\_name | The name of the stage for Terraform state IAM role | `string` | `"root"` | no |

## Outputs

| Name | Description |
|------|-------------|
| datadog\_monitor\_names | Names of the created Datadog monitors |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


## References
* [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/master/modules/datadog-monitor) - Cloud Posse's upstream component


[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
