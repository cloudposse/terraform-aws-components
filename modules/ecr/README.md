---
tags:
  - component/ecr
  - layer/baseline
  - provider/aws
---

# Component: `ecr`

This component is responsible for provisioning repositories, lifecycle rules, and permissions for streamlined ECR usage.
This utilizes
[the roles-to-principals submodule](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/account-map/modules/roles-to-principals)
to assign accounts to various roles. It is also compatible with the
[GitHub Actions IAM Role mixin](https://github.com/cloudposse/terraform-aws-components/blob/master/mixins/github-actions-iam-role/README-github-action-iam-role.md).

> [!WARNING]
>
> Older versions of our reference architecture have an`eks-iam` component that needs to be updated to provide sufficient
> IAM roles to allow pods to pull from ECR repos

## Usage

**Stack Level**: Regional

Here's an example snippet for how to use this component. This component is normally only applied once as the resources
it creates are globally accessible, but you may want to create ECRs in multiple regions for redundancy. This is
typically provisioned via the stack for the "artifact" account (typically `auto`, `artifact`, or `corp`) in the primary
region.

```yaml
components:
  terraform:
    ecr:
      vars:
        ecr_user_enabled: false
        enable_lifecycle_policy: true
        max_image_count: 500
        scan_images_on_push: true
        protected_tags:
          - prod
        image_tag_mutability: MUTABLE

        images:
          - infrastructure
          - microservice-a
          - microservice-b
          - microservice-c
        read_write_account_role_map:
          identity:
            - admin
            - cicd
          automation:
            - admin
        read_only_account_role_map:
          corp: ["*"]
          dev: ["*"]
          prod: ["*"]
          stage: ["*"]
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
| <a name="module_ecr"></a> [ecr](#module\_ecr) | cloudposse/ecr/aws | 0.36.0 |
| <a name="module_full_access"></a> [full\_access](#module\_full\_access) | ../account-map/modules/roles-to-principals | n/a |
| <a name="module_iam_roles"></a> [iam\_roles](#module\_iam\_roles) | ../account-map/modules/iam-roles | n/a |
| <a name="module_readonly_access"></a> [readonly\_access](#module\_readonly\_access) | ../account-map/modules/roles-to-principals | n/a |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.ecr_user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_user.ecr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user) | resource |
| [aws_iam_user_policy_attachment.ecr_user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy_attachment) | resource |
| [aws_iam_policy_document.ecr_user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br>This is for some rare cases where resources want additional configuration of tags<br>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br>in the order they appear in the list. New attributes are appended to the<br>end of the list. The elements of the list are joined by the `delimiter`<br>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "descriptor_formats": {},<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "labels_as_tags": [<br>    "unset"<br>  ],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {},<br>  "tenant": null<br>}</pre> | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br>Map of maps. Keys are names of descriptors. Values are maps of the form<br>`{<br>   format = string<br>   labels = list(string)<br>}`<br>(Type is `any` so the map values can later be enhanced to provide additional options.)<br>`format` is a Terraform format string to be passed to the `format()` function.<br>`labels` is a list of labels, in order, to pass to `format()` function.<br>Label values will be normalized before being passed to `format()` so they will be<br>identical to how they appear in `id`.<br>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_ecr_user_enabled"></a> [ecr\_user\_enabled](#input\_ecr\_user\_enabled) | Enable/disable the provisioning of the ECR user (for CI/CD systems that don't support assuming IAM roles to access ECR, e.g. Codefresh) | `bool` | `false` | no |
| <a name="input_enable_lifecycle_policy"></a> [enable\_lifecycle\_policy](#input\_enable\_lifecycle\_policy) | Enable/disable image lifecycle policy | `bool` | n/a | yes |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for keep the existing setting, which defaults to `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_image_tag_mutability"></a> [image\_tag\_mutability](#input\_image\_tag\_mutability) | The tag mutability setting for the repository. Must be one of: `MUTABLE` or `IMMUTABLE` | `string` | `"MUTABLE"` | no |
| <a name="input_images"></a> [images](#input\_images) | List of image names (ECR repo names) to create repos for | `list(string)` | n/a | yes |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br>Does not affect keys of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br>set as tag values, and output by this module individually.<br>Does not affect values of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br>Default is to include all labels.<br>Tags with empty values will not be included in the `tags` output.<br>Set to `[]` to suppress all generated tags.<br>**Notes:**<br>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br>  "default"<br>]</pre> | no |
| <a name="input_max_image_count"></a> [max\_image\_count](#input\_max\_image\_count) | Max number of images to store. Old ones will be deleted to make room for new ones. | `number` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br>This is the only ID element not also included as a `tag`.<br>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_principals_lambda"></a> [principals\_lambda](#input\_principals\_lambda) | Principal account IDs of Lambdas allowed to consume ECR | `list(string)` | `[]` | no |
| <a name="input_protected_tags"></a> [protected\_tags](#input\_protected\_tags) | Tags to refrain from deleting | `list(string)` | `[]` | no |
| <a name="input_read_only_account_role_map"></a> [read\_only\_account\_role\_map](#input\_read\_only\_account\_role\_map) | Map of `account:[role, role...]` for read-only access. Use `*` for role to grant access to entire account | `map(list(string))` | `{}` | no |
| <a name="input_read_write_account_role_map"></a> [read\_write\_account\_role\_map](#input\_read\_write\_account\_role\_map) | Map of `account:[role, role...]` for write access. Use `*` for role to grant access to entire account | `map(list(string))` | n/a | yes |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br>Characters matching the regex will be removed from the ID elements.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_scan_images_on_push"></a> [scan\_images\_on\_push](#input\_scan\_images\_on\_push) | Indicates whether images are scanned after being pushed to the repository | `bool` | `false` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ecr_repo_arn_map"></a> [ecr\_repo\_arn\_map](#output\_ecr\_repo\_arn\_map) | Map of image names to ARNs |
| <a name="output_ecr_repo_url_map"></a> [ecr\_repo\_url\_map](#output\_ecr\_repo\_url\_map) | Map of image names to URLs |
| <a name="output_ecr_user_arn"></a> [ecr\_user\_arn](#output\_ecr\_user\_arn) | ECR user ARN |
| <a name="output_ecr_user_name"></a> [ecr\_user\_name](#output\_ecr\_user\_name) | ECR user name |
| <a name="output_ecr_user_unique_id"></a> [ecr\_user\_unique\_id](#output\_ecr\_user\_unique\_id) | ECR user unique ID assigned by AWS |
| <a name="output_repository_host"></a> [repository\_host](#output\_repository\_host) | ECR repository name |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## Related

- [Decide How to distribute Docker Images](https://docs.cloudposse.com/layers/software-delivery/design-decisions/decide-how-to-distribute-docker-images/)

- [Decide on ECR Strategy](https://docs.cloudposse.com/layers/project/design-decisions/decide-on-ecr-strategy/)

## References

- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/ecr) -
  Cloud Posse's upstream component

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
