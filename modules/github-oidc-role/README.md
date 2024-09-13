---
tags:
  - component/github-oidc-role
  - layer/github
  - provider/aws
  - privileged
---

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
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.9.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.9.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_dynamodb"></a> [dynamodb](#module\_dynamodb) | cloudposse/stack-config/yaml//modules/remote-state | 1.5.0 |
| <a name="module_gha_assume_role"></a> [gha\_assume\_role](#module\_gha\_assume\_role) | ../account-map/modules/team-assume-role-policy | n/a |
| <a name="module_iam_policy"></a> [iam\_policy](#module\_iam\_policy) | cloudposse/iam-policy/aws | 2.0.1 |
| <a name="module_iam_roles"></a> [iam\_roles](#module\_iam\_roles) | ../account-map/modules/iam-roles | n/a |
| <a name="module_s3_artifacts_bucket"></a> [s3\_artifacts\_bucket](#module\_s3\_artifacts\_bucket) | cloudposse/stack-config/yaml//modules/remote-state | 1.5.0 |
| <a name="module_s3_bucket"></a> [s3\_bucket](#module\_s3\_bucket) | cloudposse/stack-config/yaml//modules/remote-state | 1.5.0 |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_role.github_actions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_policy_document.gitops_iam_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.lambda_cicd_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br>This is for some rare cases where resources want additional configuration of tags<br>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br>in the order they appear in the list. New attributes are appended to the<br>end of the list. The elements of the list are joined by the `delimiter`<br>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "descriptor_formats": {},<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "labels_as_tags": [<br>    "unset"<br>  ],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {},<br>  "tenant": null<br>}</pre> | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br>Map of maps. Keys are names of descriptors. Values are maps of the form<br>`{<br>   format = string<br>   labels = list(string)<br>}`<br>(Type is `any` so the map values can later be enhanced to provide additional options.)<br>`format` is a Terraform format string to be passed to the `format()` function.<br>`labels` is a list of labels, in order, to pass to `format()` function.<br>Label values will be normalized before being passed to `format()` so they will be<br>identical to how they appear in `id`.<br>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_github_actions_allowed_repos"></a> [github\_actions\_allowed\_repos](#input\_github\_actions\_allowed\_repos) | A list of the GitHub repositories that are allowed to assume this role from GitHub Actions. For example,<br>  ["cloudposse/infra-live"]. Can contain "*" as wildcard.<br>  If org part of repo name is omitted, "cloudposse" will be assumed. | `list(string)` | `[]` | no |
| <a name="input_gitops_policy_configuration"></a> [gitops\_policy\_configuration](#input\_gitops\_policy\_configuration) | Configuration for the GitOps IAM Policy, valid keys are<br> - `s3_bucket_component_name` - Component Name of where to store the TF Plans in S3, defaults to `gitops/s3-bucket`<br> - `dynamodb_component_name` - Component Name of where to store the TF Plans in Dynamodb, defaults to `gitops/dynamodb`<br> - `s3_bucket_environment_name` - Environment name for the S3 Bucket, defaults to current environment<br> - `dynamodb_environment_name` - Environment name for the Dynamodb Table, defaults to current environment | <pre>object({<br>    s3_bucket_component_name   = optional(string, "gitops/s3-bucket")<br>    dynamodb_component_name    = optional(string, "gitops/dynamodb")<br>    s3_bucket_environment_name = optional(string)<br>    dynamodb_environment_name  = optional(string)<br>  })</pre> | `{}` | no |
| <a name="input_iam_policies"></a> [iam\_policies](#input\_iam\_policies) | List of policies to attach to the IAM role, should be either an ARN of an AWS Managed Policy or a name of a custom policy e.g. `gitops` | `list(string)` | `[]` | no |
| <a name="input_iam_policy"></a> [iam\_policy](#input\_iam\_policy) | IAM policy as list of Terraform objects, compatible with Terraform `aws_iam_policy_document` data source<br>except that `source_policy_documents` and `override_policy_documents` are not included.<br>Use inputs `iam_source_policy_documents` and `iam_override_policy_documents` for that. | <pre>list(object({<br>    policy_id = optional(string, null)<br>    version   = optional(string, null)<br>    statements = list(object({<br>      sid           = optional(string, null)<br>      effect        = optional(string, null)<br>      actions       = optional(list(string), null)<br>      not_actions   = optional(list(string), null)<br>      resources     = optional(list(string), null)<br>      not_resources = optional(list(string), null)<br>      conditions = optional(list(object({<br>        test     = string<br>        variable = string<br>        values   = list(string)<br>      })), [])<br>      principals = optional(list(object({<br>        type        = string<br>        identifiers = list(string)<br>      })), [])<br>      not_principals = optional(list(object({<br>        type        = string<br>        identifiers = list(string)<br>      })), [])<br>    }))<br>  }))</pre> | `[]` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for keep the existing setting, which defaults to `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br>Does not affect keys of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br>set as tag values, and output by this module individually.<br>Does not affect values of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br>Default is to include all labels.<br>Tags with empty values will not be included in the `tags` output.<br>Set to `[]` to suppress all generated tags.<br>**Notes:**<br>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br>  "default"<br>]</pre> | no |
| <a name="input_lambda_cicd_policy_configuration"></a> [lambda\_cicd\_policy\_configuration](#input\_lambda\_cicd\_policy\_configuration) | Configuration for the lambda-cicd policy. The following keys are supported:<br>  - `enable_kms_access` - (bool) - Whether to allow access to KMS. Defaults to false.<br>  - `enable_ssm_access` - (bool) - Whether to allow access to SSM. Defaults to false.<br>  - `enable_s3_access` - (bool) - Whether to allow access to S3. Defaults to false.<br>  - `s3_bucket_component_name` - (string) - The name of the component to use for the S3 bucket. Defaults to `s3-bucket/github-action-artifacts`.<br>  - `s3_bucket_environment_name` - (string) - The name of the environment to use for the S3 bucket. Defaults to the environment of the current module.<br>  - `s3_bucket_tenant_name` - (string) - The name of the tenant to use for the S3 bucket. Defaults to the tenant of the current module.<br>  - `s3_bucket_stage_name` - (string) - The name of the stage to use for the S3 bucket. Defaults to the stage of the current module.<br>  - `enable_lambda_update` - (bool) - Whether to allow access to update lambda functions. Defaults to false. | <pre>object({<br>    enable_kms_access          = optional(bool, false)<br>    enable_ssm_access          = optional(bool, false)<br>    enable_s3_access           = optional(bool, false)<br>    s3_bucket_component_name   = optional(string, "s3-bucket/github-action-artifacts")<br>    s3_bucket_environment_name = optional(string)<br>    s3_bucket_tenant_name      = optional(string)<br>    s3_bucket_stage_name       = optional(string)<br>    enable_lambda_update       = optional(bool, false)<br>  })</pre> | `{}` | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br>This is the only ID element not also included as a `tag`.<br>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br>Characters matching the regex will be removed from the ID elements.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_github_actions_iam_role_arn"></a> [github\_actions\_iam\_role\_arn](#output\_github\_actions\_iam\_role\_arn) | ARN of IAM role for GitHub Actions |
| <a name="output_github_actions_iam_role_name"></a> [github\_actions\_iam\_role\_name](#output\_github\_actions\_iam\_role\_name) | Name of IAM role for GitHub Actions |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## References

- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/github-oidc-role) -
  Cloud Posse's upstream component

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
