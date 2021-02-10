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
                - name: prodplatform
                  tags:
                    eks: true
                - name: devplatform
                  tags:
                    eks: true
                - name: stageplatform
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
| terraform | >= 0.13.0 |
| aws | >= 3.0 |
| local | >= 1.3 |
| template | >= 2.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 3.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| account\_email\_format | Email address format for the accounts (e.g. `aws+%s@example.com`) | `string` | n/a | yes |
| account\_iam\_user\_access\_to\_billing | If set to `ALLOW`, the new account enables IAM users to access account billing information if they have the required permissions. If set to `DENY`, then only the root user of the new account can access account billing information | `string` | `"DENY"` | no |
| additional\_tag\_map | Additional tags for appending to tags\_as\_list\_of\_maps. Not added to `tags`. | `map(string)` | `{}` | no |
| attributes | Additional attributes (e.g. `1`) | `list(string)` | `[]` | no |
| aws\_service\_access\_principals | List of AWS service principal names for which you want to enable integration with your organization. This is typically in the form of a URL, such as service-abbreviation.amazonaws.com. Organization must have `feature_set` set to ALL. For additional information, see the [AWS Organizations User Guide](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_integrate_services.html) | `list(string)` | n/a | yes |
| context | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | <pre>object({<br>    enabled             = bool<br>    namespace           = string<br>    environment         = string<br>    stage               = string<br>    name                = string<br>    delimiter           = string<br>    attributes          = list(string)<br>    tags                = map(string)<br>    additional_tag_map  = map(string)<br>    regex_replace_chars = string<br>    label_order         = list(string)<br>    id_length_limit     = number<br>  })</pre> | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_order": [],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {}<br>}</pre> | no |
| delimiter | Delimiter to be used between `namespace`, `environment`, `stage`, `name` and `attributes`.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| enabled | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| enabled\_policy\_types | List of Organizations policy types to enable in the Organization Root. Organization must have feature\_set set to ALL. For additional information about valid policy types (e.g. SERVICE\_CONTROL\_POLICY and TAG\_POLICY), see the [AWS Organizations API Reference](https://docs.aws.amazon.com/organizations/latest/APIReference/API_EnablePolicyType.html) | `list(string)` | n/a | yes |
| environment | Environment, e.g. 'uw2', 'us-west-2', OR 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| id\_length\_limit | Limit `id` to this many characters.<br>Set to `0` for unlimited length.<br>Set to `null` for default, which is `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| label\_order | The naming order of the id output and Name tag.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 5 elements, but at least one must be present. | `list(string)` | `null` | no |
| name | Solution name, e.g. 'app' or 'jenkins' | `string` | `null` | no |
| namespace | Namespace, which could be your organization name or abbreviation, e.g. 'eg' or 'cp' | `string` | `null` | no |
| organization\_config | Organization, Organizational Units and Accounts configuration | `any` | n/a | yes |
| organization\_enabled | A boolean flag indicating whether to create an Organization or use the existing one | `bool` | `true` | no |
| regex\_replace\_chars | Regex to replace chars with empty string in `namespace`, `environment`, `stage` and `name`.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| region | AWS Region | `string` | n/a | yes |
| root\_account\_stage\_name | The stage name for the Organization root (master) account | `string` | `"root"` | no |
| service\_control\_policies\_config\_paths | List of paths to Service Control Policy configurations | `list(string)` | n/a | yes |
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
| account\_arns | List of account ARNs |
| account\_ids | List of account IDs |
| account\_names\_account\_arns | Map of account names to account ARNs |
| account\_names\_account\_ids | Map of account names to account IDs |
| account\_names\_account\_scp\_arns | Map of account names to SCP ARNs |
| account\_names\_account\_scp\_ids | Map of account names to SCP IDs |
| eks\_accounts | List of EKS accounts |
| non\_eks\_accounts | List of non EKS accounts |
| organization\_arn | Organization ARN |
| organization\_id | Organization ID |
| organization\_master\_account\_arn | Organization master account ARN |
| organization\_master\_account\_email | Organization master account email |
| organization\_master\_account\_id | Organization master account ID |
| organization\_scp\_arn | Organization Service Control Policy ARN |
| organization\_scp\_id | Organization Service Control Policy ID |
| organizational\_unit\_arns | List of Organizational Unit ARNs |
| organizational\_unit\_ids | List of Organizational Unit IDs |
| organizational\_unit\_names\_organizational\_unit\_arns | Map of Organizational Unit names to Organizational Unit ARNs |
| organizational\_unit\_names\_organizational\_unit\_ids | Map of Organizational Unit names to Organizational Unit IDs |
| organizational\_unit\_names\_organizational\_unit\_scp\_arns | Map of OU names to SCP ARNs |
| organizational\_unit\_names\_organizational\_unit\_scp\_ids | Map of OU names to SCP IDs |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


## References
* [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/master/modules/account) - Cloud Posse's upstream component


[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
