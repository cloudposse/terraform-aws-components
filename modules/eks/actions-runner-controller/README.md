# Component: `actions-runner-controller`

This component creates a Helm release for [actions-runner-controller](https://github.com/actions-runner-controller/actions-runner-controller) on an EKS cluster.

## Usage

**Stack Level**: Regional

Once the catalog file is created, the file can be imported as follows.

```yaml
import:
  - catalog/eks/actions-runner-controller
  ...
```

The default catalog values `e.g. stacks/catalog/eks/actions-runner-controller.yaml`

```yaml
components:
  terraform:
    eks/actions-runner-controller:
      settings:
        spacelift:
          workspace_enabled: true
      vars:
        enabled: true
        name: "actions-runner" # avoids hitting name length limit on IAM role
        chart: "actions-runner-controller"
        chart_repository: "https://actions-runner-controller.github.io/actions-runner-controller"
        chart_version: "0.20.2"
        kubernetes_namespace: "actions-runner-system"
        create_namespace: true
        resources:
          limits:
            cpu: 50m
            memory: 100Mi
          requests:
            cpu: 10m
            memory: 30Mi
        ssm_github_token_path: "/github/acme/github_token"
        ssm_github_webhook_secret_token_path: "/github/acme/github_webhook_secret_token"
        runners:
          repository-runner:
            type: "repository" # can be either 'organization' or 'repository'
            dind_enabled: false # A Docker sidecar container will be deployed
            image: summerwind/actions-runner # If dind_enabled=true, set this to 'summerwind/actions-runner-dind'
            scope: "acme/infrastructure"
            scale_down_delay_seconds: 300
            min_replicas: 1
            max_replicas: 5
            busy_metrics:
              scale_up_threshold: 0.75
              scale_down_threshold: 0.25
              scale_up_factor: 2
              scale_down_factor: 0.5
            resources:
              limits:
                cpu: 50m
                memory: 100Mi
              requests:
                cpu: 10m
                memory: 30Mi
            webhook_driven_scaling_enabled: false
            pull_driven_scaling_enabled: false
            labels:
              - "Ubuntu"
              - "core-otto"
```

### Creating Github Tokens

Ensure that the required tokens are created in AWS SSM.
1. The `github_token` saved under `var.ssm_github_token_path`. The value should be a PAT with the scope outlined in [this document](https://github.com/actions-runner-controller/actions-runner-controller#deploying-using-pat-authentication).
2. If using the Webhook Driven autoscaling (recommended), include the key `github_webhook_secret_token` saved under `var.ssm_github_webhook_secret_token_path`. Set to a random string you will use as the Secret when creating the webhook in GitHub.
Generate the string using 1Password (no special characters, length 45) or by running
```bash
dd if=/dev/random bs=1 count=33  2>/dev/null | base64
```


### Updating CRDs

When updating the chart or application version of `actions-runner-controller`, it is possible you will need to install
new CRDs. Such a requirement should be indicated in the `actions-runner-controller` release notes and may require some adjustment to our
custom chart or configuration. 

This component uses `helm` to manage the deployment, and `helm` will not auto-update CRDs. 
If new CRDs are needed, install them manually via a command like

```
kubectl create -f https://raw.githubusercontent.com/actions-runner-controller/actions-runner-controller/master/charts/actions-runner-controller/crds/actions.summerwind.dev_horizontalrunnerautoscalers.yaml
```

Consult [actions-runner-controller](https://github.com/actions-runner-controller/actions-runner-controller) documentation for further details.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 4.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_account_map"></a> [account\_map](#module\_account\_map) | cloudposse/stack-config/yaml//modules/remote-state | 0.22.4 |
| <a name="module_actions_runner"></a> [actions\_runner](#module\_actions\_runner) | cloudposse/helm-release/aws | 0.6.0 |
| <a name="module_actions_runner_controller"></a> [actions\_runner\_controller](#module\_actions\_runner\_controller) | cloudposse/helm-release/aws | 0.6.0 |
| <a name="module_eks"></a> [eks](#module\_eks) | cloudposse/stack-config/yaml//modules/remote-state | 0.22.4 |
| <a name="module_iam_roles"></a> [iam\_roles](#module\_iam\_roles) | ../../account-map/modules/iam-roles | n/a |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |

## Resources

| Name | Type |
|------|------|
| [aws_eks_cluster_auth.eks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_ssm_parameter.github_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.github_webhook_secret_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_map_environment_name"></a> [account\_map\_environment\_name](#input\_account\_map\_environment\_name) | The name of the environment where `account_map` is provisioned | `string` | `"gbl"` | no |
| <a name="input_account_map_stage_name"></a> [account\_map\_stage\_name](#input\_account\_map\_stage\_name) | The name of the stage where `account_map` is provisioned | `string` | `"root"` | no |
| <a name="input_account_map_tenant_name"></a> [account\_map\_tenant\_name](#input\_account\_map\_tenant\_name) | The name of the tenant where `account_map` is provisioned.<br><br>If the `tenant` label is not used, leave this as `null`. | `string` | `"core"` | no |
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br>This is for some rare cases where resources want additional configuration of tags<br>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_atomic"></a> [atomic](#input\_atomic) | If set, installation process purges chart on fail. The wait flag will be set automatically if atomic is used. | `bool` | `true` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br>in the order they appear in the list. New attributes are appended to the<br>end of the list. The elements of the list are joined by the `delimiter`<br>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_chart"></a> [chart](#input\_chart) | Chart name to be installed. The chart name can be local path, a URL to a chart, or the name of the chart if `repository` is specified. It is also possible to use the `<repository>/<chart>` format here if you are running Terraform on a system that the repository has been added to with `helm repo add` but this is not recommended. | `string` | n/a | yes |
| <a name="input_chart_description"></a> [chart\_description](#input\_chart\_description) | Set release description attribute (visible in the history). | `string` | `null` | no |
| <a name="input_chart_repository"></a> [chart\_repository](#input\_chart\_repository) | Repository URL where to locate the requested chart. | `string` | n/a | yes |
| <a name="input_chart_values"></a> [chart\_values](#input\_chart\_values) | Additional values to yamlencode as `helm_release` values. | `any` | `{}` | no |
| <a name="input_chart_version"></a> [chart\_version](#input\_chart\_version) | Specify the exact chart version to install. If this is not specified, the latest version is installed. | `string` | `null` | no |
| <a name="input_cleanup_on_fail"></a> [cleanup\_on\_fail](#input\_cleanup\_on\_fail) | Allow deletion of new resources created in this upgrade when upgrade fails. | `bool` | `true` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "descriptor_formats": {},<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "labels_as_tags": [<br>    "unset"<br>  ],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {},<br>  "tenant": null<br>}</pre> | no |
| <a name="input_create_namespace"></a> [create\_namespace](#input\_create\_namespace) | Create the namespace if it does not yet exist. Defaults to `false`. | `bool` | `null` | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br>Map of maps. Keys are names of descriptors. Values are maps of the form<br>`{<br>   format = string<br>   labels = list(string)<br>}`<br>(Type is `any` so the map values can later be enhanced to provide additional options.)<br>`format` is a Terraform format string to be passed to the `format()` function.<br>`labels` is a list of labels, in order, to pass to `format()` function.<br>Label values will be normalized before being passed to `format()` so they will be<br>identical to how they appear in `id`.<br>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_eks_component_name"></a> [eks\_component\_name](#input\_eks\_component\_name) | The name of the eks component | `string` | `"eks/eks"` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_helm_manifest_experiment_enabled"></a> [helm\_manifest\_experiment\_enabled](#input\_helm\_manifest\_experiment\_enabled) | Enable storing of the rendered manifest for helm\_release so the full diff of what is changing can been seen in the plan | `bool` | `true` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for keep the existing setting, which defaults to `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_import_profile_name"></a> [import\_profile\_name](#input\_import\_profile\_name) | AWS Profile name to use when importing a resource | `string` | `null` | no |
| <a name="input_import_role_arn"></a> [import\_role\_arn](#input\_import\_role\_arn) | IAM Role ARN to use when importing a resource | `string` | `null` | no |
| <a name="input_kube_data_auth_enabled"></a> [kube\_data\_auth\_enabled](#input\_kube\_data\_auth\_enabled) | If `true`, use an `aws_eks_cluster_auth` data source to authenticate to the EKS cluster.<br>Disabled by `kubeconfig_file_enabled` or `kube_exec_auth_enabled`. | `bool` | `false` | no |
| <a name="input_kube_exec_auth_aws_profile"></a> [kube\_exec\_auth\_aws\_profile](#input\_kube\_exec\_auth\_aws\_profile) | The AWS config profile for `aws eks get-token` to use | `string` | `""` | no |
| <a name="input_kube_exec_auth_aws_profile_enabled"></a> [kube\_exec\_auth\_aws\_profile\_enabled](#input\_kube\_exec\_auth\_aws\_profile\_enabled) | If `true`, pass `kube_exec_auth_aws_profile` as the `profile` to `aws eks get-token` | `bool` | `false` | no |
| <a name="input_kube_exec_auth_enabled"></a> [kube\_exec\_auth\_enabled](#input\_kube\_exec\_auth\_enabled) | If `true`, use the Kubernetes provider `exec` feature to execute `aws eks get-token` to authenticate to the EKS cluster.<br>Disabled by `kubeconfig_file_enabled`, overrides `kube_data_auth_enabled`. | `bool` | `true` | no |
| <a name="input_kube_exec_auth_role_arn"></a> [kube\_exec\_auth\_role\_arn](#input\_kube\_exec\_auth\_role\_arn) | The role ARN for `aws eks get-token` to use | `string` | `""` | no |
| <a name="input_kube_exec_auth_role_arn_enabled"></a> [kube\_exec\_auth\_role\_arn\_enabled](#input\_kube\_exec\_auth\_role\_arn\_enabled) | If `true`, pass `kube_exec_auth_role_arn` as the role ARN to `aws eks get-token` | `bool` | `true` | no |
| <a name="input_kubeconfig_context"></a> [kubeconfig\_context](#input\_kubeconfig\_context) | Context to choose from the Kubernetes kube config file | `string` | `""` | no |
| <a name="input_kubeconfig_exec_auth_api_version"></a> [kubeconfig\_exec\_auth\_api\_version](#input\_kubeconfig\_exec\_auth\_api\_version) | The Kubernetes API version of the credentials returned by the `exec` auth plugin | `string` | `"client.authentication.k8s.io/v1beta1"` | no |
| <a name="input_kubeconfig_file"></a> [kubeconfig\_file](#input\_kubeconfig\_file) | The Kubernetes provider `config_path` setting to use when `kubeconfig_file_enabled` is `true` | `string` | `""` | no |
| <a name="input_kubeconfig_file_enabled"></a> [kubeconfig\_file\_enabled](#input\_kubeconfig\_file\_enabled) | If `true`, configure the Kubernetes provider with `kubeconfig_file` and use that kubeconfig file for authenticating to the EKS cluster | `bool` | `false` | no |
| <a name="input_kubernetes_namespace"></a> [kubernetes\_namespace](#input\_kubernetes\_namespace) | The namespace to install the release into. | `string` | n/a | yes |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br>Does not affect keys of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br>set as tag values, and output by this module individually.<br>Does not affect values of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br>Default is to include all labels.<br>Tags with empty values will not be included in the `tags` output.<br>Set to `[]` to suppress all generated tags.<br>**Notes:**<br>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br>  "default"<br>]</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br>This is the only ID element not also included as a `tag`.<br>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_rbac_enabled"></a> [rbac\_enabled](#input\_rbac\_enabled) | Service Account for pods. | `bool` | `true` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br>Characters matching the regex will be removed from the ID elements.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region. | `string` | n/a | yes |
| <a name="input_resources"></a> [resources](#input\_resources) | The cpu and memory of the deployment's limits and requests. | <pre>object({<br>    limits = object({<br>      cpu    = string<br>      memory = string<br>    })<br>    requests = object({<br>      cpu    = string<br>      memory = string<br>    })<br>  })</pre> | n/a | yes |
| <a name="input_runners"></a> [runners](#input\_runners) | Map of Action Runner configurations, with the key being the name of the runner. Please note that the name must be in<br>kebab-case.<br><br>For example:<pre>hcl<br>organization_runner = {<br>  type = "organization" # can be either 'organization' or 'repository'<br>  dind_enabled: false # A Docker sidecar container will be deployed<br>  image: summerwind/actions-runner # If dind_enabled=true, set this to 'summerwind/actions-runner-dind'<br>  scope = "ACME"  # org name for Organization runners, repo name for Repository runners<br>  scale_down_delay_seconds = 300<br>  min_replicas = 1<br>  max_replicas = 5<br>  busy_metrics = {<br>    scale_up_threshold = 0.75<br>    scale_down_threshold = 0.25<br>    scale_up_factor = 2<br>    scale_down_factor = 0.5<br>  }<br>  labels = [<br>    "Ubuntu",<br>    "mgmt-automation",<br>  ]<br>}</pre> | <pre>map(object({<br>    type                           = string<br>    scope                          = string<br>    image                          = string<br>    dind_enabled                   = bool<br>    scale_down_delay_seconds       = number<br>    min_replicas                   = number<br>    max_replicas                   = number<br>    busy_metrics                   = map(string)<br>    webhook_driven_scaling_enabled = bool<br>    pull_driven_scaling_enabled    = bool<br>    labels                         = list(string)<br>    resources = object({<br>      limits = object({<br>        cpu    = string<br>        memory = string<br>      })<br>      requests = object({<br>        cpu    = string<br>        memory = string<br>      })<br>    })<br>  }))</pre> | n/a | yes |
| <a name="input_s3_bucket_arns"></a> [s3\_bucket\_arns](#input\_s3\_bucket\_arns) | List of ARNs of S3 Buckets to which the runners will have read-write access to. | `list(string)` | `[]` | no |
| <a name="input_ssm_github_token_path"></a> [ssm\_github\_token\_path](#input\_ssm\_github\_token\_path) | The path in SSM to the GitHub token. | `string` | `""` | no |
| <a name="input_ssm_github_webhook_secret_token_path"></a> [ssm\_github\_webhook\_secret\_token\_path](#input\_ssm\_github\_webhook\_secret\_token\_path) | The path in SSM to the GitHub Webhook Secret token. | `string` | `""` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |
| <a name="input_timeout"></a> [timeout](#input\_timeout) | Time in seconds to wait for any individual kubernetes operation (like Jobs for hooks). Defaults to `300` seconds | `number` | `null` | no |
| <a name="input_wait"></a> [wait](#input\_wait) | Will wait until all resources are in a ready state before marking the release as successful. It will wait for as long as `timeout`. Defaults to `true`. | `bool` | `null` | no |
| <a name="input_webhook"></a> [webhook](#input\_webhook) | Configuration for the GitHub Webhook Server.<br>`hostname_template` is the `format()` string to use to generate the hostname via `format(var.hostname_template, var.tenant, var.stage, var.environment)`"<br>Typically something like `"echo.%[3]v.%[2]v.example.com"`. | <pre>object({<br>    enabled           = bool<br>    hostname_template = string<br>  })</pre> | <pre>{<br>  "enabled": false,<br>  "hostname_template": null<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_metadata"></a> [metadata](#output\_metadata) | Block status of the deployed release |
| <a name="output_metadata_action_runner_releases"></a> [metadata\_action\_runner\_releases](#output\_metadata\_action\_runner\_releases) | Block statuses of the deployed actions-runner chart releases |
| <a name="output_webhook_payload_url"></a> [webhook\_payload\_url](#output\_webhook\_payload\_url) | Payload URL for GitHub webhook |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## References

- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/master/modules/eks/actions-runner-controller) - Cloud Posse's upstream component
- [alb-controller](https://artifacthub.io/packages/helm/aws/aws-load-balancer-controller) - Helm Chart
- [alb-controller](https://github.com/kubernetes-sigs/aws-load-balancer-controller) - AWS Load Balancer Controller

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
