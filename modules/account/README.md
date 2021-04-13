# Component: `account`

This component is responsible for provisioning the full account hierarchy along with Organizational Units (OUs). It includes the ability to associate Service Control Policies (SCPs) to the Organization, each Organizational Unit and account.

## Usage

**Stack Level**: Global

Here's an example snippet for how to use this component. Stick this snippet in the management account's stack (E.g. `gbl-root.yaml`)

**IMPORTANT**: Account names must not contain dashes. Doing so will lead to unpredictable resource names as a `-` is the default delimiter. Additionally, account names must be alpha-numeric with no special characters.

```yaml
components:
  terraform:
    account:
      vars:
        account_email_format: aws+%s@example.net
        account_iam_user_access_to_billing: DENY
        organization_enabled: true
        aws_service_access_principals:
          - cloudtrail.amazonaws.com
          - ram.amazonaws.com
        enabled_policy_types:
          - SERVICE_CONTROL_POLICY
          - TAG_POLICY
        organization_config:
          root_account_stage_name: root
          accounts: []
          organization:
            service_control_policies: []
          organizational_units:
            - name: data
              accounts:
                - name: proddata
                  tags:
                    eks: true
                - name: devdata
                  tags:
                    eks: true
                - name: stagedata
                  tags:
                    eks: true
              service_control_policies:
                - DenyLeavingOrganization
            - name: platform
              accounts:
                - name: platformprod
                  tags:
                    eks: true
                - name: platformdev
                  tags:
                    eks: true
                - name: platformstaging
                  tags:
                    eks: true
              service_control_policies:
                - DenyLeavingOrganization
            - name: mgmt
              accounts:
                - name: demo
                  tags:
                    eks: true
                - name: audit
                  tags:
                    eks: false
                - name: corp
                  tags:
                    eks: true
                - name: security
                  tags:
                    eks: false
                - name: identity
                  tags:
                    eks: false
                - name: network
                  tags:
                    eks: false
                - name: dns
                  tags:
                    eks: false
                - name: automation
                  tags:
                    eks: true
              service_control_policies:
                - DenyLeavingOrganization
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 0.14.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.32 |
| <a name="requirement_local"></a> [local](#requirement\_local) | ~> 2.0 |
| <a name="requirement_template"></a> [template](#requirement\_template) | ~> 2.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 3.32 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_accounts_service_control_policies"></a> [accounts\_service\_control\_policies](#module\_accounts\_service\_control\_policies) | cloudposse/service-control-policies/aws | 0.4.0 |
| <a name="module_organization_service_control_policies"></a> [organization\_service\_control\_policies](#module\_organization\_service\_control\_policies) | cloudposse/service-control-policies/aws | 0.4.0 |
| <a name="module_organizational_units_service_control_policies"></a> [organizational\_units\_service\_control\_policies](#module\_organizational\_units\_service\_control\_policies) | cloudposse/service-control-policies/aws | 0.4.0 |
| <a name="module_service_control_policy_statements_yaml_config"></a> [service\_control\_policy\_statements\_yaml\_config](#module\_service\_control\_policy\_statements\_yaml\_config) | cloudposse/config/yaml | 0.1.0 |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.24.1 |

## Resources

| Name | Type |
|------|------|
| [aws_organizations_account.organization_accounts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_account) | resource |
| [aws_organizations_account.organizational_units_accounts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_account) | resource |
| [aws_organizations_organization.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_organization) | resource |
| [aws_organizations_organizational_unit.children](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_organizational_unit) | resource |
| [aws_organizations_organizational_unit.parents](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_organizational_unit) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_email_format"></a> [account\_email\_format](#input\_account\_email\_format) | Email address format for the accounts (e.g. `aws+%s@example.com`) | `string` | n/a | yes |
| <a name="input_account_iam_user_access_to_billing"></a> [account\_iam\_user\_access\_to\_billing](#input\_account\_iam\_user\_access\_to\_billing) | If set to `ALLOW`, the new account enables IAM users to access account billing information if they have the required permissions. If set to `DENY`, then only the root user of the new account can access account billing information | `string` | `"DENY"` | no |
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional tags for appending to tags\_as\_list\_of\_maps. Not added to `tags`. | `map(string)` | `{}` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | Additional attributes (e.g. `1`) | `list(string)` | `[]` | no |
| <a name="input_aws_service_access_principals"></a> [aws\_service\_access\_principals](#input\_aws\_service\_access\_principals) | List of AWS service principal names for which you want to enable integration with your organization. This is typically in the form of a URL, such as service-abbreviation.amazonaws.com. Organization must have `feature_set` set to ALL. For additional information, see the [AWS Organizations User Guide](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_integrate_services.html) | `list(string)` | n/a | yes |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | <pre>object({<br>    enabled             = bool<br>    namespace           = string<br>    environment         = string<br>    stage               = string<br>    name                = string<br>    delimiter           = string<br>    attributes          = list(string)<br>    tags                = map(string)<br>    additional_tag_map  = map(string)<br>    regex_replace_chars = string<br>    label_order         = list(string)<br>    id_length_limit     = number<br>  })</pre> | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_order": [],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {}<br>}</pre> | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between `namespace`, `environment`, `stage`, `name` and `attributes`.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_enabled_policy_types"></a> [enabled\_policy\_types](#input\_enabled\_policy\_types) | List of Organizations policy types to enable in the Organization Root. Organization must have feature\_set set to ALL. For additional information about valid policy types (e.g. SERVICE\_CONTROL\_POLICY and TAG\_POLICY), see the [AWS Organizations API Reference](https://docs.aws.amazon.com/organizations/latest/APIReference/API_EnablePolicyType.html) | `list(string)` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment, e.g. 'uw2', 'us-west-2', OR 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters.<br>Set to `0` for unlimited length.<br>Set to `null` for default, which is `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The naming order of the id output and Name tag.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 5 elements, but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Solution name, e.g. 'app' or 'jenkins' | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace, which could be your organization name or abbreviation, e.g. 'eg' or 'cp' | `string` | `null` | no |
| <a name="input_organization_config"></a> [organization\_config](#input\_organization\_config) | Organization, Organizational Units and Accounts configuration | `any` | n/a | yes |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Regex to replace chars with empty string in `namespace`, `environment`, `stage` and `name`.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_root_account_stage_name"></a> [root\_account\_stage\_name](#input\_root\_account\_stage\_name) | The stage name for the Organization root (master) account | `string` | `"root"` | no |
| <a name="input_service_control_policies_config_paths"></a> [service\_control\_policies\_config\_paths](#input\_service\_control\_policies\_config\_paths) | List of paths to Service Control Policy configurations | `list(string)` | n/a | yes |
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
| <a name="output_account_arns"></a> [account\_arns](#output\_account\_arns) | List of account ARNs |
| <a name="output_account_ids"></a> [account\_ids](#output\_account\_ids) | List of account IDs |
| <a name="output_account_names_account_arns"></a> [account\_names\_account\_arns](#output\_account\_names\_account\_arns) | Map of account names to account ARNs |
| <a name="output_account_names_account_ids"></a> [account\_names\_account\_ids](#output\_account\_names\_account\_ids) | Map of account names to account IDs |
| <a name="output_account_names_account_scp_arns"></a> [account\_names\_account\_scp\_arns](#output\_account\_names\_account\_scp\_arns) | Map of account names to SCP ARNs |
| <a name="output_account_names_account_scp_ids"></a> [account\_names\_account\_scp\_ids](#output\_account\_names\_account\_scp\_ids) | Map of account names to SCP IDs |
| <a name="output_eks_accounts"></a> [eks\_accounts](#output\_eks\_accounts) | List of EKS accounts |
| <a name="output_non_eks_accounts"></a> [non\_eks\_accounts](#output\_non\_eks\_accounts) | List of non EKS accounts |
| <a name="output_organization_arn"></a> [organization\_arn](#output\_organization\_arn) | Organization ARN |
| <a name="output_organization_id"></a> [organization\_id](#output\_organization\_id) | Organization ID |
| <a name="output_organization_master_account_arn"></a> [organization\_master\_account\_arn](#output\_organization\_master\_account\_arn) | Organization master account ARN |
| <a name="output_organization_master_account_email"></a> [organization\_master\_account\_email](#output\_organization\_master\_account\_email) | Organization master account email |
| <a name="output_organization_master_account_id"></a> [organization\_master\_account\_id](#output\_organization\_master\_account\_id) | Organization master account ID |
| <a name="output_organization_scp_arn"></a> [organization\_scp\_arn](#output\_organization\_scp\_arn) | Organization Service Control Policy ARN |
| <a name="output_organization_scp_id"></a> [organization\_scp\_id](#output\_organization\_scp\_id) | Organization Service Control Policy ID |
| <a name="output_organizational_unit_arns"></a> [organizational\_unit\_arns](#output\_organizational\_unit\_arns) | List of Organizational Unit ARNs |
| <a name="output_organizational_unit_ids"></a> [organizational\_unit\_ids](#output\_organizational\_unit\_ids) | List of Organizational Unit IDs |
| <a name="output_organizational_unit_names_organizational_unit_arns"></a> [organizational\_unit\_names\_organizational\_unit\_arns](#output\_organizational\_unit\_names\_organizational\_unit\_arns) | Map of Organizational Unit names to Organizational Unit ARNs |
| <a name="output_organizational_unit_names_organizational_unit_ids"></a> [organizational\_unit\_names\_organizational\_unit\_ids](#output\_organizational\_unit\_names\_organizational\_unit\_ids) | Map of Organizational Unit names to Organizational Unit IDs |
| <a name="output_organizational_unit_names_organizational_unit_scp_arns"></a> [organizational\_unit\_names\_organizational\_unit\_scp\_arns](#output\_organizational\_unit\_names\_organizational\_unit\_scp\_arns) | Map of OU names to SCP ARNs |
| <a name="output_organizational_unit_names_organizational_unit_scp_ids"></a> [organizational\_unit\_names\_organizational\_unit\_scp\_ids](#output\_organizational\_unit\_names\_organizational\_unit\_scp\_ids) | Map of OU names to SCP IDs |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## References

- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/master/modules/account) - Cloud Posse's upstream component

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
