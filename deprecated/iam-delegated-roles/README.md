# Component: `iam-delegated-roles`

This component is responsible for provisioning all user and system IAM roles. It sets them up to be assumed from the primary, `identity` account roles. This is expected to be used alongside and applied after [the `iam-primary-roles` component][1] is applied to the identity account.

## Usage

**Stack Level**: Global
**Deployment**: Must be deployed by SuperAdmin using `atmos` CLI

Here's an example snippet for how to use this component. This specific usage is intended to be used as the default, and is therefore more restrictive than you may want for development accounts, and not restrictive enough for sensitive accounts like `audit`. You can make account-specific changes by importing this default configuration and then overriding settings, for example by setting `enabled: false` for roles you do not want created in that account, limiting access by setting a different value for `trusted_primary_roles`, or by changing the permissions available to that role by overriding the `role_policy_arns` (not recommended, limit access to the role instead).

Note that when overriding, **maps are deep merged, but lists are replaced**. This means, for example, that your setting of `trusted_primary_roles` in an override completely replaces the default, it does not add to it, so if you want to allow an extra "primary" role to have access to the role, you have to include all the default "primary" roles in the list, too, or they will lose access.

```yaml
components:
  terraform:
    iam-delegated-roles:
      backend:
        s3:
          # Override the default Role for accessing the backend, because SuperAdmin is not allowed to assume that role
          role_arn: null
      vars:
        enabled: true
        roles:
          # `template` serves as the default configuration for other roles via the YAML anchor.
          # However, `atmos` does not support "import" of YAML anchors, so if you define a new role
          # in another file, you will not be able to reference this anchor.
          template: &user-template
            # If `enabled: false`, the role will not be created in this account
            enabled: false

            # `max_session_duration` set the maximum session duration (in seconds) for the IAM roles.
            # This setting can have a value from 3600 (1 hour) to 43200 (12 hours).
            # For roles people log into via SAML, a long duration is convenient to prevent them
            # from having to frequently re-authenticate.
            # For roles assumed from some other role, the setting is practically irrelevant, because
            # the AssumeRole API limits the duration to 1 hour in any case.
            # References:
            # - https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use.html
            # - https://docs.aws.amazon.com/STS/latest/APIReference/API_AssumeRole.html
            max_session_duration: 3600 # 1 hour in seconds

            # role_policy_arns are the IAM Policy ARNs to attach to this policy. In addition to real ARNs,
            # you can use keys in the `custom_policy_map` in `main.tf` to select policies defined in the component.
            # If you are using keys from the map, plans look better if you put them after the real role ARNs.
            role_policy_arns: []
            role_description: "Template role, should not exist"

            # If `sso_login_enabled: true` then the role will be available via SAML logins,
            # but only via the SAML IDPs configured for this account.
            # Otherwise, it will only be accessible via `assume role`.
            sso_login_enabled: false

            ## The following attributes control access to this role via `assume role`.
            ## `trusted_*` grants access, `denied_*` denies access.
            ## If a role is both trusted and denied, it will not be able to access this role.

            # Permission sets specify users operating from the given AWS SSO permission set in this account.
            trusted_permission_sets: []
            denied_permission_sets: []

            # Primary roles specify the short role names of roles in the primary (identity)
            # account that are allowed to assume this role.
            # BE CAREFUL: This is setting the default access for other roles.
            trusted_primary_roles: []
            denied_primary_roles: []

            # Role ARNs specify Role ARNs in any account that are allowed to assume this role.
            # BE CAREFUL: there is nothing limiting these Role ARNs to roles within our organization.
            trusted_role_arns: []
            denied_role_arns: []

          ##
          ## admin, terraform, and helm are the core delegated roles
          ## We configure them here for "restricted" accounts, with other categories overriding as needed.
          ##

          admin:
            <<: *user-template
            enabled: true
            role_policy_arns:
            - "arn:aws:iam::aws:policy/AdministratorAccess"
            role_description: "Full administration of this account"
            trusted_primary_roles: ["admin"]
            trusted_permission_sets: ["AdministratorAccess"]

          helm:
            <<: *user-template
            enabled: true
            role_policy_arns:
            - "arn:aws:iam::aws:policy/AdministratorAccess"
            role_description: "Role for Helm administration of this account"
            trusted_primary_roles: ["admin", "cicd"]
            # Unfortunately, we have not yet figured out acceptable limits on Helm.
            # It might work with PowerUser (further restricted to deny AWS SSO changes).
            trusted_permission_sets: ["AdministratorAccess"]

          terraform:
            <<: *user-template
            enabled: true
            role_policy_arns:
            - "arn:aws:iam::aws:policy/AdministratorAccess"
            role_description: "Role for Terraform administration of this account"
            trusted_primary_roles: ["admin", "spacelift"]
            # We require Terraform to be allowed to create and modify IAM roles
            # and policies (e.g. for EKS service accounts), so there is no use trying to restrict it.
            # For better security, we could segregate components that needed
            # administrative permissions and use a more restrictive role
            # for Terraform, such as PowerUser (further restricted to deny AWS SSO changes).
            trusted_permission_sets: ["AdministratorAccess"]

          poweruser:
            <<: *user-template
            enabled: true
            role_policy_arns:
            - "arn:aws:iam::aws:policy/PowerUserAccess"
            - "support"
            role_description: "Role for Power Users (read/write)"
            trusted_primary_roles: ["admin", "poweruser"]
            trusted_permission_sets: ["AdministratorAccess", "PowerUserAccess"]

          # https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html#securityhub-cis-controls-1.20
          support:
            <<: *user-template
            enabled: true
            role_policy_arns:
            - "support"
            role_description: "Role with permissions for accessing the AWS Support Service"
            # Terraform is too powerful a role to allow powerusers to access it
            trusted_primary_roles: ["admin", "support"]
            trusted_permission_sets: ["AdministratorAccess", "SupportAccess", "ReadOnlyAccess"]

          ##
          ## observer and reader are for read-only access to the account.
          ## reader is able to read sensitive information (Read Only job function)
          ## while observer is more limited (View Only job function).
          ## Reference: https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_job-functions.html
          ##

          reader:
            <<: *user-template
            enabled: true
            role_policy_arns:
            - "arn:aws:iam::aws:policy/ReadOnlyAccess"
            - "support"
            role_description: "Read Only access (including reading S3 and other sensitive information)"
            trusted_primary_roles: ["admin", "cicd", "poweruser", "reader", "spacelift"]
            trusted_permission_sets: ["AdministratorAccess", "PowerUserAccess", "ReadOnlyAccess"]


          observer:
            <<: *user-template
            enabled: true
            role_policy_arns:
            - "arn:aws:iam::aws:policy/job-function/ViewOnlyAccess"
            - "support"
            role_description: "View Only access"
            trusted_primary_roles: ["admin", "observer", "poweruser", "reader"]
            trusted_permission_sets: ["AdministratorAccess", "PowerUserAccess", "ReadOnlyAccess"]

```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->



## Version Requirements

| Requirement | Version |
| --- | --- |
| `terraform` | >= 1.0.0 |
| `aws` | ~> 4.0 |


## Providers

| Provider | Version |
| --- | --- |
| `aws` | ~> 4.0 |


## Modules

Name | Version | Source | Description
--- | --- | --- | ---
`assume_role` | latest | [`../../modules/account-map/modules/iam-assume-role-policy`](https://registry.terraform.io/modules/../../modules/account-map/modules/iam-assume-role-policy/) | n/a
`iam_roles` | latest | [`../../modules/account-map/modules/iam-roles`](https://registry.terraform.io/modules/../../modules/account-map/modules/iam-roles/) | n/a
`sso` | 0.22.2 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/0.22.2) | n/a
`this` | 0.25.0 | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | n/a


## Resources

The following resources are used by this module:

  - [`aws_iam_policy.billing_admin`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) (resource)(policy-billing.tf#38)
  - [`aws_iam_policy.billing_read_only`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) (resource)(policy-billing.tf#13)
  - [`aws_iam_policy.support`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) (resource)(policy-support.tf#47)
  - [`aws_iam_role.default`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) (resource)(main.tf#90)
  - [`aws_iam_role_policy_attachment.default`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) (resource)(main.tf#100)

## Data Sources

The following data sources are used by this module:

  - [`aws_iam_policy.aws_billing_admin_access`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy) (data source)
  - [`aws_iam_policy.aws_billing_read_only_access`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy) (data source)
  - [`aws_iam_policy.aws_support_access`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy) (data source)
  - [`aws_iam_policy_document.assume_role_aggregated`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) (data source)
  - [`aws_iam_policy_document.billing_admin_access_aggregated`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) (data source)
  - [`aws_iam_policy_document.saml_provider_assume`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) (data source)
  - [`aws_iam_policy_document.support_access_aggregated`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) (data source)
  - [`aws_iam_policy_document.support_access_trusted_advisor`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) (data source)
  - [`aws_partition.current`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) (data source)

## Outputs

<dl>
  <dt><code>role_long_name_policy_arn_map</code></dt>
  <dd>
    Map of role long names to attached IAM Policy ARNs<br/>

  </dd>
  <dt><code>role_name_role_arn_map</code></dt>
  <dd>
    Map of role names to role ARNs<br/>

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
>    <code></code>
>   </dd>
> </dl>
>


### `roles` <i>required</i>


A roles map to configure the accounts.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>Yes</dd>
>   <dt>Type</dt>
>   <dd>
>   
>
>   ```hcl
>   map(object({
    enabled = bool

    denied_permission_sets  = list(string)
    denied_primary_roles    = list(string)
    denied_role_arns        = list(string)
    max_session_duration    = number # in seconds 3600 <= max <= 43200 (12 hours)
    role_description        = string
    role_policy_arns        = list(string)
    sso_login_enabled       = bool
    trusted_permission_sets = list(string)
    trusted_primary_roles   = list(string)
    trusted_role_arns       = list(string)
  }))
>   ```
>
>   
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code></code>
>   </dd>
> </dl>
>



## Optional Variables
### `iam_primary_roles_account_name` (`string`) <i>optional</i>


The name of the account where the IAM primary roles are provisioned<br/>

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
>    <code>"identity"</code>
>   </dd>
> </dl>
>


### `import_profile_name` (`string`) <i>optional</i>


AWS Profile name to use when importing a resource<br/>

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
>    <code>null</code>
>   </dd>
> </dl>
>


### `import_role_arn` (`string`) <i>optional</i>


IAM Role ARN to use when importing a resource<br/>

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
>    <code>null</code>
>   </dd>
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
>    <code>{}</code>
>   </dd>
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
>    <code>[]</code>
>   </dd>
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
>    ```hcl
>    {
>      "additional_tag_map": {},
>      "attributes": [],
>      "delimiter": null,
>      "descriptor_formats": {},
>      "enabled": true,
>      "environment": null,
>      "id_length_limit": null,
>      "label_key_case": null,
>      "label_order": [],
>      "label_value_case": null,
>      "labels_as_tags": [
>        "unset"
>      ],
>      "name": null,
>      "namespace": null,
>      "regex_replace_chars": null,
>      "stage": null,
>      "tags": {},
>      "tenant": null
>    }
>    ```
>
>   </dd>
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
>    <code>null</code>
>   </dd>
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
>    <code>{}</code>
>   </dd>
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
>    <code>null</code>
>   </dd>
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
>    <code>null</code>
>   </dd>
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
>    <code>null</code>
>   </dd>
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
>    <code>null</code>
>   </dd>
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
>    <code>null</code>
>   </dd>
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
>    <code>null</code>
>   </dd>
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
>    ```hcl
>    [
>      "default"
>    ]
>    ```
>
>   </dd>
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
>    <code>null</code>
>   </dd>
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
>    <code>null</code>
>   </dd>
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
>    <code>null</code>
>   </dd>
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
>    <code>null</code>
>   </dd>
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
>    <code>{}</code>
>   </dd>
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
>    <code>null</code>
>   </dd>
> </dl>
>



</details>
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## References
* [cloudposse/terraform-aws-components][44] - Cloud Posse's upstream component

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>][45]

[1]:	https://github.com/cloudposse/terraform-aws-components/tree/master/modules/iam-primary-roles
[2]:	#requirement%5C_terraform
[3]:	#requirement%5C_aws
[4]:	#requirement%5C_local
[5]:	#requirement%5C_template
[6]:	#requirement%5C_utils
[7]:	#provider%5C_aws
[8]:	#module%5C_assume%5C_role
[9]:	#module%5C_iam%5C_roles
[10]:	#module%5C_sso
[11]:	#module%5C_this
[12]:	https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy
[13]:	https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
[14]:	https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment
[15]:	https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy
[16]:	https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document
[17]:	https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document
[18]:	https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document
[19]:	https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document
[20]:	#input%5C_additional%5C_tag%5C_map
[21]:	#input%5C_attributes
[22]:	#input%5C_context
[23]:	#input%5C_delimiter
[24]:	#input%5C_descriptor%5C_formats
[25]:	#input%5C_enabled
[26]:	#input%5C_environment
[27]:	#input%5C_iam%5C_primary%5C_roles%5C_account%5C_name
[28]:	#input%5C_id%5C_length%5C_limit
[29]:	#input%5C_import%5C_role%5C_arn
[30]:	#input%5C_label%5C_key%5C_case
[31]:	#input%5C_label%5C_order
[32]:	#input%5C_label%5C_value%5C_case
[33]:	#input%5C_labels%5C_as%5C_tags
[34]:	#input%5C_name
[35]:	#input%5C_namespace
[36]:	#input%5C_regex%5C_replace%5C_chars
[37]:	#input%5C_region
[38]:	#input%5C_roles
[39]:	#input%5C_stage
[40]:	#input%5C_tags
[41]:	#input%5C_tenant
[42]:	#output%5C_role%5C_long%5C_name%5C_policy%5C_arn%5C_map
[43]:	#output%5C_role%5C_name%5C_role%5C_arn%5C_map
[44]:	https://github.com/cloudposse/terraform-aws-components/tree/master/modules/TODO
[45]:	https://cpco.io/component
