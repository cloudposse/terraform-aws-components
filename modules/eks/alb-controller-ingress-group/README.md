# alb-controller-ingress-group

This component creates a Kubernetes Service that creates an ALB for a specific [IngressGroup].

An [IngressGroup] is a feature of the [alb-controller] which allows multiple Kubernetes Ingresses to share the same Application Load Balancer.

## Usage

**Stack Level**: Regional

Once the catalog file is created, the file can be imported as follows.

```yaml
import:
  - catalog/eks/alb-controller-ingress-group
```

The default catalog values `e.g. stacks/catalog/eks/alb-controller-ingress-group.yaml` will create a Kubernetes Service in the `default` namespace with an [IngressGroup] named `alb-controller-ingress-group`.

```yaml
components:
  terraform:
    eks/alb-controller-ingress-group:
      settings:
        spacelift:
          workspace_enabled: true
      vars:
        enabled: true
        # change the name of the Ingress Group
        name: alb-controller-ingress-group
        # if this is not set, the expectation is that account-map
        # is deployed within the same tenant
        root_account_tenant_name: core
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.7.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.7.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_dns_delegated"></a> [dns\_delegated](#module\_dns\_delegated) | cloudposse/stack-config/yaml//modules/remote-state | 1.4.1 |
| <a name="module_eks"></a> [eks](#module\_eks) | cloudposse/stack-config/yaml//modules/remote-state | 1.4.1 |
| <a name="module_global_accelerator"></a> [global\_accelerator](#module\_global\_accelerator) | cloudposse/stack-config/yaml//modules/remote-state | 1.4.1 |
| <a name="module_iam_roles"></a> [iam\_roles](#module\_iam\_roles) | ../../account-map/modules/iam-roles | n/a |
| <a name="module_load_balancer_name"></a> [load\_balancer\_name](#module\_load\_balancer\_name) | cloudposse/label/null | 0.25.0 |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |
| <a name="module_waf"></a> [waf](#module\_waf) | cloudposse/stack-config/yaml//modules/remote-state | 1.4.1 |

## Resources

| Name | Type |
|------|------|
| [aws_globalaccelerator_endpoint_group.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/globalaccelerator_endpoint_group) | resource |
| [kubernetes_ingress_v1.default](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/ingress_v1) | resource |
| [kubernetes_namespace.default](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_service.default](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service) | resource |
| [aws_eks_cluster_auth.eks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |
| [aws_lb.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/lb) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_annotations"></a> [additional\_annotations](#input\_additional\_annotations) | Additional annotations to add to the Kubernetes ingress | `map(any)` | `{}` | no |
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br>This is for some rare cases where resources want additional configuration of tags<br>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_alb_access_logs_enabled"></a> [alb\_access\_logs\_enabled](#input\_alb\_access\_logs\_enabled) | Whether or not to enable access logs for the ALB | `bool` | `false` | no |
| <a name="input_alb_access_logs_s3_bucket_name"></a> [alb\_access\_logs\_s3\_bucket\_name](#input\_alb\_access\_logs\_s3\_bucket\_name) | The name of the S3 bucket to store the access logs in | `string` | `null` | no |
| <a name="input_alb_access_logs_s3_bucket_prefix"></a> [alb\_access\_logs\_s3\_bucket\_prefix](#input\_alb\_access\_logs\_s3\_bucket\_prefix) | The prefix to use when storing the access logs | `string` | `"echo-server"` | no |
| <a name="input_alb_group_name"></a> [alb\_group\_name](#input\_alb\_group\_name) | The name of the alb group | `string` | `null` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br>in the order they appear in the list. New attributes are appended to the<br>end of the list. The elements of the list are joined by the `delimiter`<br>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "descriptor_formats": {},<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "labels_as_tags": [<br>    "unset"<br>  ],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {},<br>  "tenant": null<br>}</pre> | no |
| <a name="input_create_namespace"></a> [create\_namespace](#input\_create\_namespace) | Create the namespace if it does not yet exist. Defaults to `false`. | `bool` | `false` | no |
| <a name="input_default_annotations"></a> [default\_annotations](#input\_default\_annotations) | Default annotations to add to the Kubernetes ingress | `map(any)` | <pre>{<br>  "alb.ingress.kubernetes.io/listen-ports": "[{\"HTTP\": 80}, {\"HTTPS\": 443}]",<br>  "alb.ingress.kubernetes.io/scheme": "internet-facing",<br>  "alb.ingress.kubernetes.io/target-type": "ip",<br>  "kubernetes.io/ingress.class": "alb"<br>}</pre> | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br>Map of maps. Keys are names of descriptors. Values are maps of the form<br>`{<br>   format = string<br>   labels = list(string)<br>}`<br>(Type is `any` so the map values can later be enhanced to provide additional options.)<br>`format` is a Terraform format string to be passed to the `format()` function.<br>`labels` is a list of labels, in order, to pass to `format()` function.<br>Label values will be normalized before being passed to `format()` so they will be<br>identical to how they appear in `id`.<br>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_dns_delegated_environment_name"></a> [dns\_delegated\_environment\_name](#input\_dns\_delegated\_environment\_name) | Global environment name | `string` | `"gbl"` | no |
| <a name="input_eks_component_name"></a> [eks\_component\_name](#input\_eks\_component\_name) | The name of the eks component | `string` | `"eks/cluster"` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_fixed_response_config"></a> [fixed\_response\_config](#input\_fixed\_response\_config) | Configuration to overwrite the defaults such as `contentType`, `statusCode`, and `messageBody` | `map(any)` | `{}` | no |
| <a name="input_fixed_response_template"></a> [fixed\_response\_template](#input\_fixed\_response\_template) | Fixed response template to service as a default backend | `string` | `"resources/default-backend.html.tpl"` | no |
| <a name="input_fixed_response_vars"></a> [fixed\_response\_vars](#input\_fixed\_response\_vars) | The templatefile vars to use for the fixed response template | `map(any)` | <pre>{<br>  "email": "hello@cloudposse.com"<br>}</pre> | no |
| <a name="input_global_accelerator_enabled"></a> [global\_accelerator\_enabled](#input\_global\_accelerator\_enabled) | Whether or not Global Accelerator Endpoint Group should be provisioned for the load balancer | `bool` | `false` | no |
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
| <a name="input_kubernetes_service_enabled"></a> [kubernetes\_service\_enabled](#input\_kubernetes\_service\_enabled) | Whether or not to enable a default kubernetes service | `bool` | `false` | no |
| <a name="input_kubernetes_service_path"></a> [kubernetes\_service\_path](#input\_kubernetes\_service\_path) | The kubernetes default service's path if enabled | `string` | `"/*"` | no |
| <a name="input_kubernetes_service_port"></a> [kubernetes\_service\_port](#input\_kubernetes\_service\_port) | The kubernetes default service's port if enabled | `number` | `8080` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br>Does not affect keys of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br>set as tag values, and output by this module individually.<br>Does not affect values of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br>Default is to include all labels.<br>Tags with empty values will not be included in the `tags` output.<br>Set to `[]` to suppress all generated tags.<br>**Notes:**<br>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br>  "default"<br>]</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br>This is the only ID element not also included as a `tag`.<br>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br>Characters matching the regex will be removed from the ID elements.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |
| <a name="input_waf_enabled"></a> [waf\_enabled](#input\_waf\_enabled) | Whether or not WAF ACL annotation should be provisioned for the load balancer | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_annotations"></a> [annotations](#output\_annotations) | The annotations of the Ingress |
| <a name="output_group_name"></a> [group\_name](#output\_group\_name) | The value of `alb.ingress.kubernetes.io/group.name` of the Ingress |
| <a name="output_host"></a> [host](#output\_host) | The name of the host used by the Ingress |
| <a name="output_load_balancer_name"></a> [load\_balancer\_name](#output\_load\_balancer\_name) | The name of the load balancer created by the Ingress |
| <a name="output_message_body_length"></a> [message\_body\_length](#output\_message\_body\_length) | The length of the message body to ensure it's lower than the maximum limit |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## References

* [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/master/modules/eks/alb-controller-ingress-group) - Cloud Posse's upstream component

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)

[IngressGroup]: <https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.2/guide/ingress/annotations/#ingressgroup>
[alb-controller]: <https://github.com/kubernetes-sigs/aws-load-balancer-controller>
