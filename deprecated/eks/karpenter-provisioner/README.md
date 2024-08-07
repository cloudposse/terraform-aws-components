# Component: `eks/karpenter-provisioner`

> [!WARNING]
>
> #### This component is DEPRECATED
>
> With v1beta1 of Karpenter, the `provisioner` component is deprecated.
> Please use the `eks/karpenter-node-group` component instead.
>
> For more details, see the [Karpenter v1beta1 release notes](/modules/eks/karpenter/CHANGELOG.md).

This component deploys [Karpenter provisioners](https://karpenter.sh/v0.18.0/aws/provisioning) on an EKS cluster.

## Usage

**Stack Level**: Regional

If provisioning more than one provisioner, it is
[best practice](https://aws.github.io/aws-eks-best-practices/karpenter/#create-provisioners-that-are-mutually-exclusive-or-weighted)
to create provisioners that are mutually exclusive or weighted.

```yaml
components:
  terraform:
    eks/karpenter-provisioner:
      settings:
        spacelift:
          workspace_enabled: true
      vars:
        enabled: true
        eks_component_name: eks/cluster
        name: "karpenter-provisioner"
        # https://karpenter.sh/v0.18.0/getting-started/getting-started-with-terraform
        # https://karpenter.sh/v0.18.0/aws/provisioning
        provisioners:
          default:
            name: default
            # Whether to place EC2 instances launched by Karpenter into VPC private subnets. Set it to `false` to use public subnets
            private_subnets_enabled: true
            # Configures Karpenter to terminate empty nodes after the specified number of seconds.
            # This behavior can be disabled by setting the value to `null` (never scales down if not set)
            ttl_seconds_after_empty: 30
            # Configures Karpenter to terminate nodes when a maximum age is reached.
            #This behavior can be disabled by setting the value to `null` (never expires if not set)
            ttl_seconds_until_expired: 2592000
            # Karpenter provisioner total CPU limit for all pods running on the EC2 instances launched by Karpenter
            total_cpu_limit: "100"
            # Karpenter provisioner total memory limit for all pods running on the EC2 instances launched by Karpenter
            total_memory_limit: "1000Gi"
            # Set acceptable (In) and unacceptable (Out) Kubernetes and Karpenter values for node provisioning based on
            # Well-Known Labels and cloud-specific settings. These can include instance types, zones, computer architecture,
            # and capacity type (such as AWS spot or on-demand).
            # See https://karpenter.sh/v0.18.0/provisioner/#specrequirements for more details
            requirements:
              - key: "karpenter.k8s.aws/instance-category"
                operator: "In"
                values: ["c", "m", "r"]
              - key: "karpenter.k8s.aws/instance-generation"
                operator: "Gt"
                values: ["2"]
              - key: "karpenter.sh/capacity-type"
                operator: "In"
                values:
                  - "on-demand"
                  - "spot"
              - key: "node.kubernetes.io/instance-type"
                operator: "In"
                # See https://aws.amazon.com/ec2/instance-explorer/ and https://aws.amazon.com/ec2/instance-types/
                # Values limited by DenyEC2InstancesWithoutEncryptionInTransit service control policy
                # See https://github.com/cloudposse/terraform-aws-service-control-policies/blob/master/catalog/ec2-policies.yaml
                # Karpenter recommends allowing at least 20 instance types to ensure availability.
                values:
                  - "c5n.2xlarge"
                  - "c5n.xlarge"
                  - "c5n.large"
                  - "c6i.2xlarge"
                  - "c6i.xlarge"
                  - "c6i.large"
                  - "m5n.2xlarge"
                  - "m5n.xlarge"
                  - "m5n.large"
                  - "m5zn.2xlarge"
                  - "m5zn.xlarge"
                  - "m5zn.large"
                  - "m6i.2xlarge"
                  - "m6i.xlarge"
                  - "m6i.large"
                  - "r5n.2xlarge"
                  - "r5n.xlarge"
                  - "r5n.large"
                  - "r6i.2xlarge"
                  - "r6i.xlarge"
                  - "r6i.large"
              - key: "kubernetes.io/arch"
                operator: "In"
                values:
                  - "amd64"
            # The AMI used by Karpenter provisioner when provisioning nodes. Based on the value set for amiFamily, Karpenter will automatically query for the appropriate EKS optimized AMI via AWS Systems Manager (SSM)
            # Bottlerocket, AL2, Ubuntu
            # https://karpenter.sh/v0.18.0/aws/provisioning/#amazon-machine-image-ami-family
            ami_family: AL2
            # Karpenter provisioner block device mappings.
            block_device_mappings:
              - deviceName: /dev/xvda
                ebs:
                  volumeSize: 200Gi
                  volumeType: gp3
                  encrypted: true
                  deleteOnTermination: true
```

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.9.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.14.0, != 2.21.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.9.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.14.0, != 2.21.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eks"></a> [eks](#module\_eks) | cloudposse/stack-config/yaml//modules/remote-state | 1.5.0 |
| <a name="module_iam_roles"></a> [iam\_roles](#module\_iam\_roles) | ../../account-map/modules/iam-roles | n/a |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | cloudposse/stack-config/yaml//modules/remote-state | 1.5.0 |

## Resources

| Name | Type |
|------|------|
| [kubernetes_manifest.provider](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.provisioner](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [aws_eks_cluster_auth.eks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br>This is for some rare cases where resources want additional configuration of tags<br>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br>in the order they appear in the list. New attributes are appended to the<br>end of the list. The elements of the list are joined by the `delimiter`<br>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "descriptor_formats": {},<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "labels_as_tags": [<br>    "unset"<br>  ],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {},<br>  "tenant": null<br>}</pre> | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br>Map of maps. Keys are names of descriptors. Values are maps of the form<br>`{<br>   format = string<br>   labels = list(string)<br>}`<br>(Type is `any` so the map values can later be enhanced to provide additional options.)<br>`format` is a Terraform format string to be passed to the `format()` function.<br>`labels` is a list of labels, in order, to pass to `format()` function.<br>Label values will be normalized before being passed to `format()` so they will be<br>identical to how they appear in `id`.<br>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_eks_component_name"></a> [eks\_component\_name](#input\_eks\_component\_name) | The name of the eks component | `string` | `"eks/cluster"` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_helm_manifest_experiment_enabled"></a> [helm\_manifest\_experiment\_enabled](#input\_helm\_manifest\_experiment\_enabled) | Enable storing of the rendered manifest for helm\_release so the full diff of what is changing can been seen in the plan | `bool` | `false` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for keep the existing setting, which defaults to `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
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
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br>Does not affect keys of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br>set as tag values, and output by this module individually.<br>Does not affect values of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br>Default is to include all labels.<br>Tags with empty values will not be included in the `tags` output.<br>Set to `[]` to suppress all generated tags.<br>**Notes:**<br>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br>  "default"<br>]</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br>This is the only ID element not also included as a `tag`.<br>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_provisioners"></a> [provisioners](#input\_provisioners) | Karpenter provisioners config | <pre>map(object({<br>    # The name of the Karpenter provisioner<br>    name = string<br>    # Whether to place EC2 instances launched by Karpenter into VPC private subnets. Set it to `false` to use public subnets<br>    private_subnets_enabled = optional(bool, true)<br>    # Configures Karpenter to terminate empty nodes after the specified number of seconds. This behavior can be disabled by setting the value to `null` (never scales down if not set)<br>    # Conflicts with `consolidation.enabled`, which is usually a better option.<br>    ttl_seconds_after_empty = optional(number, null)<br>    # Configures Karpenter to terminate nodes when a maximum age is reached. This behavior can be disabled by setting the value to `null` (never expires if not set)<br>    ttl_seconds_until_expired = optional(number, null)<br>    # Continuously binpack containers into least possible number of nodes. Mutually exclusive with ttl_seconds_after_empty.<br>    # Ideally `true` by default, but conflicts with `ttl_seconds_after_empty`, which was previously the only option.<br>    consolidation = optional(object({<br>      enabled = bool<br>    }), { enabled = false })<br>    # Karpenter provisioner total CPU limit for all pods running on the EC2 instances launched by Karpenter<br>    total_cpu_limit = string<br>    # Karpenter provisioner total memory limit for all pods running on the EC2 instances launched by Karpenter<br>    total_memory_limit = string<br>    # Set acceptable (In) and unacceptable (Out) Kubernetes and Karpenter values for node provisioning based on Well-Known Labels and cloud-specific settings. These can include instance types, zones, computer architecture, and capacity type (such as AWS spot or on-demand). See https://karpenter.sh/v0.18.0/provisioner/#specrequirements for more details<br>    requirements = list(object({<br>      key      = string<br>      operator = string<br>      values   = list(string)<br>    }))<br>    # Karpenter provisioner taints configuration. See https://aws.github.io/aws-eks-best-practices/karpenter/#create-provisioners-that-are-mutually-exclusive for more details<br>    taints = optional(list(object({<br>      key    = string<br>      effect = string<br>      value  = string<br>    })), [])<br>    startup_taints = optional(list(object({<br>      key    = string<br>      effect = string<br>      value  = string<br>    })), [])<br>    # Karpenter provisioner metadata options. See https://karpenter.sh/v0.18.0/aws/provisioning/#metadata-options for more details<br>    metadata_options = optional(object({<br>      httpEndpoint            = optional(string, "enabled"),  # valid values: enabled, disabled<br>      httpProtocolIPv6        = optional(string, "disabled"), # valid values: enabled, disabled<br>      httpPutResponseHopLimit = optional(number, 2),          # limit of 1 discouraged because it keeps Pods from reaching metadata service<br>      httpTokens              = optional(string, "required")  # valid values: required, optional<br>    })),<br>    # The AMI used by Karpenter provisioner when provisioning nodes. Based on the value set for amiFamily, Karpenter will automatically query for the appropriate EKS optimized AMI via AWS Systems Manager (SSM)<br>    ami_family = string<br>    # Karpenter provisioner block device mappings. Controls the Elastic Block Storage volumes that Karpenter attaches to provisioned nodes. Karpenter uses default block device mappings for the AMI Family specified. For example, the Bottlerocket AMI Family defaults with two block device mappings. See https://karpenter.sh/v0.18.0/aws/provisioning/#block-device-mappings for more details<br>    block_device_mappings = optional(list(object({<br>      deviceName = string<br>      ebs = optional(object({<br>        volumeSize          = string<br>        volumeType          = string<br>        deleteOnTermination = optional(bool, true)<br>        encrypted           = optional(bool, true)<br>        iops                = optional(number)<br>        kmsKeyID            = optional(string, "alias/aws/ebs")<br>        snapshotID          = optional(string)<br>        throughput          = optional(number)<br>      }))<br>    })), [])<br>  }))</pre> | n/a | yes |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br>Characters matching the regex will be removed from the ID elements.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_providers"></a> [providers](#output\_providers) | Deployed Karpenter AWSNodeTemplates |
| <a name="output_provisioners"></a> [provisioners](#output\_provisioners) | Deployed Karpenter provisioners |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## References

- https://karpenter.sh
- https://aws.github.io/aws-eks-best-practices/karpenter
- https://karpenter.sh/v0.18.0/getting-started/getting-started-with-terraform
- https://aws.amazon.com/blogs/aws/introducing-karpenter-an-open-source-high-performance-kubernetes-cluster-autoscaler
- https://github.com/aws/karpenter
- https://www.eksworkshop.com/beginner/085_scaling_karpenter
- https://ec2spotworkshops.com/karpenter.html
- https://www.eksworkshop.com/beginner/085_scaling_karpenter/install_karpenter
- https://karpenter.sh/v0.18.0/development-guide
- https://karpenter.sh/v0.18.0/aws/provisioning

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
