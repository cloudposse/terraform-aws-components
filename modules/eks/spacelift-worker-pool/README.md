---
tags:
  - component/eks/spacelift-worker-pool
  - layer/spacelift
  - provider/aws
  - provider/helm
  - provider/spacelift
---

# Component: `eks/spacelift-worker-pool`

This component provisions the `WorkerPool` part of the
[Kubernetes Operator](https://docs.spacelift.io/concepts/worker-pools/kubernetes-workers#kubernetes-workers) for
[Spacelift Worker Pools](https://docs.spacelift.io/concepts/worker-pools#kubernetes) into an EKS cluster. You can
provision this component multiple times to create multiple worker pools in a single EKS cluster.

## Usage

> [!NOTE]
>
> Before provisioning the `eks/spacelift-worker-pool` component, the `eks/spacelift-worker-pool-controller` component
> must be provisioned first into an EKS cluster to enable the
> [Spacelift Worker Pool Kubernetes Controller](https://docs.spacelift.io/concepts/worker-pools#kubernetes). The
> `eks/spacelift-worker-pool-controller` component must be provisioned only once per EKS cluster.

The Spacelift worker needs to pull a Docker image from an ECR repository. It will run the Terraform commands inside the
Docker container. In the Cloud Posse reference architecture, this image is the "infra" or "infrastructure" image derived
from [Geodesic](https://github.com/cloudposse/geodesic). The worker service account needs permission to pull the image
from the ECR repository, and the details of where to find the image are configured in the various `ecr_*` variables.

**Stack Level**: Regional

```yaml
# stacks/catalog/eks/spacelift-worker-pool/defaults.yaml
components:
  terraform:
    eks/spacelift-worker-pool:
      enabled: true
      name: "spacelift-worker-pool"
      space_name: root
      # aws_config_file is the path in the Docker container to the AWS_CONFIG_FILE.
      # "/etc/aws-config/aws-config-spacelift" is the usual path in the "infrastructure" image.
      aws_config_file: "/etc/aws-config/aws-config-spacelift"
      spacelift_api_endpoint: "https://1898andco.app.spacelift.io"
      eks_component_name: "eks/cluster"
      worker_pool_size: 40
      kubernetes_namespace: "spacelift-worker-pool"
      kubernetes_service_account_enabled: true
      kubernetes_service_account_name: "spacelift-worker-pool"
      keep_successful_pods: false
      kubernetes_role_api_groups: [""]
      kubernetes_role_resources: ["*"]
      kubernetes_role_resource_names: null
      kubernetes_role_verbs: ["get", "list"]
      ecr_component_name: ecr
      ecr_environment_name: use1
      ecr_stage_name: artifacts
      ecr_tenant_name: core
      ecr_repo_name: infra
```

## References

- https://docs.spacelift.io/concepts/worker-pools#kubernetes
- https://docs.spacelift.io/integrations/docker#customizing-the-runner-image
- https://registry.terraform.io/providers/spacelift-io/spacelift/latest/docs/resources/worker_pool
- https://docs.spacelift.io/concepts/worker-pools#installation
- https://github.com/spacelift-io/spacelift-helm-charts/tree/main/spacelift-workerpool-controller
- https://github.com/spacelift-io/spacelift-helm-charts/blob/main/spacelift-workerpool-controller/values.yaml
- https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication-and-configuration
- https://github.com/aws/aws-cli/issues/3875
- https://github.com/boto/botocore/issues/2245

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.9.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.18.1, != 2.21.0 |
| <a name="requirement_spacelift"></a> [spacelift](#requirement\_spacelift) | >= 0.1.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.9.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.18.1, != 2.21.0 |
| <a name="provider_spacelift"></a> [spacelift](#provider\_spacelift) | >= 0.1.2 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_account_map"></a> [account\_map](#module\_account\_map) | cloudposse/stack-config/yaml//modules/remote-state | 1.8.0 |
| <a name="module_ecr"></a> [ecr](#module\_ecr) | cloudposse/stack-config/yaml//modules/remote-state | 1.8.0 |
| <a name="module_eks"></a> [eks](#module\_eks) | cloudposse/stack-config/yaml//modules/remote-state | 1.8.0 |
| <a name="module_eks_iam_policy"></a> [eks\_iam\_policy](#module\_eks\_iam\_policy) | cloudposse/iam-policy/aws | 2.0.1 |
| <a name="module_eks_iam_role"></a> [eks\_iam\_role](#module\_eks\_iam\_role) | cloudposse/eks-iam-role/aws | 2.1.1 |
| <a name="module_iam_roles"></a> [iam\_roles](#module\_iam\_roles) | ../../account-map/modules/iam-roles | n/a |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |

## Resources

| Name | Type |
|------|------|
| [kubernetes_manifest.spacelift_worker_pool](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_role_binding_v1.default](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/role_binding_v1) | resource |
| [kubernetes_role_v1.default](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/role_v1) | resource |
| [kubernetes_secret.default](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_service_account_v1.default](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account_v1) | resource |
| [spacelift_worker_pool.default](https://registry.terraform.io/providers/spacelift-io/spacelift/latest/docs/resources/worker_pool) | resource |
| [aws_eks_cluster_auth.eks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_ssm_parameter.spacelift_key_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.spacelift_key_secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [spacelift_spaces.default](https://registry.terraform.io/providers/spacelift-io/spacelift/latest/docs/data-sources/spaces) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br>This is for some rare cases where resources want additional configuration of tags<br>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br>in the order they appear in the list. New attributes are appended to the<br>end of the list. The elements of the list are joined by the `delimiter`<br>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_aws_config_file"></a> [aws\_config\_file](#input\_aws\_config\_file) | The AWS\_CONFIG\_FILE used by the worker. Can be overridden by `/.spacelift/config.yml`. | `string` | n/a | yes |
| <a name="input_aws_profile"></a> [aws\_profile](#input\_aws\_profile) | The AWS\_PROFILE used by the worker. If not specified, `"${var.namespace}-identity"` will be used.<br>Can be overridden by `/.spacelift/config.yml`. | `string` | `null` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "descriptor_formats": {},<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "labels_as_tags": [<br>    "unset"<br>  ],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {},<br>  "tenant": null<br>}</pre> | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br>Map of maps. Keys are names of descriptors. Values are maps of the form<br>`{<br>   format = string<br>   labels = list(string)<br>}`<br>(Type is `any` so the map values can later be enhanced to provide additional options.)<br>`format` is a Terraform format string to be passed to the `format()` function.<br>`labels` is a list of labels, in order, to pass to `format()` function.<br>Label values will be normalized before being passed to `format()` so they will be<br>identical to how they appear in `id`.<br>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_ecr_component_name"></a> [ecr\_component\_name](#input\_ecr\_component\_name) | ECR component name | `string` | `"ecr"` | no |
| <a name="input_ecr_environment_name"></a> [ecr\_environment\_name](#input\_ecr\_environment\_name) | The name of the environment where `ecr` is provisioned | `string` | `""` | no |
| <a name="input_ecr_repo_name"></a> [ecr\_repo\_name](#input\_ecr\_repo\_name) | ECR repository name | `string` | n/a | yes |
| <a name="input_ecr_stage_name"></a> [ecr\_stage\_name](#input\_ecr\_stage\_name) | The name of the stage where `ecr` is provisioned | `string` | `"artifacts"` | no |
| <a name="input_ecr_tenant_name"></a> [ecr\_tenant\_name](#input\_ecr\_tenant\_name) | The name of the tenant where `ecr` is provisioned.<br><br>If the `tenant` label is not used, leave this as `null`. | `string` | `null` | no |
| <a name="input_eks_component_name"></a> [eks\_component\_name](#input\_eks\_component\_name) | The name of the eks component | `string` | `"eks/cluster"` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_grpc_server_resources"></a> [grpc\_server\_resources](#input\_grpc\_server\_resources) | Resources for the gRPC server part of the worker pool deployment. The default values are usually sufficient. | <pre>object({<br>    requests = optional(object({<br>      memory = optional(string, "50Mi")<br>      cpu    = optional(string, "50m")<br>    }), {})<br>    limits = optional(object({<br>      memory = optional(string, "500Mi")<br>      cpu    = optional(string, "500m")<br>    }), {})<br>  })</pre> | `{}` | no |
| <a name="input_helm_manifest_experiment_enabled"></a> [helm\_manifest\_experiment\_enabled](#input\_helm\_manifest\_experiment\_enabled) | Enable storing of the rendered manifest for helm\_release so the full diff of what is changing can been seen in the plan | `bool` | `false` | no |
| <a name="input_iam_attributes"></a> [iam\_attributes](#input\_iam\_attributes) | Additional attributes to add to the IDs of the IAM role and policy | `list(string)` | `[]` | no |
| <a name="input_iam_override_policy_documents"></a> [iam\_override\_policy\_documents](#input\_iam\_override\_policy\_documents) | List of IAM policy documents that are merged together into the exported document with higher precedence.<br>In merging, statements with non-blank SIDs will override statements with the same SID<br>from earlier documents in the list and from other "source" documents. | `list(string)` | `null` | no |
| <a name="input_iam_permissions_boundary"></a> [iam\_permissions\_boundary](#input\_iam\_permissions\_boundary) | ARN of the policy that is used to set the permissions boundary for the IAM Role | `string` | `null` | no |
| <a name="input_iam_source_json_url"></a> [iam\_source\_json\_url](#input\_iam\_source\_json\_url) | IAM source JSON policy to download | `string` | `null` | no |
| <a name="input_iam_source_policy_documents"></a> [iam\_source\_policy\_documents](#input\_iam\_source\_policy\_documents) | List of IAM policy documents that are merged together into the exported document.<br>Statements defined in `iam_source_policy_documents` must have unique SIDs.<br>Statements with the same SID as in statements in documents assigned to the<br>`iam_override_policy_documents` arguments will be overridden. | `list(string)` | `null` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for keep the existing setting, which defaults to `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_keep_successful_pods"></a> [keep\_successful\_pods](#input\_keep\_successful\_pods) | Indicates whether run Pods should automatically be removed as soon<br>as they complete successfully, or be kept so that they can be inspected later. By default<br>run Pods are removed as soon as they complete successfully. Failed Pods are not automatically<br>removed to allow debugging. | `bool` | `false` | no |
| <a name="input_kube_data_auth_enabled"></a> [kube\_data\_auth\_enabled](#input\_kube\_data\_auth\_enabled) | If `true`, use an `aws_eks_cluster_auth` data source to authenticate to the EKS cluster.<br>Disabled by `kubeconfig_file_enabled` or `kube_exec_auth_enabled`. | `bool` | `false` | no |
| <a name="input_kube_exec_auth_aws_profile"></a> [kube\_exec\_auth\_aws\_profile](#input\_kube\_exec\_auth\_aws\_profile) | The AWS config profile for `aws eks get-token` to use | `string` | `""` | no |
| <a name="input_kube_exec_auth_aws_profile_enabled"></a> [kube\_exec\_auth\_aws\_profile\_enabled](#input\_kube\_exec\_auth\_aws\_profile\_enabled) | If `true`, pass `kube_exec_auth_aws_profile` as the `profile` to `aws eks get-token` | `bool` | `false` | no |
| <a name="input_kube_exec_auth_enabled"></a> [kube\_exec\_auth\_enabled](#input\_kube\_exec\_auth\_enabled) | If `true`, use the Kubernetes provider `exec` feature to execute `aws eks get-token` to authenticate to the EKS cluster.<br>Disabled by `kubeconfig_file_enabled`, overrides `kube_data_auth_enabled`. | `bool` | `true` | no |
| <a name="input_kube_exec_auth_role_arn"></a> [kube\_exec\_auth\_role\_arn](#input\_kube\_exec\_auth\_role\_arn) | The role ARN for `aws eks get-token` to use | `string` | `""` | no |
| <a name="input_kube_exec_auth_role_arn_enabled"></a> [kube\_exec\_auth\_role\_arn\_enabled](#input\_kube\_exec\_auth\_role\_arn\_enabled) | If `true`, pass `kube_exec_auth_role_arn` as the role ARN to `aws eks get-token` | `bool` | `true` | no |
| <a name="input_kubeconfig_context"></a> [kubeconfig\_context](#input\_kubeconfig\_context) | Context to choose from the Kubernetes config file.<br>If supplied, `kubeconfig_context_format` will be ignored. | `string` | `""` | no |
| <a name="input_kubeconfig_context_format"></a> [kubeconfig\_context\_format](#input\_kubeconfig\_context\_format) | A format string to use for creating the `kubectl` context name when<br>`kubeconfig_file_enabled` is `true` and `kubeconfig_context` is not supplied.<br>Must include a single `%s` which will be replaced with the cluster name. | `string` | `""` | no |
| <a name="input_kubeconfig_exec_auth_api_version"></a> [kubeconfig\_exec\_auth\_api\_version](#input\_kubeconfig\_exec\_auth\_api\_version) | The Kubernetes API version of the credentials returned by the `exec` auth plugin | `string` | `"client.authentication.k8s.io/v1beta1"` | no |
| <a name="input_kubeconfig_file"></a> [kubeconfig\_file](#input\_kubeconfig\_file) | The Kubernetes provider `config_path` setting to use when `kubeconfig_file_enabled` is `true` | `string` | `""` | no |
| <a name="input_kubeconfig_file_enabled"></a> [kubeconfig\_file\_enabled](#input\_kubeconfig\_file\_enabled) | If `true`, configure the Kubernetes provider with `kubeconfig_file` and use that kubeconfig file for authenticating to the EKS cluster | `bool` | `false` | no |
| <a name="input_kubernetes_namespace"></a> [kubernetes\_namespace](#input\_kubernetes\_namespace) | Name of the Kubernetes Namespace the Spacelift worker pool is deployed in to | `string` | n/a | yes |
| <a name="input_kubernetes_role_api_groups"></a> [kubernetes\_role\_api\_groups](#input\_kubernetes\_role\_api\_groups) | List of APIGroups for the Kubernetes Role created for the Kubernetes Service Account | `list(string)` | <pre>[<br>  ""<br>]</pre> | no |
| <a name="input_kubernetes_role_resource_names"></a> [kubernetes\_role\_resource\_names](#input\_kubernetes\_role\_resource\_names) | List of resource names for the Kubernetes Role created for the Kubernetes Service Account | `list(string)` | `null` | no |
| <a name="input_kubernetes_role_resources"></a> [kubernetes\_role\_resources](#input\_kubernetes\_role\_resources) | List of resources for the Kubernetes Role created for the Kubernetes Service Account | `list(string)` | <pre>[<br>  "*"<br>]</pre> | no |
| <a name="input_kubernetes_role_verbs"></a> [kubernetes\_role\_verbs](#input\_kubernetes\_role\_verbs) | List of verbs that apply to ALL the ResourceKinds for the Kubernetes Role created for the Kubernetes Service Account | `list(string)` | <pre>[<br>  "get",<br>  "list"<br>]</pre> | no |
| <a name="input_kubernetes_service_account_enabled"></a> [kubernetes\_service\_account\_enabled](#input\_kubernetes\_service\_account\_enabled) | Flag to enable/disable Kubernetes service account | `bool` | `false` | no |
| <a name="input_kubernetes_service_account_name"></a> [kubernetes\_service\_account\_name](#input\_kubernetes\_service\_account\_name) | Kubernetes service account name | `string` | `null` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br>Does not affect keys of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br>set as tag values, and output by this module individually.<br>Does not affect values of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br>Default is to include all labels.<br>Tags with empty values will not be included in the `tags` output.<br>Set to `[]` to suppress all generated tags.<br>**Notes:**<br>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br>  "default"<br>]</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br>This is the only ID element not also included as a `tag`.<br>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br>Characters matching the regex will be removed from the ID elements.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_space_name"></a> [space\_name](#input\_space\_name) | The name of the Spacelift Space to create the worker pool in | `string` | `"root"` | no |
| <a name="input_spacelift_api_endpoint"></a> [spacelift\_api\_endpoint](#input\_spacelift\_api\_endpoint) | The Spacelift API endpoint URL (e.g. https://example.app.spacelift.io) | `string` | n/a | yes |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |
| <a name="input_worker_pool_description"></a> [worker\_pool\_description](#input\_worker\_pool\_description) | Spacelift worker pool description. The default dynamically includes EKS cluster ID and Spacelift Space name. | `string` | `null` | no |
| <a name="input_worker_pool_size"></a> [worker\_pool\_size](#input\_worker\_pool\_size) | Worker pool size. The number of workers registered with Spacelift. | `number` | `1` | no |
| <a name="input_worker_spec"></a> [worker\_spec](#input\_worker\_spec) | Configuration for the Workers in the worker pool | <pre>object({<br>    tmpfs_enabled = optional(bool, false)<br>    resources = optional(object({<br>      limits = optional(object({<br>        cpu               = optional(string, "1")<br>        memory            = optional(string, "4500Mi")<br>        ephemeral-storage = optional(string, "2G")<br>      }), {})<br>      requests = optional(object({<br>        cpu               = optional(string, "750m")<br>        memory            = optional(string, "4Gi")<br>        ephemeral-storage = optional(string, "1G")<br>      }), {})<br>    }), {})<br>    annotations   = optional(map(string), {})<br>    node_selector = optional(map(string), {})<br>    tolerations = optional(list(object({<br>      key                = optional(string)<br>      operator           = optional(string)<br>      value              = optional(string)<br>      effect             = optional(string)<br>      toleration_seconds = optional(number)<br>    })), [])<br>    # activeDeadlineSeconds defines the length of time in seconds before which the Pod will<br>    # be marked as failed. This can be used to set a time limit for your runs.<br>    active_deadline_seconds          = optional(number, 4200) # 4200 seconds = 70 minutes<br>    termination_grace_period_seconds = optional(number, 50)<br>  })</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_service_account_name"></a> [service\_account\_name](#output\_service\_account\_name) | Kubernetes Service Account name |
| <a name="output_service_account_namespace"></a> [service\_account\_namespace](#output\_service\_account\_namespace) | Kubernetes Service Account namespace |
| <a name="output_service_account_policy_arn"></a> [service\_account\_policy\_arn](#output\_service\_account\_policy\_arn) | IAM policy ARN |
| <a name="output_service_account_policy_id"></a> [service\_account\_policy\_id](#output\_service\_account\_policy\_id) | IAM policy ID |
| <a name="output_service_account_policy_name"></a> [service\_account\_policy\_name](#output\_service\_account\_policy\_name) | IAM policy name |
| <a name="output_service_account_role_arn"></a> [service\_account\_role\_arn](#output\_service\_account\_role\_arn) | IAM role ARN |
| <a name="output_service_account_role_name"></a> [service\_account\_role\_name](#output\_service\_account\_role\_name) | IAM role name |
| <a name="output_service_account_role_unique_id"></a> [service\_account\_role\_unique\_id](#output\_service\_account\_role\_unique\_id) | IAM role unique ID |
| <a name="output_spacelift_worker_pool_manifest"></a> [spacelift\_worker\_pool\_manifest](#output\_spacelift\_worker\_pool\_manifest) | Spacelift worker pool Kubernetes manifest |
| <a name="output_worker_pool_id"></a> [worker\_pool\_id](#output\_worker\_pool\_id) | Spacelift worker pool ID |
| <a name="output_worker_pool_name"></a> [worker\_pool\_name](#output\_worker\_pool\_name) | Spacelift worker pool name |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->
