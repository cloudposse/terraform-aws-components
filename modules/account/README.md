---
tags:
  - component/account
  - layer/accounts
  - provider/aws
  - privileged
---

# Component: `account`

This component is responsible for provisioning the full account hierarchy along with Organizational Units (OUs). It
includes the ability to associate Service Control Policies (SCPs) to the Organization, each Organizational Unit and
account.

> [!NOTE]
>
> Part of a [cold start](https://docs.cloudposse.com/layers/accounts/prepare-aws-organization/) so it has to be
> initially run with `SuperAdmin` role.

In addition, it enables
[AWS IAM Access Analyzer](https://docs.aws.amazon.com/IAM/latest/UserGuide/what-is-access-analyzer.html), which helps
you identify the resources in your organization and accounts, such as Amazon S3 buckets or IAM roles, that are shared
with an external entity. This lets you identify unintended access to your resources and data, which is a security risk.
Access Analyzer identifies resources that are shared with external principals by using logic-based reasoning to analyze
the resource-based policies in your AWS environment. For each instance of a resource that is shared outside of your
account, Access Analyzer generates a finding. Findings include information about the access and the external principal
that it is granted to. You can review findings to determine whether the access is intended and safe, or the access is
unintended and a security risk.

## Usage

**Stack Level**: Global

**IMPORTANT**: Account Name building blocks (such as tenant, stage, environment) must not contain dashes. Doing so will
lead to unpredictable resource names as a `-` is the default delimiter. Additionally, account names must be lower case
alphanumeric with no special characters. For example:

| Key              | Value           | Correctness |
| ---------------- | --------------- | ----------- |
| **Tenant**       | foo             | ✅          |
| **Tenant**       | foo-bar         | ❌          |
| **Environment**  | use1            | ✅          |
| **Environment**  | us-east-1       | ❌          |
| **Account Name** | `core-identity` | ✅          |

Here is an example snippet for how to use this component. Include this snippet in the stack configuration for the
management account (typically `root`) in the management tenant/OU (usually something like `mgmt` or `core`) in the
global region (`gbl`). You can insert the content directly, or create a `stacks/catalog/account.yaml` file and import it
from there.

```yaml
components:
  terraform:
    account:
      settings:
        spacelift:
          workspace_enabled: false
      backend:
        s3:
          role_arn: null
      vars:
        enabled: true
        account_email_format: aws+%s@example.net
        account_iam_user_access_to_billing: ALLOW
        organization_enabled: true
        aws_service_access_principals:
          - cloudtrail.amazonaws.com
          - guardduty.amazonaws.com
          - ipam.amazonaws.com
          - ram.amazonaws.com
          - securityhub.amazonaws.com
          - servicequotas.amazonaws.com
          - sso.amazonaws.com
          - securityhub.amazonaws.com
          - auditmanager.amazonaws.com
        enabled_policy_types:
          - SERVICE_CONTROL_POLICY
          - TAG_POLICY
        organization_config:
          root_account:
            name: core-root
            stage: root
            tenant: core
            tags:
              eks: false
          accounts: []
          organization:
            service_control_policies:
              - DenyEC2InstancesWithoutEncryptionInTransit
          organizational_units:
            - name: core
              accounts:
                - name: core-artifacts
                  tenant: core
                  stage: artifacts
                  tags:
                    eks: false
                - name: core-audit
                  tenant: core
                  stage: audit
                  tags:
                    eks: false
                - name: core-auto
                  tenant: core
                  stage: auto
                  tags:
                    eks: true
                - name: core-corp
                  tenant: core
                  stage: corp
                  tags:
                    eks: true
                - name: core-dns
                  tenant: core
                  stage: dns
                  tags:
                    eks: false
                - name: core-identity
                  tenant: core
                  stage: identity
                  tags:
                    eks: false
                - name: core-network
                  tenant: core
                  stage: network
                  tags:
                    eks: false
                - name: core-security
                  tenant: core
                  stage: security
                  tags:
                    eks: false
              service_control_policies:
                - DenyLeavingOrganization
            - name: plat
              accounts:
                - name: plat-dev
                  tenant: plat
                  stage: dev
                  tags:
                    eks: true
                - name: plat-sandbox
                  tenant: plat
                  stage: sandbox
                  tags:
                    eks: true
                - name: plat-staging
                  tenant: plat
                  stage: staging
                  tags:
                    eks: true
                - name: plat-prod
                  tenant: plat
                  stage: prod
                  tags:
                    eks: true
              service_control_policies:
                - DenyLeavingOrganization
        service_control_policies_config_paths:
          # These paths specify where to find the service control policies identified by SID in the service_control_policies sections above.
          - "https://raw.githubusercontent.com/cloudposse/terraform-aws-service-control-policies/0.12.0/catalog/cloudwatch-logs-policies.yaml"
          - "https://raw.githubusercontent.com/cloudposse/terraform-aws-service-control-policies/0.12.0/catalog/deny-all-policies.yaml"
          - "https://raw.githubusercontent.com/cloudposse/terraform-aws-service-control-policies/0.12.0/catalog/iam-policies.yaml"
          - "https://raw.githubusercontent.com/cloudposse/terraform-aws-service-control-policies/0.12.0/catalog/kms-policies.yaml"
          - "https://raw.githubusercontent.com/cloudposse/terraform-aws-service-control-policies/0.12.0/catalog/organization-policies.yaml"
          - "https://raw.githubusercontent.com/cloudposse/terraform-aws-service-control-policies/0.12.0/catalog/route53-policies.yaml"
          - "https://raw.githubusercontent.com/cloudposse/terraform-aws-service-control-policies/0.12.0/catalog/s3-policies.yaml"
          - "https://raw.githubusercontent.com/cloudposse/terraform-aws-service-control-policies/0.12.0/catalog/ec2-policies.yaml"
```

## First Time Organization Setup

Your AWS Organization is managed by the `account` component, along with accounts and organizational units.

However, because the AWS defaults for an Organization and its accounts are not exactly what we want, and there is no way
to change them via Terraform, we have to first provision the AWS Organization, then take some steps on the AWS console,
and then we can provision the rest.

### Use AWS Console to create and set up the Organization

Unfortunately, there are some tasks that need to be done via the console. Log into the AWS Console with the root (not
SuperAdmin) credentials you have saved in 1Password.

#### Request an increase in the maximum number of accounts allowed

> [!WARNING]
>
> Make sure your support plan for the _root_ account was upgraded to the "Business" level (or Higher). This is necessary
> to expedite the quota increase requests, which could take several days on a basic support plan. Without it, AWS
> support will claim that since we’re not currently utilizing any of the resources, so they do not want to approve the
> requests. AWS support is not aware of your other organization. If AWS still gives you problems, please escalate to
> your AWS TAM.

1. From the region list, select "US East (N. Virginia) us-east-1".

2. From the account dropdown menu, select "My Service Quotas".

3. From the Sidebar, select "AWS Services".

4. Type "org" in the search field under "AWS services"

5. Click on "AWS Organizations" in the "Service" list

6. Click on "Default maximum number of accounts", which should take you to a new view

7. Click on "Request quota increase" on the right side of the view, which should pop us a request form

8. At the bottom of the form, under "Change quota value", enter the number you decided on in the previous step (probably
   "20") and click "Request"

#### (Optional) Create templates to request other quota increases

New accounts start with a low limit on the number of instances you can create. However, as you add accounts, and use
more instances, the numbers automatically adjust up. So you may or may not want to create a template to generate
automatic quota increase requests, depending on how many instances per account you expect to want to provision right
away.

Create a
[Quota request template](https://docs.aws.amazon.com/servicequotas/latest/userguide/organization-templates.html) for the
organization. From the Sidebar, click "Quota request template"

Add each EC2 quota increase request you want to make:

1. Click "Add Quota" on the right side of the view

2. Under "Region", select your default region (repeat with the backup region if you are using one)

3. Under "Service", type "EC2" and select "Amazon Elastic Compute Cloud (Amazon EC2)"

4. Under "Quota", find the quota you want to increase. The likely candidates are:

5. type "stand" and select "Running On-Demand Standard (A, C, D, H, I, M, R, T, Z) Instances"

6. type "stand" and select "All Standard (A, C, D, H, I, M, R, T, Z) Spot Instance Request"

7. type "g i" and select "Running On-Demand G Instances"

8. type "all g" and select "All G Spot Instance Requests"

9. Under "Desired quota value" enter your desired default quota

10. Click "Add"

After you have added all the templates, click "Enable" on the Quota request template screen to enable the templates.

#### Enable resource sharing with AWS Organization

[AWS Resource Access Manager (RAM)](https://docs.aws.amazon.com/ram/latest/userguide/what-is.html) lets you share your
resources with any AWS account or through AWS Organizations.

<img src="/assets/refarch/image-20211116-045412.png" height="780" width="3774" /><br/>

If you have multiple AWS accounts, you can create resources centrally and use AWS RAM to share those resources with
other accounts.

Resource sharing through AWS Organization will be used to share the Transit Gateway deployed in the `network` account
with other accounts to connect their VPCs to the shared Transit Gateway.

This is a one-time manual step in the AWS Resource Access Manager console. When you share resources within your
organization, AWS RAM does not send invitations to principals. Principals in your organization get access to shared
resources without exchanging invitations.

To enable resource sharing with AWS Organization via AWS Management Console

- Open the Settings page of AWS Resource Access Manager console at
  [https://console.aws.amazon.com/ram/home#Settings](https://console.aws.amazon.com/ram/home#Settings)

- Choose "Enable sharing with AWS Organizations"

To enable resource sharing with AWS Organization via AWS CLI

```
 √ . [xamp-SuperAdmin] (HOST) infra ⨠ aws ram enable-sharing-with-aws-organization
{
    "returnValue": true
}
```

For more information, see:

- [https://docs.aws.amazon.com/ram/latest/userguide/what-is.html](https://docs.aws.amazon.com/ram/latest/userguide/what-is.html)

- [https://docs.aws.amazon.com/ram/latest/userguide/getting-started-sharing.html](https://docs.aws.amazon.com/ram/latest/userguide/getting-started-sharing.html)

- [https://docs.aws.amazon.com/organizations/latest/userguide/services-that-can-integrate-ram.html](https://docs.aws.amazon.com/organizations/latest/userguide/services-that-can-integrate-ram.html)

### Import the organization into Terraform using the `account` component

After we are done with the above ClickOps and the Service Quota Increase for maximum number of accounts has been
granted, we can then do the rest via Terraform.

In the Geodesic shell, as SuperAdmin, execute the following command to get the AWS Organization ID that will be used to
import the organization:

```
aws organizations describe-organization
```

From the output, identify the _organization-id_:

```
{
    "Organization": {
        "Id": "o-7qcakq6zxw",
        "Arn": "arn:aws:organizations::
        ...
```

Using the example above, the _organization-id_ is o-7qcakq6zxw.

In the Geodesic shell, as SuperAdmin, execute the following command to import the AWS Organization, changing the stack
name `core-gbl-root` if needed, to reflect the stack where the organization management account is defined, and changing
the last argument to reflect the _organization-id_ from the output of the previous command.

```
atmos terraform import account --stack core-gbl-root 'aws_organizations_organization.this[0]' 'o-7qcakq6zxw'
```

### Provision AWS OUs and Accounts using the `account` component

AWS accounts and organizational units are generated dynamically by the `terraform/account` component using the
configuration in the `gbl-root` stack.

> [!IMPORTANT]
>
> In the rare case where you will need to be enabling non-default AWS Regions, temporarily comment out the
> `DenyRootAccountAccess` service control policy setting in `gbl-root.yaml`. You will restore it later, after enabling
> the optional Regions. See related:
> [Decide on Opting Into Non-default Regions](https://docs.cloudposse.com/layers/network/design-decisions/decide-on-opting-into-non-default-regions/)

> [!TIP]
>
> #### You must wait until your quota increase request has been granted
>
> If you try to create the accounts before the quota increase is granted, you can expect to see failures like
> `ACCOUNT_NUMBER_LIMIT_EXCEEDED`.

In the Geodesic shell, execute the following commands to provision AWS Organizational Units and AWS accounts:

```
atmos terraform apply account --stack gbl-root
```

Review the Terraform plan, _**ensure that no new organization will be created**_ (look for
`aws_organizations_organization.this[0]`), type "yes" to approve and apply. This creates the AWS organizational units
and AWS accounts.

### Configure root account credentials for each account

Note: unless you need to enable non-default AWS regions (see next step), this step can be done later or in parallel with
other steps, for example while waiting for Terraform to create resources.

**For** _**each**_ **new account:**

1. Perform a password reset by attempting to [log in to the AWS console](https://signin.aws.amazon.com/signin) as a
   "root user", using that account's email address, and then clicking the "Forgot password?" link. You will receive a
   password reset link via email, which should be forwarded to the shared Slack channel for automated messages. Click
   the link and enter a new password. (Use 1Password or [Random.org](https://www.random.org/passwords) to create a
   password 26-38 characters long, including at least 3 of each class of character: lower case, uppercase, digit, and
   symbol. You may need to manually combine or add to the generated password to ensure 3 symbols and digits are
   present.) Save the email address and generated password as web login credentials in 1Password. While you are at it,
   save the account number in a separate field.

2. Log in using the new password, choose "My Security Credentials" from the account dropdown menu and set up
   Multi-Factor Authentication (MFA) to use a Virtual MFA device. Save the MFA TOTP key in 1Password by using
   1Password's TOTP field and built-in screen scanner. Also, save the Virtual MFA ARN (sometimes shown as "serial
   number").

3. While logged in, enable optional regions as described in the next step, if needed.

4. (Optional, but highly recommended): [Unsubscribe](https://pages.awscloud.com/communication-preferences.html) the
   account's email address from all marketing emails.

### (Optional) Enable regions

Most AWS regions are enabled by default. If you are using a region that is not enabled by default (such as Middle
East/Bahrain), you need to take extra steps.

1. While logged in using root credentials (see the previous step), in the account dropdown menu, select "My Account" to
   get to the [Billing home page](https://console.aws.amazon.com/billing/home?#/account).

2. In the "AWS Regions" section, enable the regions you want to enable.

3. Go to the IAM [account settings page](https://console.aws.amazon.com/iam/home?#/account_settings) and edit the STS
   Global endpoint to create session tokens valid in all AWS regions.

You will need to wait a few minutes for the regions to be enabled before you can proceed to the next step. Until they
are enabled, you may get what look like AWS authentication or permissions errors.

After enabling the regions in all accounts, re-enable the `DenyRootAccountAccess` service control policy setting in
`gbl-root.yaml` and rerun

```
atmos terraform apply account --stack gbl-root
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
| <a name="module_accounts_service_control_policies"></a> [accounts\_service\_control\_policies](#module\_accounts\_service\_control\_policies) | cloudposse/service-control-policies/aws | 0.9.2 |
| <a name="module_organization_service_control_policies"></a> [organization\_service\_control\_policies](#module\_organization\_service\_control\_policies) | cloudposse/service-control-policies/aws | 0.9.2 |
| <a name="module_organizational_units_service_control_policies"></a> [organizational\_units\_service\_control\_policies](#module\_organizational\_units\_service\_control\_policies) | cloudposse/service-control-policies/aws | 0.9.2 |
| <a name="module_service_control_policy_statements_yaml_config"></a> [service\_control\_policy\_statements\_yaml\_config](#module\_service\_control\_policy\_statements\_yaml\_config) | cloudposse/config/yaml | 1.0.2 |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |

## Resources

| Name | Type |
|------|------|
| [aws_organizations_account.organization_accounts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_account) | resource |
| [aws_organizations_account.organizational_units_accounts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_account) | resource |
| [aws_organizations_organization.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_organization) | resource |
| [aws_organizations_organizational_unit.child](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_organizational_unit) | resource |
| [aws_organizations_organizational_unit.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_organizational_unit) | resource |
| [aws_organizations_organization.existing](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/organizations_organization) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_email_format"></a> [account\_email\_format](#input\_account\_email\_format) | Email address format for the accounts (e.g. `aws+%s@example.com`) | `string` | n/a | yes |
| <a name="input_account_iam_user_access_to_billing"></a> [account\_iam\_user\_access\_to\_billing](#input\_account\_iam\_user\_access\_to\_billing) | If set to `ALLOW`, the new account enables IAM users to access account billing information if they have the required permissions. If set to `DENY`, then only the root user of the new account can access account billing information | `string` | `"DENY"` | no |
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br>This is for some rare cases where resources want additional configuration of tags<br>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br>in the order they appear in the list. New attributes are appended to the<br>end of the list. The elements of the list are joined by the `delimiter`<br>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_aws_service_access_principals"></a> [aws\_service\_access\_principals](#input\_aws\_service\_access\_principals) | List of AWS service principal names for which you want to enable integration with your organization. This is typically in the form of a URL, such as service-abbreviation.amazonaws.com. Organization must have `feature_set` set to ALL. For additional information, see the [AWS Organizations User Guide](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_integrate_services.html) | `list(string)` | n/a | yes |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "descriptor_formats": {},<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "labels_as_tags": [<br>    "unset"<br>  ],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {},<br>  "tenant": null<br>}</pre> | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br>Map of maps. Keys are names of descriptors. Values are maps of the form<br>`{<br>   format = string<br>   labels = list(string)<br>}`<br>(Type is `any` so the map values can later be enhanced to provide additional options.)<br>`format` is a Terraform format string to be passed to the `format()` function.<br>`labels` is a list of labels, in order, to pass to `format()` function.<br>Label values will be normalized before being passed to `format()` so they will be<br>identical to how they appear in `id`.<br>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_enabled_policy_types"></a> [enabled\_policy\_types](#input\_enabled\_policy\_types) | List of Organizations policy types to enable in the Organization Root. Organization must have feature\_set set to ALL. For additional information about valid policy types (e.g. SERVICE\_CONTROL\_POLICY and TAG\_POLICY), see the [AWS Organizations API Reference](https://docs.aws.amazon.com/organizations/latest/APIReference/API_EnablePolicyType.html) | `list(string)` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for keep the existing setting, which defaults to `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br>Does not affect keys of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br>set as tag values, and output by this module individually.<br>Does not affect values of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br>Default is to include all labels.<br>Tags with empty values will not be included in the `tags` output.<br>Set to `[]` to suppress all generated tags.<br>**Notes:**<br>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br>  "default"<br>]</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br>This is the only ID element not also included as a `tag`.<br>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_organization_config"></a> [organization\_config](#input\_organization\_config) | Organization, Organizational Units and Accounts configuration | `any` | n/a | yes |
| <a name="input_organization_enabled"></a> [organization\_enabled](#input\_organization\_enabled) | A boolean flag indicating whether to create an Organization or use the existing one | `bool` | `true` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br>Characters matching the regex will be removed from the ID elements.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_service_control_policies_config_paths"></a> [service\_control\_policies\_config\_paths](#input\_service\_control\_policies\_config\_paths) | List of paths to Service Control Policy configurations | `list(string)` | n/a | yes |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_account_arns"></a> [account\_arns](#output\_account\_arns) | List of account ARNs (excluding root account) |
| <a name="output_account_ids"></a> [account\_ids](#output\_account\_ids) | List of account IDs (excluding root account) |
| <a name="output_account_info_map"></a> [account\_info\_map](#output\_account\_info\_map) | Map of account names to<br>  eks: boolean, account hosts at least one EKS cluster<br>  id: account id (number)<br>  stage: (optional) the account "stage"<br>  tenant: (optional) the account "tenant" |
| <a name="output_account_names_account_arns"></a> [account\_names\_account\_arns](#output\_account\_names\_account\_arns) | Map of account names to account ARNs (excluding root account) |
| <a name="output_account_names_account_ids"></a> [account\_names\_account\_ids](#output\_account\_names\_account\_ids) | Map of account names to account IDs (excluding root account) |
| <a name="output_account_names_account_scp_arns"></a> [account\_names\_account\_scp\_arns](#output\_account\_names\_account\_scp\_arns) | Map of account names to SCP ARNs for accounts with SCPs |
| <a name="output_account_names_account_scp_ids"></a> [account\_names\_account\_scp\_ids](#output\_account\_names\_account\_scp\_ids) | Map of account names to SCP IDs for accounts with SCPs |
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
<!-- prettier-ignore-end -->

## References

- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/account) -
  Cloud Posse's upstream component

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
