# Component: `iam-delegated-roles`

This component is responsible for provisioning all delegated user and system IAM roles. It sets them up to be assumed from the primary, identity account roles. This is expected to be used alongside and applied after [the `iam-primary-roles` component](https://github.com/cloudposse/terraform-aws-components/tree/master/modules/iam-primary-roles) is applied to the identity account.

## Usage

**Stack Level**: Global

Here's an example snippet for how to use this component. This specific usage is for an audit stack (e.g. `gbl-audit.yaml`) where limiting the default permissions of the roles is desired.

```yaml
components:
  terraform:
    iam-delegated-roles:
      vars:
        exclude_roles: [ "helm" ]
        account_role_policy_arns:
          # IAM Policy ARNs to attach to each role, overriding the defaults
          admin: [ "arn:aws:iam::aws:policy/PowerUserAccess" ]
          ops: [ "arn:aws:iam::aws:policy/job-function/ViewOnlyAccess" ]
          poweruser: [ "arn:aws:iam::aws:policy/job-function/ViewOnlyAccess" ]
          observer: [ "arn:aws:iam::aws:policy/job-function/ViewOnlyAccess" ]
          # Use default for terraform

        trusted_primary_role_overrides:
          # Terraform in audit can wipe out logs, so access to it needs to be restricted
          terraform: [ "admin" ]
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12.0 |
| aws | >= 2.0 |
| local | >= 1.3 |
| template | >= 2.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 2.0 |
| terraform | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| account\_number | Account number for the target account | `string` | n/a | yes |
| account\_role\_policy\_arns | Custom IAM policy ARNs to override defaults | `map(list(string))` | `{}` | no |
| additional\_tag\_map | Additional tags for appending to tags\_as\_list\_of\_maps. Not added to `tags`. | `map(string)` | `{}` | no |
| allow\_same\_account\_assume\_role | Set true to allow roles to assume other roles in the same account | `bool` | `false` | no |
| attributes | Additional attributes (e.g. `1`) | `list(string)` | `[]` | no |
| context | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | <pre>object({<br>    enabled             = bool<br>    namespace           = string<br>    environment         = string<br>    stage               = string<br>    name                = string<br>    delimiter           = string<br>    attributes          = list(string)<br>    tags                = map(string)<br>    additional_tag_map  = map(string)<br>    regex_replace_chars = string<br>    label_order         = list(string)<br>    id_length_limit     = number<br>  })</pre> | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_order": [],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {}<br>}</pre> | no |
| default\_account\_role\_policy\_arns | Custom IAM policy ARNs to override defaults | `map(list(string))` | n/a | yes |
| delimiter | Delimiter to be used between `namespace`, `environment`, `stage`, `name` and `attributes`.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| enabled | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| environment | Environment, e.g. 'uw2', 'us-west-2', OR 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| exclude\_roles | Roles in roles\_config that should NOT be created | `list(string)` | `[]` | no |
| iam\_primary\_roles\_stage\_name | The name of the stage where the IAM primary roles are provisioned | `string` | `"identity"` | no |
| iam\_role\_max\_session\_duration | The maximum session duration (in seconds) that you want to set for the IAM roles. If you do not specify a value for this setting, the default maximum of one hour is applied. This setting can have a value from 1 hour to 12 hours | `number` | `43200` | no |
| iam\_roles\_environment\_name | The name of the environment where the IAM roles are provisioned | `string` | `"gbl"` | no |
| id\_length\_limit | Limit `id` to this many characters.<br>Set to `0` for unlimited length.<br>Set to `null` for default, which is `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| import\_role\_arn | IAM Role ARN to use when importing a resource | `string` | `null` | no |
| label\_order | The naming order of the id output and Name tag.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 5 elements, but at least one must be present. | `list(string)` | `null` | no |
| name | Solution name, e.g. 'app' or 'jenkins' | `string` | `null` | no |
| namespace | Namespace, which could be your organization name or abbreviation, e.g. 'eg' or 'cp' | `string` | `null` | no |
| primary\_account\_id | Primary authentication account id used as the source for assume role | `string` | n/a | yes |
| regex\_replace\_chars | Regex to replace chars with empty string in `namespace`, `environment`, `stage` and `name`.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| region | AWS Region | `string` | n/a | yes |
| stage | Stage, e.g. 'prod', 'staging', 'dev', OR 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| tags | Additional tags (e.g. `map('BusinessUnit','XYZ')` | `map(string)` | `{}` | no |
| tfstate\_account\_id | The ID of the account where the Terraform remote state backend is provisioned | `string` | `""` | no |
| tfstate\_assume\_role | Set to false to use the caller's role to access the Terraform remote state | `bool` | `true` | no |
| tfstate\_backend\_stage\_name | The name of the stage where the Terraform state backend is provisioned | `string` | `"root"` | no |
| tfstate\_bucket\_environment\_name | The name of the environment for Terraform state bucket | `string` | `""` | no |
| tfstate\_bucket\_stage\_name | The name of the stage for Terraform state bucket | `string` | `"root"` | no |
| tfstate\_existing\_role\_arn | The ARN of the existing IAM Role to access the Terraform remote state. If not provided and `remote_state_assume_role` is `true`, a role will be constructed from `remote_state_role_arn_template` | `string` | `""` | no |
| tfstate\_role\_arn\_template | IAM Role ARN template for accessing the Terraform remote state | `string` | `"arn:aws:iam::%s:role/%s-%s-%s-%s"` | no |
| tfstate\_role\_environment\_name | The name of the environment for Terraform state IAM role | `string` | `"gbl"` | no |
| tfstate\_role\_name | IAM Role name for accessing the Terraform remote state | `string` | `"terraform"` | no |
| tfstate\_role\_stage\_name | The name of the stage for Terraform state IAM role | `string` | `"root"` | no |
| trusted\_primary\_role\_overrides | Override default list of primary roles that can assume this one | `map(list(string))` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| role\_long\_name\_policy\_arn\_map | Map of role long names to attached IAM Policy ARNs |
| role\_name\_role\_arn\_map | Map of role names to role ARNs |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


## References
* [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/master/modules/iam-delegated-roles) - Cloud Posse's upstream component


[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
