# Component: `cloudtrail-bucket`

This component is responsible for provisioning a bucket for storing cloudtrail logs for auditing purposes. It's expected to be used alongside [the `cloudtrail` component](https://github.com/cloudposse/terraform-aws-components/tree/master/modules/cloudtrail).

## Usage

**Stack Level**: Regional

Here's an example snippet for how to use this component. It's suggested to apply this component to only the centralized `audit` account.

```yaml
components:
  terraform:
    cloudtrail-bucket:
      vars:
        name: "cloudtrail"
        noncurrent_version_expiration_days: 180
        noncurrent_version_transition_days: 30
        standard_transition_days: 60
        glacier_transition_days: 180
        expiration_days: 365
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.12.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | >= 1.3 |
| <a name="requirement_template"></a> [template](#requirement\_template) | >= 2.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cloudtrail_s3_bucket"></a> [cloudtrail\_s3\_bucket](#module\_cloudtrail\_s3\_bucket) | git::https://github.com/cloudposse/terraform-aws-cloudtrail-s3-bucket.git | tags/0.12.0 |
| <a name="module_iam_roles"></a> [iam\_roles](#module\_iam\_roles) | ../account-map/modules/iam-roles | n/a |
| <a name="module_this"></a> [this](#module\_this) | git::https://github.com/cloudposse/terraform-null-label.git | tags/0.21.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional tags for appending to tags\_as\_list\_of\_maps. Not added to `tags`. | `map(string)` | `{}` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | Additional attributes (e.g. `1`) | `list(string)` | `[]` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | <pre>object({<br>    enabled             = bool<br>    namespace           = string<br>    environment         = string<br>    stage               = string<br>    name                = string<br>    delimiter           = string<br>    attributes          = list(string)<br>    tags                = map(string)<br>    additional_tag_map  = map(string)<br>    regex_replace_chars = string<br>    label_order         = list(string)<br>    id_length_limit     = number<br>  })</pre> | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_order": [],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {}<br>}</pre> | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between `namespace`, `environment`, `stage`, `name` and `attributes`.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment, e.g. 'uw2', 'us-west-2', OR 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_expiration_days"></a> [expiration\_days](#input\_expiration\_days) | Number of days after which to expunge the objects | `number` | `90` | no |
| <a name="input_glacier_transition_days"></a> [glacier\_transition\_days](#input\_glacier\_transition\_days) | Number of days after which to move the data to the glacier storage tier | `number` | `60` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters.<br>Set to `0` for unlimited length.<br>Set to `null` for default, which is `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_import_role_arn"></a> [import\_role\_arn](#input\_import\_role\_arn) | IAM Role ARN to use when importing a resource | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The naming order of the id output and Name tag.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 5 elements, but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Solution name, e.g. 'app' or 'jenkins' | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace, which could be your organization name or abbreviation, e.g. 'eg' or 'cp' | `string` | `null` | no |
| <a name="input_noncurrent_version_expiration_days"></a> [noncurrent\_version\_expiration\_days](#input\_noncurrent\_version\_expiration\_days) | Specifies when noncurrent object versions expire | `number` | `90` | no |
| <a name="input_noncurrent_version_transition_days"></a> [noncurrent\_version\_transition\_days](#input\_noncurrent\_version\_transition\_days) | Specifies when noncurrent object versions transitions | `number` | `30` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Regex to replace chars with empty string in `namespace`, `environment`, `stage` and `name`.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_stage"></a> [stage](#input\_stage) | Stage, e.g. 'prod', 'staging', 'dev', OR 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_standard_transition_days"></a> [standard\_transition\_days](#input\_standard\_transition\_days) | Number of days to persist in the standard storage tier before moving to the infrequent access tier | `number` | `30` | no |
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
| <a name="output_cloudtrail_bucket_arn"></a> [cloudtrail\_bucket\_arn](#output\_cloudtrail\_bucket\_arn) | CloudTrail S3 bucket ARN |
| <a name="output_cloudtrail_bucket_domain_name"></a> [cloudtrail\_bucket\_domain\_name](#output\_cloudtrail\_bucket\_domain\_name) | CloudTrail S3 bucket domain name |
| <a name="output_cloudtrail_bucket_id"></a> [cloudtrail\_bucket\_id](#output\_cloudtrail\_bucket\_id) | CloudTrail S3 bucket ID |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


## References
* [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/master/modules/cloudtrail-bucket) - Cloud Posse's upstream component


[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
