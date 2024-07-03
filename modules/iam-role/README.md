# Component: `iam-role`

This component is responsible for provisioning simple IAM roles. If a more complicated IAM role and policy are desired
then it is better to use a separate component specific to that role.

## Usage

**Stack Level**: Global

Abstract

```yaml
# stacks/catalog/iam-role.yaml
components:
  terraform:
    iam-role/defaults:
      metadata:
        type: abstract
        component: iam-role
      settings:
        spacelift:
          workspace_enabled: true
      vars:
        enabled: true
```

Use-case: An IAM role for AWS Workspaces Directory since this service does not have a service linked role.

```yaml
# stacks/catalog/aws-workspaces/directory/iam-role.yaml
import:
  - catalog/iam-role

components:
  terraform:
    aws-workspaces/directory/iam-role:
      metadata:
        component: iam-role
        inherits:
          - iam-role/defaults
      vars:
        name: workspaces_DefaultRole
        # Added _ here to allow the _ character
        regex_replace_chars: /[^a-zA-Z0-9-_]/
        # Keep the current name casing
        label_value_case: none
        # Use the "name" without the other context inputs i.e. namespace, tenant, environment, attributes
        use_fullname: false
        role_description: |
          Used with AWS Workspaces Directory. The name of the role does not match the normal naming convention because this name is a requirement to work with the service. This role has to be used until AWS provides the respective service linked role.
        principals:
          Service:
            - workspaces.amazonaws.com
        # This will prevent the creation of a managed IAM policy
        policy_document_count: 0
        managed_policy_arns:
          - arn:aws:iam::aws:policy/AmazonWorkSpacesServiceAccess
          - arn:aws:iam::aws:policy/AmazonWorkSpacesSelfServiceAccess
```

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


## Reference

### Version Requirements

- [`terraform`](https://registry.terraform.io/modules/terraform/>= 1.0.0), version: >= 1.0.0
- [`aws`](https://registry.terraform.io/modules/aws/>= 4.9.0), version: >= 4.9.0

https://registry.terraform.io/modules/cloudposse/stack-config/yaml//remote-state



### Modules

Name | Version | Source | Description
--- | --- | --- | ---
`iam_roles` | latest | [`../account-map/modules/iam-roles`](https://registry.terraform.io/modules/../account-map/modules/iam-roles/) | n/a
`role` | 0.17.0 | [`cloudposse/iam-role/aws`](https://registry.terraform.io/modules/cloudposse/iam-role/aws/0.17.0) | n/a
`this` | 0.25.0 | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | n/a




### Context Variables

The following variables are defined in the `context.tf` file of this module and part of the [terraform-null-label](https://registry.terraform.io/modules/cloudposse/label/null) pattern.

<dl>
  <dt>`additional_tag_map` (`map(string)`) <i>optional</i></dt>
  <dd>
    Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br/>
    This is for some rare cases where resources want additional configuration of tags<br/>
    and therefore take a list of maps with tag key, value, and additional configuration.<br/>
    <br/>
    **Required:** No<br/>
    **Type:** `map(string)`
    **Default value:** `{}`
  </dd>
  <dt>`attributes` (`list(string)`) <i>optional</i></dt>
  <dd>
    ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br/>
    in the order they appear in the list. New attributes are appended to the<br/>
    end of the list. The elements of the list are joined by the `delimiter`<br/>
    and treated as a single ID element.<br/>
    <br/>
    **Required:** No<br/>
    **Type:** `list(string)`
    **Default value:** `[]`
  </dd>
  <dt>`context` (`any`) <i>optional</i></dt>
  <dd>
    Single object for setting entire context at once.<br/>
    See description of individual variables for details.<br/>
    Leave string and numeric variables as `null` to use default value.<br/>
    Individual variable settings (non-null) override settings in context object,<br/>
    except for attributes, tags, and additional_tag_map, which are merged.<br/>
    <br/>
    **Required:** No<br/>
    **Type:** `any`
    **Default value:** 
    ```hcl
    {
      "additional_tag_map": {},
      "attributes": [],
      "delimiter": null,
      "descriptor_formats": {},
      "enabled": true,
      "environment": null,
      "id_length_limit": null,
      "label_key_case": null,
      "label_order": [],
      "label_value_case": null,
      "labels_as_tags": [
        "unset"
      ],
      "name": null,
      "namespace": null,
      "regex_replace_chars": null,
      "stage": null,
      "tags": {},
      "tenant": null
    }
    ```
    
  </dd>
  <dt>`delimiter` (`string`) <i>optional</i></dt>
  <dd>
    Delimiter to be used between ID elements.<br/>
    Defaults to `-` (hyphen). Set to `""` to use no delimiter at all.<br/>
    <br/>
    **Required:** No<br/>
    **Type:** `string`
    **Default value:** `null`
  </dd>
  <dt>`descriptor_formats` (`any`) <i>optional</i></dt>
  <dd>
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
    **Required:** No<br/>
    **Type:** `any`
    **Default value:** `{}`
  </dd>
  <dt>`enabled` (`bool`) <i>optional</i></dt>
  <dd>
    Set to false to prevent the module from creating any resources<br/>
    **Required:** No<br/>
    **Type:** `bool`
    **Default value:** `null`
  </dd>
  <dt>`environment` (`string`) <i>optional</i></dt>
  <dd>
    ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT'<br/>
    **Required:** No<br/>
    **Type:** `string`
    **Default value:** `null`
  </dd>
  <dt>`id_length_limit` (`number`) <i>optional</i></dt>
  <dd>
    Limit `id` to this many characters (minimum 6).<br/>
    Set to `0` for unlimited length.<br/>
    Set to `null` for keep the existing setting, which defaults to `0`.<br/>
    Does not affect `id_full`.<br/>
    <br/>
    **Required:** No<br/>
    **Type:** `number`
    **Default value:** `null`
  </dd>
  <dt>`label_key_case` (`string`) <i>optional</i></dt>
  <dd>
    Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br/>
    Does not affect keys of tags passed in via the `tags` input.<br/>
    Possible values: `lower`, `title`, `upper`.<br/>
    Default value: `title`.<br/>
    <br/>
    **Required:** No<br/>
    **Type:** `string`
    **Default value:** `null`
  </dd>
  <dt>`label_order` (`list(string)`) <i>optional</i></dt>
  <dd>
    The order in which the labels (ID elements) appear in the `id`.<br/>
    Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br/>
    You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present.<br/>
    <br/>
    **Required:** No<br/>
    **Type:** `list(string)`
    **Default value:** `null`
  </dd>
  <dt>`label_value_case` (`string`) <i>optional</i></dt>
  <dd>
    Controls the letter case of ID elements (labels) as included in `id`,<br/>
    set as tag values, and output by this module individually.<br/>
    Does not affect values of tags passed in via the `tags` input.<br/>
    Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br/>
    Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br/>
    Default value: `lower`.<br/>
    <br/>
    **Required:** No<br/>
    **Type:** `string`
    **Default value:** `null`
  </dd>
  <dt>`labels_as_tags` (`set(string)`) <i>optional</i></dt>
  <dd>
    Set of labels (ID elements) to include as tags in the `tags` output.<br/>
    Default is to include all labels.<br/>
    Tags with empty values will not be included in the `tags` output.<br/>
    Set to `[]` to suppress all generated tags.<br/>
    **Notes:**<br/>
      The value of the `name` tag, if included, will be the `id`, not the `name`.<br/>
      Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br/>
      changed in later chained modules. Attempts to change it will be silently ignored.<br/>
    <br/>
    **Required:** No<br/>
    **Type:** `set(string)`
    **Default value:** 
    ```hcl
    [
      "default"
    ]
    ```
    
  </dd>
  <dt>`name` (`string`) <i>optional</i></dt>
  <dd>
    ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br/>
    This is the only ID element not also included as a `tag`.<br/>
    The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input.<br/>
    <br/>
    **Required:** No<br/>
    **Type:** `string`
    **Default value:** `null`
  </dd>
  <dt>`namespace` (`string`) <i>optional</i></dt>
  <dd>
    ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique<br/>
    **Required:** No<br/>
    **Type:** `string`
    **Default value:** `null`
  </dd>
  <dt>`regex_replace_chars` (`string`) <i>optional</i></dt>
  <dd>
    Terraform regular expression (regex) string.<br/>
    Characters matching the regex will be removed from the ID elements.<br/>
    If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits.<br/>
    <br/>
    **Required:** No<br/>
    **Type:** `string`
    **Default value:** `null`
  </dd>
  <dt>`stage` (`string`) <i>optional</i></dt>
  <dd>
    ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release'<br/>
    **Required:** No<br/>
    **Type:** `string`
    **Default value:** `null`
  </dd>
  <dt>`tags` (`map(string)`) <i>optional</i></dt>
  <dd>
    Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br/>
    Neither the tag keys nor the tag values will be modified by this module.<br/>
    <br/>
    **Required:** No<br/>
    **Type:** `map(string)`
    **Default value:** `{}`
  </dd>
  <dt>`tenant` (`string`) <i>optional</i></dt>
  <dd>
    ID element _(Rarely used, not included by default)_. A customer identifier, indicating who this instance of a resource is for<br/>
    **Required:** No<br/>
    **Type:** `string`
    **Default value:** `null`
  </dd>
</dl>

### Required Inputs

<dl>
  <dt>`region` (`string`) <i>required</i></dt>
  <dd>
    AWS Region<br/>

    **Type:** `string`
    <br/>
    **Default value:** ``

  </dd>
  <dt>`role_description` (`string`) <i>required</i></dt>
  <dd>
    The description of the IAM role that is visible in the IAM role manager<br/>

    **Type:** `string`
    <br/>
    **Default value:** ``

  </dd>
</dl>

### Optional Inputs

<dl>
  <dt>`assume_role_actions` (`list(string)`) <i>optional</i></dt>
  <dd>
    The IAM action to be granted by the AssumeRole policy<br/>
    <br/>
    **Type:** `list(string)`
    <br/>
    **Default value:** 
    ```hcl
    [
      "sts:AssumeRole",
      "sts:SetSourceIdentity",
      "sts:TagSession"
    ]
    ```
    
  </dd>
  <dt>`assume_role_conditions` <i>optional</i></dt>
  <dd>
    List of conditions for the assume role policy<br/>
    <br/>
    **Type:** 

    ```hcl
    list(object({
    test     = string
    variable = string
    values   = list(string)
  }))
    ```
    
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`instance_profile_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    Create EC2 Instance Profile for the role<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`managed_policy_arns` (`set(string)`) <i>optional</i></dt>
  <dd>
    List of managed policies to attach to created role<br/>
    <br/>
    **Type:** `set(string)`
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`max_session_duration` (`number`) <i>optional</i></dt>
  <dd>
    The maximum session duration (in seconds) for the role. Can have a value from 1 hour to 12 hours<br/>
    <br/>
    **Type:** `number`
    <br/>
    **Default value:** `3600`
  </dd>
  <dt>`path` (`string`) <i>optional</i></dt>
  <dd>
    Path to the role and policy. See [IAM Identifiers](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_identifiers.html) for more information.<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"/"`
  </dd>
  <dt>`permissions_boundary` (`string`) <i>optional</i></dt>
  <dd>
    ARN of the policy that is used to set the permissions boundary for the role<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `""`
  </dd>
  <dt>`policy_description` (`string`) <i>optional</i></dt>
  <dd>
    The description of the IAM policy that is visible in the IAM policy manager<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `""`
  </dd>
  <dt>`policy_document_count` (`number`) <i>optional</i></dt>
  <dd>
    Number of policy documents (length of policy_documents list)<br/>
    <br/>
    **Type:** `number`
    <br/>
    **Default value:** `1`
  </dd>
  <dt>`policy_documents` (`list(string)`) <i>optional</i></dt>
  <dd>
    List of JSON IAM policy documents<br/>
    <br/>
    **Type:** `list(string)`
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`policy_name` (`string`) <i>optional</i></dt>
  <dd>
    The name of the IAM policy that is visible in the IAM policy manager<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`principals` (`map(list(string))`) <i>optional</i></dt>
  <dd>
    Map of service name as key and a list of ARNs to allow assuming the role as value (e.g. map(`AWS`, list(`arn:aws:iam:::role/admin`)))<br/>
    <br/>
    **Type:** `map(list(string))`
    <br/>
    **Default value:** `{}`
  </dd>
  <dt>`tags_enabled` (`string`) <i>optional</i></dt>
  <dd>
    Enable/disable tags on IAM roles and policies<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `true`
  </dd>
  <dt>`use_fullname` (`bool`) <i>optional</i></dt>
  <dd>
    If set to 'true' then the full ID for the IAM role name (e.g. `[var.namespace]-[var.environment]-[var.stage]`) will be used.<br/>
    Otherwise, `var.name` will be used for the IAM role name.<br/>
    <br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `true`
  </dd></dl>


### Outputs

<dl>
  <dt>`role`</dt>
  <dd>
    IAM role module outputs<br/>
  </dd>
</dl>
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## References

- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/iam-role) -
  Cloud Posse's upstream component

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
