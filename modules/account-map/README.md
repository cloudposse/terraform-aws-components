# Component: `account-map`

This component is responsible for provisioning information only: it simply populates Terraform state with data (account
ids, groups, and roles) that other root modules need via outputs.

## Pre-requisites

- [account](https://docs.cloudposse.com/components/library/aws/account) must be provisioned before
  [account-map](https://docs.cloudposse.com/components/library/aws/account-map) component

## Usage

**Stack Level**: Global

Here is an example snippet for how to use this component. Include this snippet in the stack configuration for the
management account (typically `root`) in the management tenant/OU (usually something like `mgmt` or `core`) in the
global region (`gbl`). You can include the content directly, or create a `stacks/catalog/account-map.yaml` file and
import it from there.

```yaml
components:
  terraform:
    account-map:
      vars:
        enabled: true
        # Set profiles_enabled to false unless we are using AWS config profiles for Terraform access.
        # When profiles_enabled is false, role_arn must be provided instead of profile in each terraform component provider.
        # This is automatically handled by the component's `provider.tf` file in conjunction with
        # the `account-map/modules/iam-roles` module.
        profiles_enabled: false
        root_account_aws_name: "aws-root"
        root_account_account_name: root
        identity_account_account_name: identity
        dns_account_account_name: dns
        audit_account_account_name: audit

        # The following variables contain `format()` strings that take the labels from `null-label`
        # as arguments in the standard order. The default values are shown here, assuming
        # the `null-label.label_order` is
        # ["namespace", "tenant", "environment", "stage", "name", "attributes"]
        # Note that you can rearrange the order of the labels in the template by
        # using [explicit argument indexes](https://pkg.go.dev/fmt#hdr-Explicit_argument_indexes) just like in `go`.

        #  `iam_role_arn_template_template` is the template for the template [sic] used to render Role ARNs.
        #  The template is first used to render a template for the account that takes only the role name.
        #  Then that rendered template is used to create the final Role ARN for the account.
        iam_role_arn_template_template: "arn:%s:iam::%s:role/%s-%s-%s-%s-%%s"
        # `profile_template` is the template used to render AWS Profile names.
        profile_template: "%s-%s-%s-%s-%s"
```

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->



## Version Requirements

| Requirement | Version |
| --- | --- |
| `terraform` | >= 1.2.0 |
| `aws` | >= 4.9.0 |
| `local` | >= 1.3 |
| `utils` | >= 1.10.0 |


## Providers

| Provider | Version |
| --- | --- |
| `aws` | >= 4.9.0 |
| `local` | >= 1.3 |
| `utils` | >= 1.10.0 |


## Modules

Name | Version | Source | Description
--- | --- | --- | ---
`accounts` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a
`atmos` | 0.25.0 | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | n/a
`this` | 0.25.0 | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | n/a


## Resources

The following resources are used by this module:

  - [`local_file.account_info`](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) (resource)(outputs.tf#115)

## Data Sources

The following data sources are used by this module:

  - [`aws_organizations_organization.organization`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/organizations_organization) (data source)
  - [`aws_partition.current`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) (data source)
  - [`utils_describe_stacks.team_roles`](https://registry.terraform.io/providers/cloudposse/utils/latest/docs/data-sources/describe_stacks) (data source)
  - [`utils_describe_stacks.teams`](https://registry.terraform.io/providers/cloudposse/utils/latest/docs/data-sources/describe_stacks) (data source)

## Outputs

<dl>
  <dt><code>account_info_map</code></dt>
  <dd>
    A map from account name to various information about the account.<br/>
    See the `account_info_map` output of `account` for more detail.<br/>
    <br/>

  </dd>
  <dt><code>all_accounts</code></dt>
  <dd>
    A list of all accounts in the AWS Organization<br/>

  </dd>
  <dt><code>artifacts_account_account_name</code></dt>
  <dd>
    The short name for the artifacts account<br/>

  </dd>
  <dt><code>audit_account_account_name</code></dt>
  <dd>
    The short name for the audit account<br/>

  </dd>
  <dt><code>aws_partition</code></dt>
  <dd>
    The AWS "partition" to use when constructing resource ARNs<br/>

  </dd>
  <dt><code>cicd_profiles</code> <strong>OBSOLETE</strong></dt>
  <dd>
    dummy results returned to avoid breaking code that depends on this output<br/>

  </dd>
  <dt><code>cicd_roles</code> <strong>OBSOLETE</strong></dt>
  <dd>
    dummy results returned to avoid breaking code that depends on this output<br/>

  </dd>
  <dt><code>dns_account_account_name</code></dt>
  <dd>
    The short name for the primary DNS account<br/>

  </dd>
  <dt><code>eks_accounts</code></dt>
  <dd>
    A list of all accounts in the AWS Organization that contain EKS clusters<br/>

  </dd>
  <dt><code>full_account_map</code></dt>
  <dd>
    The map of account name to account ID (number).<br/>

  </dd>
  <dt><code>helm_profiles</code> <strong>OBSOLETE</strong></dt>
  <dd>
    dummy results returned to avoid breaking code that depends on this output<br/>

  </dd>
  <dt><code>helm_roles</code> <strong>OBSOLETE</strong></dt>
  <dd>
    dummy results returned to avoid breaking code that depends on this output<br/>

  </dd>
  <dt><code>iam_role_arn_templates</code></dt>
  <dd>
    Map of accounts to corresponding IAM Role ARN templates<br/>

  </dd>
  <dt><code>identity_account_account_name</code></dt>
  <dd>
    The short name for the account holding primary IAM roles<br/>

  </dd>
  <dt><code>non_eks_accounts</code></dt>
  <dd>
    A list of all accounts in the AWS Organization that do not contain EKS clusters<br/>

  </dd>
  <dt><code>org</code></dt>
  <dd>
    The name of the AWS Organization<br/>

  </dd>
  <dt><code>profiles_enabled</code></dt>
  <dd>
    Whether or not to enable profiles instead of roles for the backend<br/>

  </dd>
  <dt><code>root_account_account_name</code></dt>
  <dd>
    The short name for the root account<br/>

  </dd>
  <dt><code>root_account_aws_name</code></dt>
  <dd>
    The name of the root account as reported by AWS<br/>

  </dd>
  <dt><code>terraform_access_map</code></dt>
  <dd>
    Mapping of team Role ARN to map of account name to terraform action role ARN to assume<br/>
    <br/>
    For each team in `aws-teams`, look at every account and see if that team has access to the designated "apply" role.<br/>
      If so, add an entry `<account-name> = "apply"` to the `terraform_access_map` entry for that team.<br/>
      If not, see if it has access to the "plan" role, and if so, add a "plan" entry.<br/>
      Otherwise, no entry is added.<br/>
    <br/>

  </dd>
  <dt><code>terraform_dynamic_role_enabled</code></dt>
  <dd>
    True if dynamic role for Terraform is enabled<br/>

  </dd>
  <dt><code>terraform_profiles</code></dt>
  <dd>
    A list of all SSO profiles used to run terraform updates<br/>

  </dd>
  <dt><code>terraform_role_name_map</code></dt>
  <dd>
    Mapping of Terraform action (plan or apply) to aws-team-role name to assume for that action<br/>

  </dd>
  <dt><code>terraform_roles</code></dt>
  <dd>
    A list of all IAM roles used to run terraform updates<br/>

  </dd>
</dl>

## Required Variables

Required variables are the minimum set of variables that must be set to use this module.

> [!IMPORTANT]
>
> To customize the names and tags of the resources created by this module, see the [context variables](#context-variables).
>
### `region` (`string`) <i>required</i>


AWS Region<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>Yes</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code></code>>   </dd>
> </dl>
>


### `root_account_aws_name` (`string`) <i>required</i>


The name of the root account as reported by AWS<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>Yes</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code></code>>   </dd>
> </dl>
>



## Optional Variables
### `artifacts_account_account_name` (`string`) <i>optional</i>


The short name for the artifacts account<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>"artifacts"</code>>   </dd>
> </dl>
>


### `audit_account_account_name` (`string`) <i>optional</i>


The short name for the audit account<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>"audit"</code>>   </dd>
> </dl>
>


### `aws_config_identity_profile_name` (`string`) <i>optional</i>


The AWS config profile name to use as `source_profile` for credentials.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>>   </dd>
> </dl>
>


### `dns_account_account_name` (`string`) <i>optional</i>


The short name for the primary DNS account<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>"dns"</code>>   </dd>
> </dl>
>


### `iam_role_arn_template_template` (`string`) <i>optional</i>


The template for the template used to render Role ARNs.<br/>
The template is first used to render a template for the account that takes only the role name.<br/>
Then that rendered template is used to create the final Role ARN for the account.<br/>
Default is appropriate when using `tenant` and default label order with `null-label`.<br/>
Use `"arn:%s:iam::%s:role/%s-%s-%s-%%s"` when not using `tenant`.<br/>
<br/>
Note that if the `null-label` variable `label_order` is truncated or extended with additional labels, this template will<br/>
need to be updated to reflect the new number of labels.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>"arn:%s:iam::%s:role/%s-%s-%s-%s-%%s"</code>>   </dd>
> </dl>
>


### `identity_account_account_name` (`string`) <i>optional</i>


The short name for the account holding primary IAM roles<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>"identity"</code>>   </dd>
> </dl>
>


### `legacy_terraform_uses_admin` (`bool`) <i>optional</i>


If `true`, the legacy behavior of using the `admin` role rather than the `terraform` role in the<br/>
`root` and identity accounts will be preserved.<br/>
The default is to use the negations of the value of `terraform_dynamic_role_enabled`.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>>   </dd>
> </dl>
>


### `profile_template` (`string`) <i>optional</i>


The template used to render AWS Profile names.<br/>
Default is appropriate when using `tenant` and default label order with `null-label`.<br/>
Use `"%s-%s-%s-%s"` when not using `tenant`.<br/>
<br/>
Note that if the `null-label` variable `label_order` is truncated or extended with additional labels, this template will<br/>
need to be updated to reflect the new number of labels.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>"%s-%s-%s-%s-%s"</code>>   </dd>
> </dl>
>


### `profiles_enabled` (`bool`) <i>optional</i>


Whether or not to enable profiles instead of roles for the backend. If true, profile must be set. If false, role_arn must be set.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>false</code>>   </dd>
> </dl>
>


### `root_account_account_name` (`string`) <i>optional</i>


The short name for the root account<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>"root"</code>>   </dd>
> </dl>
>


### `terraform_dynamic_role_enabled` (`bool`) <i>optional</i>


If true, the IAM role Terraform will assume will depend on the identity of the user running terraform<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>false</code>>   </dd>
> </dl>
>


### `terraform_role_name_map` (`map(string)`) <i>optional</i>


Mapping of Terraform action (plan or apply) to aws-team-role name to assume for that action<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>map(string)</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    
>
>    ```hcl>
>    {
>
>      "apply": "terraform",
>
>      "plan": "planner"
>
>    }
>
>    ```
>>   </dd>
> </dl>
>



## Context Variables

The following variables are defined in the `context.tf` file of this module and part of the [terraform-null-label](https://registry.terraform.io/modules/cloudposse/label/null) pattern. These are identical in all Cloud Posse modules.

<details>
<summary>Click to expand</summary>


### `additional_tag_map` (`map(string)`) <i>optional</i>


Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br/>
This is for some rare cases where resources want additional configuration of tags<br/>
and therefore take a list of maps with tag key, value, and additional configuration.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>map(string)</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>{}</code>>   </dd>
> </dl>
>


### `attributes` (`list(string)`) <i>optional</i>


ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br/>
in the order they appear in the list. New attributes are appended to the<br/>
end of the list. The elements of the list are joined by the `delimiter`<br/>
and treated as a single ID element.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>[]</code>>   </dd>
> </dl>
>


### `context` (`any`) <i>optional</i>


Single object for setting entire context at once.<br/>
See description of individual variables for details.<br/>
Leave string and numeric variables as `null` to use default value.<br/>
Individual variable settings (non-null) override settings in context object,<br/>
except for attributes, tags, and additional_tag_map, which are merged.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>any</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    
>
>    ```hcl>
>    {
>
>      "additional_tag_map": {},
>
>      "attributes": [],
>
>      "delimiter": null,
>
>      "descriptor_formats": {},
>
>      "enabled": true,
>
>      "environment": null,
>
>      "id_length_limit": null,
>
>      "label_key_case": null,
>
>      "label_order": [],
>
>      "label_value_case": null,
>
>      "labels_as_tags": [
>
>        "unset"
>
>      ],
>
>      "name": null,
>
>      "namespace": null,
>
>      "regex_replace_chars": null,
>
>      "stage": null,
>
>      "tags": {},
>
>      "tenant": null
>
>    }
>
>    ```
>>   </dd>
> </dl>
>


### `delimiter` (`string`) <i>optional</i>


Delimiter to be used between ID elements.<br/>
Defaults to `-` (hyphen). Set to `""` to use no delimiter at all.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>>   </dd>
> </dl>
>


### `descriptor_formats` (`any`) <i>optional</i>


Describe additional descriptors to be output in the `descriptors` output map.<br/>
Map of maps. Keys are names of descriptors. Values are maps of the form<br/>
`{<br/>
   format = string<br/>
   labels = list(string)<br/>
}`<br/>
(Type is `any` so the map values can later be enhanced to provide additional options.)<br/>
`format` is a Terraform format string to be passed to the `format()` function.<br/>
`labels` is a list of labels, in order, to pass to `format()` function.<br/>
Label values will be normalized before being passed to `format()` so they will be<br/>
identical to how they appear in `id`.<br/>
Default is `{}` (`descriptors` output will be empty).<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>any</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>{}</code>>   </dd>
> </dl>
>


### `enabled` (`bool`) <i>optional</i>


Set to false to prevent the module from creating any resources<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>>   </dd>
> </dl>
>


### `environment` (`string`) <i>optional</i>


ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT'<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>>   </dd>
> </dl>
>


### `id_length_limit` (`number`) <i>optional</i>


Limit `id` to this many characters (minimum 6).<br/>
Set to `0` for unlimited length.<br/>
Set to `null` for keep the existing setting, which defaults to `0`.<br/>
Does not affect `id_full`.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>number</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>>   </dd>
> </dl>
>


### `label_key_case` (`string`) <i>optional</i>


Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br/>
Does not affect keys of tags passed in via the `tags` input.<br/>
Possible values: `lower`, `title`, `upper`.<br/>
Default value: `title`.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>>   </dd>
> </dl>
>


### `label_order` (`list(string)`) <i>optional</i>


The order in which the labels (ID elements) appear in the `id`.<br/>
Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br/>
You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>>   </dd>
> </dl>
>


### `label_value_case` (`string`) <i>optional</i>


Controls the letter case of ID elements (labels) as included in `id`,<br/>
set as tag values, and output by this module individually.<br/>
Does not affect values of tags passed in via the `tags` input.<br/>
Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br/>
Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br/>
Default value: `lower`.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>>   </dd>
> </dl>
>


### `labels_as_tags` (`set(string)`) <i>optional</i>


Set of labels (ID elements) to include as tags in the `tags` output.<br/>
Default is to include all labels.<br/>
Tags with empty values will not be included in the `tags` output.<br/>
Set to `[]` to suppress all generated tags.<br/>
**Notes:**<br/>
  The value of the `name` tag, if included, will be the `id`, not the `name`.<br/>
  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br/>
  changed in later chained modules. Attempts to change it will be silently ignored.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>set(string)</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    
>
>    ```hcl>
>    [
>
>      "default"
>
>    ]
>
>    ```
>>   </dd>
> </dl>
>


### `name` (`string`) <i>optional</i>


ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br/>
This is the only ID element not also included as a `tag`.<br/>
The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>>   </dd>
> </dl>
>


### `namespace` (`string`) <i>optional</i>


ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>>   </dd>
> </dl>
>


### `regex_replace_chars` (`string`) <i>optional</i>


Terraform regular expression (regex) string.<br/>
Characters matching the regex will be removed from the ID elements.<br/>
If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>>   </dd>
> </dl>
>


### `stage` (`string`) <i>optional</i>


ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release'<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>>   </dd>
> </dl>
>


### `tags` (`map(string)`) <i>optional</i>


Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br/>
Neither the tag keys nor the tag values will be modified by this module.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>map(string)</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>{}</code>>   </dd>
> </dl>
>


### `tenant` (`string`) <i>optional</i>


ID element _(Rarely used, not included by default)_. A customer identifier, indicating who this instance of a resource is for<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>>   </dd>
> </dl>
>



</details>
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## References

- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/account-map) -
  Cloud Posse's upstream component

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
