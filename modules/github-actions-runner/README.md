# Component: `github-action-runners`

This component deploys a controller to operate self-hosted runners for GitHub Actions on your Kubernetes cluster.

## Usage

**Stack Level**: Regional

```yaml
components:
  terraform:
    github-actions-runner:
      vars:
        enabled: true
        runner_configurations:
          - repo: infrastructure
            runner_type: small # Optional field (defaults to small)
            autoscale_type: low_concurrency # Optional field (defaults to low_concurrency)
          - repo: another-repo
          - repo: yet-another-repo
```

### Runner Types:
**small**
```yaml
resources:
  limits:
    cpu: "3"
    memory: "12Gi"
  requests:
    cpu: "1"
    memory: "1Gi"
```

**medium**
```yaml
resources:
  limits:
    cpu: "6"
    memory: "12Gi"
  requests:
    cpu: "2"
    memory: "1Gi"
```

**large**
```yaml
resources:
  limits:
    cpu: "8"
    memory: "12Gi"
  requests:
    cpu: "4"
    memory: "1Gi"
```

### Autoscale Types:
**low_concurrency**
```yaml
minReplicas: 1
maxReplicas: 8
metrics:
  type: PercentageRunnersBusy
  scaleUpThreshold: '0.75'
  scaleDownThreshold: '0.3'
  scaleUpAdjustment: 1
  scaleDownAdjustment: 1
```

**medium_concurrency**
```yaml
minReplicas: 1
maxReplicas: 16
metrics:
  type: PercentageRunnersBusy
  scaleUpThreshold: '0.75'
  scaleDownThreshold: '0.3'
  scaleUpAdjustment: 4
  scaleDownAdjustment: 2
```

**high_concurrency**
```yaml
minReplicas: 1
maxReplicas: 32
metrics:
  type: PercentageRunnersBusy
  scaleUpThreshold: '0.75'
  scaleDownThreshold: '0.3'
  scaleUpAdjustment: 8
  scaleDownAdjustment: 4
```

## Managing the Runner Docker Image

```
cd components/terraform/github-actions-runner/runners/runner
```

Run `make help` to get a quick list of the commands.

Run `make TAG=0.0.6 help` to get the same commands with a specific tag for ease of copy/paste.

### ECR Authentication

There are multiple ways to authenticate with ECR. The commands provided by AWS with the `docker login` approach is available with the target:

```bash
make auth
```

_NOTE_: You cannot run the build or push from inside Geodesic, you need to run those on your host to avoid docker-in-docker issues so ensure you authentication is handled outside of Geodesic as well.

### Manually Building and Tagging the Image

We create our own runner image with amazon-ecr-credential-helper installed. For actions-runner-controller 0.16.0 we used runners_image: `"summerwind/actions-runner-dind:v2.275.1"` -> `action-runner:v0.1.0`.

For `actions-runner-controller` 0.18.0 we tried `runners_image: "summerwind/actions-runner-dind:v2.277.1"` -> `action-runner:0.2.0` but that did not work (see https://github.com/summerwind/actions-runner-controller/issues/274) so we reverted to `runners_image: "summerwind/actions-runner-dind:v2.274.2"` -> `action-runner:0.2.1` based on the [issue comment](https://github.com/summerwind/actions-runner-controller/blob/bc6e499e4f72f60024781d99ec66a665bedb5e1f/runner/Dockerfile#L4) and the runner version configured in the controller release.

Edit Dockerfile to set base runner version and `ecr-credential-helper-version`. Create the image before deploying the Helmfile.

```bash
make TAG=xxx build
```

_Hint_: find the existing tags with `make list-tags`.

### Manually Pushing a Tagged Image

Push the image with `make TAG=xxx push`.

## Managing the `GITHUB_TOKEN`

According to the above docs, do not use the Github App if Github Enterprise is used or planned to be used. The best way is to use a Github PAT.

See the [official documentation](https://github.com/actions-runner-controller/actions-runner-controller#deploying-using-pat-authentication) on how to generate and configure the `GITHUB_TOKEN` (Personal Access Token).

Install `GITHUB_TOKEN` with:

```bash
kubectl create secret generic controller-manager -n actions-runner-system \
  --from-literal=github_token=${GITHUB_TOKEN}
```

_NOTE_: configure the desired cluster in Geodesic using `set-cluster account` (where `account` is the AWS account name; ex: `set-cluster auto`).

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.0 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | >= 2.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eks"></a> [eks](#module\_eks) | cloudposse/stack-config/yaml//modules/remote-state | 0.19.0 |
| <a name="module_eks_iam_policy"></a> [eks\_iam\_policy](#module\_eks\_iam\_policy) | cloudposse/iam-policy/aws | 0.2.2 |
| <a name="module_eks_iam_role"></a> [eks\_iam\_role](#module\_eks\_iam\_role) | cloudposse/eks-iam-role/aws | 0.10.3 |
| <a name="module_github_action_controller_label"></a> [github\_action\_controller\_label](#module\_github\_action\_controller\_label) | cloudposse/label/null | 0.25.0 |
| <a name="module_github_action_helm_label"></a> [github\_action\_helm\_label](#module\_github\_action\_helm\_label) | cloudposse/label/null | 0.25.0 |
| <a name="module_iam_primary_roles"></a> [iam\_primary\_roles](#module\_iam\_primary\_roles) | cloudposse/stack-config/yaml//modules/remote-state | 0.19.0 |
| <a name="module_iam_roles"></a> [iam\_roles](#module\_iam\_roles) | ../account-map/modules/iam-roles | n/a |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.github_action_runner_kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role_policy_attachment.github_action_runner_kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_kms_alias.github_action_runner](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.github_action_runner](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [helm_release.actions_runner](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.actions_runner_controller](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_eks_cluster.kubernetes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_eks_cluster_auth.kubernetes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |
| [aws_iam_policy_document.github_action_runner](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.github_action_runner_kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br>This is for some rare cases where resources want additional configuration of tags<br>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br>in the order they appear in the list. New attributes are appended to the<br>end of the list. The elements of the list are joined by the `delimiter`<br>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_autoscale_type"></a> [autoscale\_type](#input\_autoscale\_type) | Default choice if not defined in autoscale\_types | `string` | `"low_concurrency"` | no |
| <a name="input_autoscale_types"></a> [autoscale\_types](#input\_autoscale\_types) | Map to define HRA CRD scaling configurations | <pre>map(object({<br>    minReplicas = number,<br>    maxReplicas = number<br>    metrics = object({<br>      type                = string,<br>      scaleUpThreshold    = number,<br>      scaleDownThreshold  = number,<br>      scaleUpAdjustment   = number,<br>      scaleDownAdjustment = number<br>    })<br>  }))</pre> | <pre>{<br>  "low_concurrency": {<br>    "maxReplicas": 8,<br>    "metrics": {<br>      "scaleDownAdjustment": 1,<br>      "scaleDownThreshold": 0.3,<br>      "scaleUpAdjustment": 1,<br>      "scaleUpThreshold": 0.75,<br>      "type": "PercentageRunnersBusy"<br>    },<br>    "minReplicas": 1<br>  }<br>}</pre> | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "descriptor_formats": {},<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "labels_as_tags": [<br>    "unset"<br>  ],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {},<br>  "tenant": null<br>}</pre> | no |
| <a name="input_controller_chart_image"></a> [controller\_chart\_image](#input\_controller\_chart\_image) | Image to use for controller | `string` | `"summerwind/actions-runner-controller"` | no |
| <a name="input_controller_chart_image_tag"></a> [controller\_chart\_image\_tag](#input\_controller\_chart\_image\_tag) | Tag to use for controller image | `string` | `"v0.19.0"` | no |
| <a name="input_controller_chart_name"></a> [controller\_chart\_name](#input\_controller\_chart\_name) | Controller Helm chart name. | `string` | `"actions-runner-controller"` | no |
| <a name="input_controller_chart_namespace"></a> [controller\_chart\_namespace](#input\_controller\_chart\_namespace) | Controller kubernetes namespace. | `string` | `"actions-runner-system"` | no |
| <a name="input_controller_chart_namespace_create"></a> [controller\_chart\_namespace\_create](#input\_controller\_chart\_namespace\_create) | Controller kubernetes namespace created if not present | `bool` | `true` | no |
| <a name="input_controller_chart_release_name"></a> [controller\_chart\_release\_name](#input\_controller\_chart\_release\_name) | Controller Helm chart release name. | `string` | `"actions-runner-controller"` | no |
| <a name="input_controller_chart_repo"></a> [controller\_chart\_repo](#input\_controller\_chart\_repo) | Controller Helm chart repository name. | `string` | `"https://actions-runner-controller.github.io/actions-runner-controller"` | no |
| <a name="input_controller_chart_values"></a> [controller\_chart\_values](#input\_controller\_chart\_values) | Additional values to yamlencode as `helm_release` values. | `any` | `{}` | no |
| <a name="input_controller_chart_version"></a> [controller\_chart\_version](#input\_controller\_chart\_version) | Controller Helm chart version. | `string` | `"0.12.8"` | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br>Map of maps. Keys are names of descriptors. Values are maps of the form<br>`{<br>   format = string<br>   labels = list(string)<br>}`<br>(Type is `any` so the map values can later be enhanced to provide additional options.)<br>`format` is a Terraform format string to be passed to the `format()` function.<br>`labels` is a list of labels, in order, to pass to `format()` function.<br>Label values will be normalized before being passed to `format()` so they will be<br>identical to how they appear in `id`.<br>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_iam_policy_statements"></a> [iam\_policy\_statements](#input\_iam\_policy\_statements) | IAM policy for the service account. Required if `var.iam_role_enabled` is `true`. This will not do variable replacements. Please see `var.iam_policy_statements_template_path`. | `any` | `{}` | no |
| <a name="input_iam_primary_roles_environment_name"></a> [iam\_primary\_roles\_environment\_name](#input\_iam\_primary\_roles\_environment\_name) | The name of the environment where global `iam_primary_roles` is provisioned | `string` | `"gbl"` | no |
| <a name="input_iam_primary_roles_stage_name"></a> [iam\_primary\_roles\_stage\_name](#input\_iam\_primary\_roles\_stage\_name) | The name of the stage where `iam_primary_roles` is provisioned | `string` | `"identity"` | no |
| <a name="input_iam_role_enabled"></a> [iam\_role\_enabled](#input\_iam\_role\_enabled) | Whether to create an IAM role. Setting this to `true` will also replace any occurrences of `{service_account_role_arn}` in `var.values_template_path` with the ARN of the IAM role created by this module. | `bool` | `false` | no |
| <a name="input_iam_source_json_url"></a> [iam\_source\_json\_url](#input\_iam\_source\_json\_url) | IAM source json policy to download. This will be used as the `source_json` meaning the `var.iam_policy_statements` and `var.iam_policy_statements_template_path` can override it. | `string` | `null` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for keep the existing setting, which defaults to `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_import_profile_name"></a> [import\_profile\_name](#input\_import\_profile\_name) | AWS Profile name to use when importing a resource | `string` | `null` | no |
| <a name="input_import_role_arn"></a> [import\_role\_arn](#input\_import\_role\_arn) | IAM Role ARN to use when importing a resource | `string` | `null` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br>Does not affect keys of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br>set as tag values, and output by this module individually.<br>Does not affect values of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br>Default is to include all labels.<br>Tags with empty values will not be included in the `tags` output.<br>Set to `[]` to suppress all generated tags.<br>**Notes:**<br>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br>  "default"<br>]</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br>This is the only ID element not also included as a `tag`.<br>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br>Characters matching the regex will be removed from the ID elements.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_runner_chart_image"></a> [runner\_chart\_image](#input\_runner\_chart\_image) | Controller Helm chart name. | `string` | `"actions-runner"` | no |
| <a name="input_runner_chart_values"></a> [runner\_chart\_values](#input\_runner\_chart\_values) | Additional values to yamlencode as `helm_release` values. | `any` | `{}` | no |
| <a name="input_runner_configurations"></a> [runner\_configurations](#input\_runner\_configurations) | List of maps to create runners from | `list(map(string))` | n/a | yes |
| <a name="input_runner_type"></a> [runner\_type](#input\_runner\_type) | Default choice if not defined in runner\_configurations | `string` | `"small"` | no |
| <a name="input_runner_types"></a> [runner\_types](#input\_runner\_types) | Map to define resources limits and requests | <pre>map(object({<br>    resources = object({<br>      limits = object({<br>        cpu    = string,<br>        memory = string<br>      }),<br>      requests = object({<br>        cpu    = string,<br>        memory = string<br>      })<br>    })<br>  }))</pre> | <pre>{<br>  "small": {<br>    "resources": {<br>      "limits": {<br>        "cpu": "3",<br>        "memory": "12Gi"<br>      },<br>      "requests": {<br>        "cpu": "1",<br>        "memory": "1Gi"<br>      }<br>    }<br>  }<br>}</pre> | no |
| <a name="input_service_account_name"></a> [service\_account\_name](#input\_service\_account\_name) | Kubernetes ServiceAccount name. Required if `var.iam_role_enabled` is `true`. | `string` | `null` | no |
| <a name="input_service_account_namespace"></a> [service\_account\_namespace](#input\_service\_account\_namespace) | Kubernetes Namespace where service account is deployed. Required if `var.iam_role_enabled` is `true`. | `string` | `null` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_kms_alias"></a> [kms\_alias](#output\_kms\_alias) | KMS alias |
| <a name="output_kms_key_arn"></a> [kms\_key\_arn](#output\_kms\_key\_arn) | KMS key ARN |
| <a name="output_release_name"></a> [release\_name](#output\_release\_name) | Name of the release |
| <a name="output_release_namespace"></a> [release\_namespace](#output\_release\_namespace) | Namespace of the release |
| <a name="output_service_account_role_arn"></a> [service\_account\_role\_arn](#output\_service\_account\_role\_arn) | Service Account role ARN |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## References

- [actions-runner-controller](https://github.com/actions-runner-controller/actions-runner-controller) - Github Repo
- [summerwind/actions-runner-controller source](https://github.com/summerwind/actions-runner-controller/blob/master/charts/actions-runner-controller/values.yaml) - Helm Chart

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
