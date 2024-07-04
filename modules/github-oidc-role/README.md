# Component: `github-oidc-role`

This component is responsible for creating IAM roles for GitHub Actions to assume.

## Usage

**Stack Level**: Global

Here's an example snippet for how to use this component.

```yaml
# stacks/catalog/github-oidc-role/defaults.yaml
components:
  terraform:
    github-oidc-role/defaults:
      metadata:
        type: abstract
      vars:
        enabled: true
        name: gha-iam
        # Note: inherited lists are not merged, they are replaced
        github_actions_allowed_repos:
          - MyOrg/* ## allow all repos in MyOrg
```

Example using for gitops (predefined policy):

```yaml
# stacks/catalog/github-oidc-role/gitops.yaml
import:
  - catalog/github-oidc-role/defaults

components:
  terraform:
    github-oidc-role/gitops:
      metadata:
        component: github-oidc-role
        inherits:
          - github-oidc-role/defaults
      vars:
        enabled: true
        # Note: inherited lists are not merged, they are replaced
        github_actions_allowed_repos:
          - "MyOrg/infrastructure"
        attributes: ["gitops"]
        iam_policies:
          - gitops
        gitops_policy_configuration:
          s3_bucket_component_name: gitops/s3-bucket
          dynamodb_component_name: gitops/dynamodb
```

Example using for lambda-cicd (predefined policy):

```yaml
# stacks/catalog/github-oidc-role/lambda-cicd.yaml
import:
  - catalog/github-oidc-role/defaults

components:
  terraform:
    github-oidc-role/lambda-cicd:
      metadata:
        component: github-oidc-role
        inherits:
          - github-oidc-role/defaults
      vars:
        enabled: true
        github_actions_allowed_repos:
          - MyOrg/example-app-on-lambda-with-gha
        attributes: ["lambda-cicd"]
        iam_policies:
          - lambda-cicd
        lambda_cicd_policy_configuration:
          enable_ssm_access: true
          enable_s3_access: true
          s3_bucket_component_name: s3-bucket/github-action-artifacts
          s3_bucket_environment_name: gbl
          s3_bucket_stage_name: artifacts
          s3_bucket_tenant_name: core
```

Example Using an AWS Managed policy and a custom inline policy:

```yaml
# stacks/catalog/github-oidc-role/custom.yaml
import:
  - catalog/github-oidc-role/defaults

components:
  terraform:
    github-oidc-role/custom:
      metadata:
        component: github-oidc-role
        inherits:
          - github-oidc-role/defaults
      vars:
        enabled: true
        github_actions_allowed_repos:
          - MyOrg/example-app-on-lambda-with-gha
        attributes: ["custom"]
        iam_policies:
          - arn:aws:iam::aws:policy/AdministratorAccess
        iam_policy:
          - version: "2012-10-17"
            statements:
              - effect: "Allow"
                actions:
                  - "ec2:*"
                resources:
                  - "*"
```

### Adding Custom Policies

There are two methods for adding custom policies to the IAM role.

1. Through the `iam_policy` input which you can use to add inline policies to the IAM role.
2. By defining policies in Terraform and then attaching them to roles by name.

#### Defining Custom Policies in Terraform

1. Give the policy a unique name, e.g. `docker-publish`. We will use `NAME` as a placeholder for the name in the
   instructions below.
2. Create a file in the component directory (i.e. `github-oidc-role`) with the name `policy_NAME.tf`.
3. In that file, conditionally (based on need) create a policy document as follows:

   ```hcl
   locals {
     NAME_policy_enabled = contains(var.iam_policies, "NAME")
     NAME_policy         = local.NAME_policy_enabled ? one(data.aws_iam_policy_document.NAME.*.json) : null
   }

   data "aws_iam_policy_document" "NAME" {
     count = local.NAME_policy_enabled ? 1 : 0

     # Define the policy here
   }
   ```

   Note that you can also add input variables and outputs to this file if desired. Just make sure that all inputs are
   optional.

4. Create a file named `additional-policy-map_override.tf` in the component directory (if it does not already exist).
   This is a [terraform override file](https://developer.hashicorp.com/terraform/language/files/override), meaning its
   contents will be merged with the main terraform file, and any locals defined in it will override locals defined in
   other files. Having your code in this separate override file makes it possible for the component to provide a
   placeholder local variable so that it works without customization, while allowing you to customize the component and
   still update it without losing your customizations.
5. In that file, redefine the local variable `overridable_additional_custom_policy_map` map as follows:

   ```hcl
   locals {
     overridable_additional_custom_policy_map = {
       "NAME" = local.NAME_policy
     }
   }
   ```

   If you have multiple custom policies, using just this one file, add each policy document to the map in the form
   `NAME = local.NAME_policy`.

6. With that done, you can now attach that policy by adding the name to the `iam_policies` list. For example:

   ```yaml
   iam_policies:
     - "arn:aws:iam::aws:policy/job-function/ViewOnlyAccess"
     - "NAME"
   ```

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


## Reference

### Version Requirements

| Requirement | Version |
| --- | --- |
| `terraform` | >= 1.3.0 |
| `aws` | >= 4.9.0 |


### Providers

| Provider | Version |
| --- | --- |
| `aws` | >= 4.9.0 |


### Modules

Name | Version | Source | Description
--- | --- | --- | ---
`dynamodb` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a
`gha_assume_role` | latest | [`../account-map/modules/team-assume-role-policy`](https://registry.terraform.io/modules/../account-map/modules/team-assume-role-policy/) | n/a
`iam_policy` | 2.0.1 | [`cloudposse/iam-policy/aws`](https://registry.terraform.io/modules/cloudposse/iam-policy/aws/2.0.1) | n/a
`iam_roles` | latest | [`../account-map/modules/iam-roles`](https://registry.terraform.io/modules/../account-map/modules/iam-roles/) | n/a
`s3_artifacts_bucket` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a
`s3_bucket` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a
`this` | 0.25.0 | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | n/a


### Resources

The following resources are used by this module:

  - [`aws_iam_role.github_actions`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) (resource)(main.tf#35)

### Data Sources

The following data sources are used by this module:

  - [`aws_iam_policy_document.gitops_iam_policy`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) (data source)
  - [`aws_iam_policy_document.lambda_cicd_policy`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) (data source)

### Context Variables

The following variables are defined in the `context.tf` file of this module and part of the [terraform-null-label](https://registry.terraform.io/modules/cloudposse/label/null) pattern. These are identical in all Cloud Posse modules.

<details>
<summary>Click to expand</summary>
> ### `additional_tag_map` (`map(string)`) <i>optional</i>
>
>
> Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br/>
>
> This is for some rare cases where resources want additional configuration of tags<br/>
>
> and therefore take a list of maps with tag key, value, and additional configuration.<br/>
>
> <br/>
>
>
> <details>
> <summary>Click to expand</summary>
>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   `map(string)`
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    `{}`
>   </dd>
> </dl>
>
> </details>


> ### `attributes` (`list(string)`) <i>optional</i>
>
>
> ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br/>
>
> in the order they appear in the list. New attributes are appended to the<br/>
>
> end of the list. The elements of the list are joined by the `delimiter`<br/>
>
> and treated as a single ID element.<br/>
>
> <br/>
>
>
> <details>
> <summary>Click to expand</summary>
>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   `list(string)`
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    `[]`
>   </dd>
> </dl>
>
> </details>


> ### `context` (`any`) <i>optional</i>
>
>
> Single object for setting entire context at once.<br/>
>
> See description of individual variables for details.<br/>
>
> Leave string and numeric variables as `null` to use default value.<br/>
>
> Individual variable settings (non-null) override settings in context object,<br/>
>
> except for attributes, tags, and additional_tag_map, which are merged.<br/>
>
> <br/>
>
>
> <details>
> <summary>Click to expand</summary>
>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   `any`
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    
>    ```hcl
>>
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
>    
>   </dd>
> </dl>
>
> </details>


> ### `delimiter` (`string`) <i>optional</i>
>
>
> Delimiter to be used between ID elements.<br/>
>
> Defaults to `-` (hyphen). Set to `""` to use no delimiter at all.<br/>
>
> <br/>
>
>
> <details>
> <summary>Click to expand</summary>
>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   `string`
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    `null`
>   </dd>
> </dl>
>
> </details>


> ### `descriptor_formats` (`any`) <i>optional</i>
>
>
> Describe additional descriptors to be output in the `descriptors` output map.<br/>
>
> Map of maps. Keys are names of descriptors. Values are maps of the form<br/>
>
> `{<br/>
>
>    format = string<br/>
>
>    labels = list(string)<br/>
>
> }`<br/>
>
> (Type is `any` so the map values can later be enhanced to provide additional options.)<br/>
>
> `format` is a Terraform format string to be passed to the `format()` function.<br/>
>
> `labels` is a list of labels, in order, to pass to `format()` function.<br/>
>
> Label values will be normalized before being passed to `format()` so they will be<br/>
>
> identical to how they appear in `id`.<br/>
>
> Default is `{}` (`descriptors` output will be empty).<br/>
>
> <br/>
>
>
> <details>
> <summary>Click to expand</summary>
>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   `any`
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    `{}`
>   </dd>
> </dl>
>
> </details>


> ### `enabled` (`bool`) <i>optional</i>
>
>
> Set to false to prevent the module from creating any resources<br/>
>
>
> <details>
> <summary>Click to expand</summary>
>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   `bool`
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    `null`
>   </dd>
> </dl>
>
> </details>


> ### `environment` (`string`) <i>optional</i>
>
>
> ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT'<br/>
>
>
> <details>
> <summary>Click to expand</summary>
>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   `string`
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    `null`
>   </dd>
> </dl>
>
> </details>


> ### `id_length_limit` (`number`) <i>optional</i>
>
>
> Limit `id` to this many characters (minimum 6).<br/>
>
> Set to `0` for unlimited length.<br/>
>
> Set to `null` for keep the existing setting, which defaults to `0`.<br/>
>
> Does not affect `id_full`.<br/>
>
> <br/>
>
>
> <details>
> <summary>Click to expand</summary>
>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   `number`
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    `null`
>   </dd>
> </dl>
>
> </details>


> ### `label_key_case` (`string`) <i>optional</i>
>
>
> Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br/>
>
> Does not affect keys of tags passed in via the `tags` input.<br/>
>
> Possible values: `lower`, `title`, `upper`.<br/>
>
> Default value: `title`.<br/>
>
> <br/>
>
>
> <details>
> <summary>Click to expand</summary>
>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   `string`
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    `null`
>   </dd>
> </dl>
>
> </details>


> ### `label_order` (`list(string)`) <i>optional</i>
>
>
> The order in which the labels (ID elements) appear in the `id`.<br/>
>
> Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br/>
>
> You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present.<br/>
>
> <br/>
>
>
> <details>
> <summary>Click to expand</summary>
>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   `list(string)`
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    `null`
>   </dd>
> </dl>
>
> </details>


> ### `label_value_case` (`string`) <i>optional</i>
>
>
> Controls the letter case of ID elements (labels) as included in `id`,<br/>
>
> set as tag values, and output by this module individually.<br/>
>
> Does not affect values of tags passed in via the `tags` input.<br/>
>
> Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br/>
>
> Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br/>
>
> Default value: `lower`.<br/>
>
> <br/>
>
>
> <details>
> <summary>Click to expand</summary>
>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   `string`
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    `null`
>   </dd>
> </dl>
>
> </details>


> ### `labels_as_tags` (`set(string)`) <i>optional</i>
>
>
> Set of labels (ID elements) to include as tags in the `tags` output.<br/>
>
> Default is to include all labels.<br/>
>
> Tags with empty values will not be included in the `tags` output.<br/>
>
> Set to `[]` to suppress all generated tags.<br/>
>
> **Notes:**<br/>
>
>   The value of the `name` tag, if included, will be the `id`, not the `name`.<br/>
>
>   Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br/>
>
>   changed in later chained modules. Attempts to change it will be silently ignored.<br/>
>
> <br/>
>
>
> <details>
> <summary>Click to expand</summary>
>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   `set(string)`
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    
>    ```hcl
>>
>    [
>
>      "default"
>
>    ]
>
>    ```
>    
>   </dd>
> </dl>
>
> </details>


> ### `name` (`string`) <i>optional</i>
>
>
> ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br/>
>
> This is the only ID element not also included as a `tag`.<br/>
>
> The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input.<br/>
>
> <br/>
>
>
> <details>
> <summary>Click to expand</summary>
>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   `string`
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    `null`
>   </dd>
> </dl>
>
> </details>


> ### `namespace` (`string`) <i>optional</i>
>
>
> ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique<br/>
>
>
> <details>
> <summary>Click to expand</summary>
>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   `string`
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    `null`
>   </dd>
> </dl>
>
> </details>


> ### `regex_replace_chars` (`string`) <i>optional</i>
>
>
> Terraform regular expression (regex) string.<br/>
>
> Characters matching the regex will be removed from the ID elements.<br/>
>
> If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits.<br/>
>
> <br/>
>
>
> <details>
> <summary>Click to expand</summary>
>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   `string`
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    `null`
>   </dd>
> </dl>
>
> </details>


> ### `stage` (`string`) <i>optional</i>
>
>
> ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release'<br/>
>
>
> <details>
> <summary>Click to expand</summary>
>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   `string`
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    `null`
>   </dd>
> </dl>
>
> </details>


> ### `tags` (`map(string)`) <i>optional</i>
>
>
> Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br/>
>
> Neither the tag keys nor the tag values will be modified by this module.<br/>
>
> <br/>
>
>
> <details>
> <summary>Click to expand</summary>
>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   `map(string)`
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    `{}`
>   </dd>
> </dl>
>
> </details>


> ### `tenant` (`string`) <i>optional</i>
>
>
> ID element _(Rarely used, not included by default)_. A customer identifier, indicating who this instance of a resource is for<br/>
>
>
> <details>
> <summary>Click to expand</summary>
>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   `string`
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    `null`
>   </dd>
> </dl>
>
> </details>



</details>

### Required Variables
> ### `region` (`string`) <i>required</i>
>
>
> AWS Region<br/>
>
>
> <details>
> <summary>Click to expand</summary>
>
> <dl>
>   <dt>Required</dt>
>   <dd>Yes</dd>
>   <dt>Type</dt>
>   <dd>
>   `string`
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    ``
>   </dd>
> </dl>
>
> </details>



### Optional Variables
> ### `github_actions_allowed_repos` (`list(string)`) <i>optional</i>
>
>
>   A list of the GitHub repositories that are allowed to assume this role from GitHub Actions. For example,<br/>
>
>   ["cloudposse/infra-live"]. Can contain "*" as wildcard.<br/>
>
>   If org part of repo name is omitted, "cloudposse" will be assumed.<br/>
>
> <br/>
>
>
> <details>
> <summary>Click to expand</summary>
>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   `list(string)`
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    `[]`
>   </dd>
> </dl>
>
> </details>


> ### `gitops_policy_configuration` <i>optional</i>
>
>
> Configuration for the GitOps IAM Policy, valid keys are<br/>
>
>  - `s3_bucket_component_name` - Component Name of where to store the TF Plans in S3, defaults to `gitops/s3-bucket`<br/>
>
>  - `dynamodb_component_name` - Component Name of where to store the TF Plans in Dynamodb, defaults to `gitops/dynamodb`<br/>
>
>  - `s3_bucket_environment_name` - Environment name for the S3 Bucket, defaults to current environment<br/>
>
>  - `dynamodb_environment_name` - Environment name for the Dynamodb Table, defaults to current environment<br/>
>
> <br/>
>
>
> <details>
> <summary>Click to expand</summary>
>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   
>
>   ```hcl
>   object({
    s3_bucket_component_name   = optional(string, "gitops/s3-bucket")
    dynamodb_component_name    = optional(string, "gitops/dynamodb")
    s3_bucket_environment_name = optional(string)
    dynamodb_environment_name  = optional(string)
  })
>   ```
>   
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    `{}`
>   </dd>
> </dl>
>
> </details>


> ### `iam_policies` (`list(string)`) <i>optional</i>
>
>
> List of policies to attach to the IAM role, should be either an ARN of an AWS Managed Policy or a name of a custom policy e.g. `gitops`<br/>
>
>
> <details>
> <summary>Click to expand</summary>
>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   `list(string)`
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    `[]`
>   </dd>
> </dl>
>
> </details>


> ### `iam_policy` <i>optional</i>
>
>
> IAM policy as list of Terraform objects, compatible with Terraform `aws_iam_policy_document` data source<br/>
>
> except that `source_policy_documents` and `override_policy_documents` are not included.<br/>
>
> Use inputs `iam_source_policy_documents` and `iam_override_policy_documents` for that.<br/>
>
> <br/>
>
>
> <details>
> <summary>Click to expand</summary>
>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   
>
>   ```hcl
>   list(object({
    policy_id = optional(string, null)
    version   = optional(string, null)
    statements = list(object({
      sid           = optional(string, null)
      effect        = optional(string, null)
      actions       = optional(list(string), null)
      not_actions   = optional(list(string), null)
      resources     = optional(list(string), null)
      not_resources = optional(list(string), null)
      conditions = optional(list(object({
        test     = string
        variable = string
        values   = list(string)
      })), [])
      principals = optional(list(object({
        type        = string
        identifiers = list(string)
      })), [])
      not_principals = optional(list(object({
        type        = string
        identifiers = list(string)
      })), [])
    }))
  }))
>   ```
>   
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    `[]`
>   </dd>
> </dl>
>
> </details>


> ### `lambda_cicd_policy_configuration` <i>optional</i>
>
>
> Configuration for the lambda-cicd policy. The following keys are supported:<br/>
>
>   - `enable_kms_access` - (bool) - Whether to allow access to KMS. Defaults to false.<br/>
>
>   - `enable_ssm_access` - (bool) - Whether to allow access to SSM. Defaults to false.<br/>
>
>   - `enable_s3_access` - (bool) - Whether to allow access to S3. Defaults to false.<br/>
>
>   - `s3_bucket_component_name` - (string) - The name of the component to use for the S3 bucket. Defaults to `s3-bucket/github-action-artifacts`.<br/>
>
>   - `s3_bucket_environment_name` - (string) - The name of the environment to use for the S3 bucket. Defaults to the environment of the current module.<br/>
>
>   - `s3_bucket_tenant_name` - (string) - The name of the tenant to use for the S3 bucket. Defaults to the tenant of the current module.<br/>
>
>   - `s3_bucket_stage_name` - (string) - The name of the stage to use for the S3 bucket. Defaults to the stage of the current module.<br/>
>
>   - `enable_lambda_update` - (bool) - Whether to allow access to update lambda functions. Defaults to false.<br/>
>
> <br/>
>
>
> <details>
> <summary>Click to expand</summary>
>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   
>
>   ```hcl
>   object({
    enable_kms_access          = optional(bool, false)
    enable_ssm_access          = optional(bool, false)
    enable_s3_access           = optional(bool, false)
    s3_bucket_component_name   = optional(string, "s3-bucket/github-action-artifacts")
    s3_bucket_environment_name = optional(string)
    s3_bucket_tenant_name      = optional(string)
    s3_bucket_stage_name       = optional(string)
    enable_lambda_update       = optional(bool, false)
  })
>   ```
>   
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    `{}`
>   </dd>
> </dl>
>
> </details>



### Outputs

<dl>
  <dt><code>github_actions_iam_role_arn</code></dt>
  <dd>
    ARN of IAM role for GitHub Actions<br/>
  </dd>
  <dt><code>github_actions_iam_role_name</code></dt>
  <dd>
    Name of IAM role for GitHub Actions<br/>
  </dd>
</dl>
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## References

- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/github-oidc-role) -
  Cloud Posse's upstream component

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
