# Component: `account-map`

This component is responsible for provisioning information only: it simply populates Terraform state with data (account ids, groups, and roles) that other root modules need via outputs.

## Usage

**Stack Level**: Global

Here's an example snippet for how to use this component. Stick this snippet in the management account's stack (E.g. `gbl-root.yaml`)

```yaml
components:
  terraform:
    account-map:
      vars:
        root_account_aws_name: "aws-root"
        root_account_stage_name: root
        identity_account_stage_name: identity
        dns_account_stage_name: dns
        audit_account_stage_name: audit
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 0.14.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.32 |
| <a name="requirement_external"></a> [external](#requirement\_external) | ~> 2.1 |
| <a name="requirement_http"></a> [http](#requirement\_http) | ~> 2.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | ~> 2.0 |
| <a name="requirement_template"></a> [template](#requirement\_template) | ~> 2.2 |
| <a name="requirement_utils"></a> [utils](#requirement\_utils) | ~> 0.3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 3.32 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_accounts"></a> [accounts](#module\_accounts) | cloudposse/stack-config/yaml//modules/remote-state | 0.13.0 |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.24.1 |

## Resources

| Name | Type |
|------|------|
| [aws_organizations_organization.organization](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/organizations_organization) | data source |
| [terraform_remote_state.accounts](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional tags for appending to tags\_as\_list\_of\_maps. Not added to `tags`. | `map(string)` | `{}` | no |
| <a name="input_artifacts_account_stage_name"></a> [artifacts\_account\_stage\_name](#input\_artifacts\_account\_stage\_name) | The stage name for the artifacts account | `string` | `"artifacts"` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | Additional attributes (e.g. `1`) | `list(string)` | `[]` | no |
| <a name="input_audit_account_stage_name"></a> [audit\_account\_stage\_name](#input\_audit\_account\_stage\_name) | The stage name for the audit account | `string` | `"audit"` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | <pre>object({<br>    enabled             = bool<br>    namespace           = string<br>    environment         = string<br>    stage               = string<br>    name                = string<br>    delimiter           = string<br>    attributes          = list(string)<br>    tags                = map(string)<br>    additional_tag_map  = map(string)<br>    regex_replace_chars = string<br>    label_order         = list(string)<br>    id_length_limit     = number<br>  })</pre> | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_order": [],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {}<br>}</pre> | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between `namespace`, `environment`, `stage`, `name` and `attributes`.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_dns_account_stage_name"></a> [dns\_account\_stage\_name](#input\_dns\_account\_stage\_name) | The stage name for the primary DNS account | `string` | `"dns"` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment, e.g. 'uw2', 'us-west-2', OR 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_global_environment_name"></a> [global\_environment\_name](#input\_global\_environment\_name) | Global environment name | `string` | `"gbl"` | no |
| <a name="input_iam_role_arn_template"></a> [iam\_role\_arn\_template](#input\_iam\_role\_arn\_template) | IAM Role ARN template | `string` | `"arn:aws:iam::%s:role/%s-%s-%s-%s"` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters.<br>Set to `0` for unlimited length.<br>Set to `null` for default, which is `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_identity_account_stage_name"></a> [identity\_account\_stage\_name](#input\_identity\_account\_stage\_name) | The stage name for the account holding primary IAM roles | `string` | `"identity"` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The naming order of the id output and Name tag.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 5 elements, but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Solution name, e.g. 'app' or 'jenkins' | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace, which could be your organization name or abbreviation, e.g. 'eg' or 'cp' | `string` | `null` | no |
| <a name="input_profile_template"></a> [profile\_template](#input\_profile\_template) | AWS Profile name template | `string` | `"%s-%s-%s-%s"` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Regex to replace chars with empty string in `namespace`, `environment`, `stage` and `name`.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_root_account_aws_name"></a> [root\_account\_aws\_name](#input\_root\_account\_aws\_name) | The name of the root account as reported by AWS | `string` | n/a | yes |
| <a name="input_root_account_stage_name"></a> [root\_account\_stage\_name](#input\_root\_account\_stage\_name) | The stage name for the root account | `string` | `"root"` | no |
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
| <a name="output_all_accounts"></a> [all\_accounts](#output\_all\_accounts) | A list of all accounts in the AWS Organization |
| <a name="output_artifacts_account_stage_name"></a> [artifacts\_account\_stage\_name](#output\_artifacts\_account\_stage\_name) | The stage name for the artifacts account |
| <a name="output_audit_account_stage_name"></a> [audit\_account\_stage\_name](#output\_audit\_account\_stage\_name) | The stage name for the audit account |
| <a name="output_cicd_profiles"></a> [cicd\_profiles](#output\_cicd\_profiles) | A list of all SSO profiles used by cicd platforms |
| <a name="output_cicd_roles"></a> [cicd\_roles](#output\_cicd\_roles) | A list of all IAM roles used by cicd platforms |
| <a name="output_dns_account_stage_name"></a> [dns\_account\_stage\_name](#output\_dns\_account\_stage\_name) | The stage name for the primary DNS account |
| <a name="output_eks_accounts"></a> [eks\_accounts](#output\_eks\_accounts) | A list of all accounts in the AWS Organization that contain EKS clusters |
| <a name="output_full_account_map"></a> [full\_account\_map](#output\_full\_account\_map) | The map describing attributes of accounts in the AWS Organization. |
| <a name="output_helm_profiles"></a> [helm\_profiles](#output\_helm\_profiles) | A list of all SSO profiles used to run helm updates |
| <a name="output_helm_roles"></a> [helm\_roles](#output\_helm\_roles) | A list of all IAM roles used to run helm updates |
| <a name="output_identity_account_stage_name"></a> [identity\_account\_stage\_name](#output\_identity\_account\_stage\_name) | The stage name for the account holding primary IAM roles |
| <a name="output_non_eks_accounts"></a> [non\_eks\_accounts](#output\_non\_eks\_accounts) | A list of all accounts in the AWS Organization that do not contain EKS clusters |
| <a name="output_org"></a> [org](#output\_org) | The name of the AWS Organization |
| <a name="output_root_account_aws_name"></a> [root\_account\_aws\_name](#output\_root\_account\_aws\_name) | The name of the root account as reported by AWS |
| <a name="output_root_account_stage_name"></a> [root\_account\_stage\_name](#output\_root\_account\_stage\_name) | The stage name for the root account |
| <a name="output_terraform_profiles"></a> [terraform\_profiles](#output\_terraform\_profiles) | A list of all SSO profiles used to run terraform updates |
| <a name="output_terraform_roles"></a> [terraform\_roles](#output\_terraform\_roles) | A list of all IAM roles used to run terraform updates |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## References

- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/master/modules/account-map) - Cloud Posse's upstream component

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
