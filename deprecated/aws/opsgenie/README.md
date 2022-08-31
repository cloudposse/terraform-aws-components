# Component: `opsgenie`

Terraform component to provision [Opsgenie resources](https://registry.terraform.io/providers/opsgenie/opsgenie/latest/docs).

## Usage

**Stack Level**: Global

Here's an example snippet for how to use this component. For more information use these resources:

1. See the [detailed usage](./detailed-usage.md) documentation for the full breakdown in usage.
1. View the [Cloud Posse opsgenie module's example configuration](https://github.com/cloudposse/terraform-opsgenie-incident-management/tree/master/examples/config/resources) for a more complete example.

```yaml
components:
  terraform:
    opsgenie:
      vars:
        teams:
        - name: acme
          description: Global Team for Acme Co.
          members:
            username: opsgenie-test@cloudposse.com
            role: admin
        - name: acme.dev
          description: Acme Dev Team
          delete_default_resources: true
          members:
            username: opsgenie-test@cloudposse.com
            role: admin
        - name: acme.dev.some-service
          description: "repo: https://github.com/acme/some-service;owner:David Lightman @David Lightman"
          ignore_members: true
          delete_default_resources: true
          members:
            username: opsgenie-test@cloudposse.com
            role: admin

        alert_policies:
        - name: "prioritize-env-prod-critical-alerts"
          owner_team_name: acme.dev
          tags:
            - "ManagedBy:terraform"
          filter:
            type: match-all-conditions
            conditions:
              - field: source
                operation: matches
                expected_value: ".*prod.acme.*"
              - field: tags
                operation: contains
                expected_value: "severity:critical"
          priority: P1

        escalations:
        - name: acme.dev.some-service-escalation
          description: "repo: https://github.com/acme/some-service;owner:David Lightman @David Lightman"
          owner_team_name: acme.dev
          rule:
            condition: if-not-acked
            notify_type: default
            delay: 0
            recipients:
            - type: team
              team_name: acme.dev.some-service

        api_integrations:
        - name: acme-dev-opsgenie-sns-integration
          type: AmazonSns
          owner_team_name: acme.dev
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.12 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 2.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | >= 1.3 |
| <a name="requirement_opsgenie"></a> [opsgenie](#requirement\_opsgenie) | >= 0.5.0 |
| <a name="requirement_template"></a> [template](#requirement\_template) | >= 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 2.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_iam_roles"></a> [iam\_roles](#module\_iam\_roles) | ../account-map/modules/iam-roles | n/a |
| <a name="module_opsgenie_config"></a> [opsgenie\_config](#module\_opsgenie\_config) | git::https://github.com/cloudposse/terraform-opsgenie-incident-management.git//modules/config | 0.9.0 |
| <a name="module_this"></a> [this](#module\_this) | git::https://github.com/cloudposse/terraform-null-label.git | tags/0.21.0 |

## Resources

| Name | Type |
|------|------|
| [aws_ssm_parameter.opsgenie_datadog_api_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.opsgenie_api_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional tags for appending to tags\_as\_list\_of\_maps. Not added to `tags`. | `map(string)` | `{}` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | Additional attributes (e.g. `1`) | `list(string)` | `[]` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | <pre>object({<br>    enabled             = bool<br>    namespace           = string<br>    environment         = string<br>    stage               = string<br>    name                = string<br>    delimiter           = string<br>    attributes          = list(string)<br>    tags                = map(string)<br>    additional_tag_map  = map(string)<br>    regex_replace_chars = string<br>    label_order         = list(string)<br>    id_length_limit     = number<br>  })</pre> | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_order": [],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {}<br>}</pre> | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between `namespace`, `environment`, `stage`, `name` and `attributes`.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment, e.g. 'uw2', 'us-west-2', OR 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters.<br>Set to `0` for unlimited length.<br>Set to `null` for default, which is `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_import_role_arn"></a> [import\_role\_arn](#input\_import\_role\_arn) | IAM Role ARN to use when importing a resource | `string` | `null` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | AWS KMS key used for writing to SSM | `string` | `"alias/aws/ssm"` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The naming order of the id output and Name tag.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 5 elements, but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Solution name, e.g. 'app' or 'jenkins' | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace, which could be your organization name or abbreviation, e.g. 'eg' or 'cp' | `string` | `null` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Regex to replace chars with empty string in `namespace`, `environment`, `stage` and `name`.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_ssm_parameter_name_format"></a> [ssm\_parameter\_name\_format](#input\_ssm\_parameter\_name\_format) | SSM parameter name format | `string` | `"/%s/%s"` | no |
| <a name="input_ssm_path"></a> [ssm\_path](#input\_ssm\_path) | SSM path | `string` | `"opsgenie"` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | Stage, e.g. 'prod', 'staging', 'dev', OR 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `map('BusinessUnit','XYZ')` | `map(string)` | `{}` | no |
| <a name="input_tfstate_account_id"></a> [tfstate\_account\_id](#input\_tfstate\_account\_id) | The ID of the account where the Terraform remote state backend is provisioned | `string` | `""` | no |
| <a name="input_tfstate_assume_role"></a> [tfstate\_assume\_role](#input\_tfstate\_assume\_role) | Set to false to use the caller's role to access the Terraform remote state | `bool` | `true` | no |
| <a name="input_tfstate_bucket_environment_name"></a> [tfstate\_bucket\_environment\_name](#input\_tfstate\_bucket\_environment\_name) | The name of the environment for Terraform state bucket | `string` | `""` | no |
| <a name="input_tfstate_bucket_stage_name"></a> [tfstate\_bucket\_stage\_name](#input\_tfstate\_bucket\_stage\_name) | The name of the stage for Terraform state bucket | `string` | `"root"` | no |
| <a name="input_tfstate_existing_role_arn"></a> [tfstate\_existing\_role\_arn](#input\_tfstate\_existing\_role\_arn) | The ARN of the existing IAM Role to access the Terraform remote state. If not provided and `remote_state_assume_role` is `true`, a role will be constructed from `remote_state_role_arn_template` | `string` | `""` | no |
| <a name="input_tfstate_role_arn_template"></a> [tfstate\_role\_arn\_template](#input\_tfstate\_role\_arn\_template) | IAM Role ARN template for accessing the Terraform remote state | `string` | `"arn:aws:iam::%s:role/%s-%s-%s-%s"` | no |
| <a name="input_tfstate_role_environment_name"></a> [tfstate\_role\_environment\_name](#input\_tfstate\_role\_environment\_name) | The name of the environment for Terraform state IAM role | `string` | `"gbl"` | no |
| <a name="input_tfstate_role_name"></a> [tfstate\_role\_name](#input\_tfstate\_role\_name) | IAM Role name for accessing the Terraform remote state | `string` | `"terraform"` | no |
| <a name="input_tfstate_role_stage_name"></a> [tfstate\_role\_stage\_name](#input\_tfstate\_role\_stage\_name) | The name of the stage for Terraform state IAM role | `string` | `"root"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alert_policies"></a> [alert\_policies](#output\_alert\_policies) | Alert policies |
| <a name="output_api_integrations"></a> [api\_integrations](#output\_api\_integrations) | API integrations |
| <a name="output_escalations"></a> [escalations](#output\_escalations) | Escalations |
| <a name="output_existing_users"></a> [existing\_users](#output\_existing\_users) | Existing Users |
| <a name="output_notification_policies"></a> [notification\_policies](#output\_notification\_policies) | Notification policies |
| <a name="output_service_incident_rule_ids"></a> [service\_incident\_rule\_ids](#output\_service\_incident\_rule\_ids) | Service Incident Rule IDs |
| <a name="output_services"></a> [services](#output\_services) | Services |
| <a name="output_team_routing_rules"></a> [team\_routing\_rules](#output\_team\_routing\_rules) | Team routing rules |
| <a name="output_teams"></a> [teams](#output\_teams) | Teams |
| <a name="output_users"></a> [users](#output\_users) | Users |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


## References
  * [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/master/modules/opsgenie) - Cloud Posse's upstream component


[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
