---
tags:
  - component/eks
  - layer/eks
  - layer/data
  - provider/aws
  - provider/helm
---

# Component: `eks/storage-class`

This component is responsible for provisioning `StorageClasses` in an EKS cluster. See the list of guides and references
linked at the bottom of this README for more information.

A StorageClass provides part of the configuration for a PersistentVolumeClaim, which copies the configuration when it is
created. Thus, you can delete a StorageClass without affecting existing PersistentVolumeClaims, and changes to a
StorageClass do not propagate to existing PersistentVolumeClaims.

## Usage

**Stack Level**: Regional, per cluster

This component can create storage classes backed by EBS or EFS, and is intended to be used with the corresponding EKS
add-ons `aws-ebs-csi-driver` and `aws-efs-csi-driver` respectively. In the case of EFS, this component also requires
that you have provisioned an EFS filesystem in the same region as your cluster, and expects you have used the `efs`
(previously `eks/efs`) component to do so. The EFS storage classes will get the file system ID from the EFS component's
output.

### Note: Default Storage Class

Exactly one StorageClass can be designated as the default StorageClass for a cluster. This default StorageClass is then
used by PersistentVolumeClaims that do not specify a storage class.

Prior to Kubernetes 1.26, if more than one StorageClass is marked as default, a PersistentVolumeClaim without
`storageClassName` explicitly specified cannot be created. In Kubernetes 1.26 and later, if more than one StorageClass
is marked as default, the last one created will be used, which means you can get by with just ignoring the default "gp2"
StorageClass that EKS creates for you.

EKS always creates a default storage class for the cluster, typically an EBS backed class named `gp2`. Find out what the
default storage class is for your cluster by running this command:

```bash
# You only need to run `set-cluster` when you are changing target clusters
set-cluster <cluster-name> admin # replace admin with other role name if desired
kubectl get storageclass
```

This will list the available storage classes, with the default one marked with `(default)` next to its name.

If you want to change the default, you can unset the existing default manually, like this:

```bash
SC_NAME=gp2 # Replace with the name of the storage class you want to unset as default
# You only need to run `set-cluster` when you are changing target clusters
set-cluster <cluster-name> admin # replace admin with other role name if desired
kubectl patch storageclass $SC_NAME -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
```

Or you can import the existing default storage class into Terraform and manage or delete it entirely, like this:

```bash
SC_NAME=gp2 # Replace with the name of the storage class you want to unset as default
atmos terraform import eks/storage-class 'kubernetes_storage_class_v1.ebs["'${SC_NAME}'"]' $SC_NAME -s=core-usw2-dev
```

View the parameters of a storage class by running this command:

```bash
SC_NAME=gp2 # Replace with the name of the storage class you want to view
# You only need to run `set-cluster` when you are changing target clusters
set-cluster <cluster-name> admin # replace admin with other role name if desired
kubectl get storageclass $SC_NAME -o yaml
```

You can then match that configuration, except that you cannot omit `allow_volume_expansion`.

```yaml
ebs_storage_classes:
  gp2:
    make_default_storage_class: true
    include_tags: false
    # Preserve values originally set by eks/cluster.
    # Set to "" to omit.
    provisioner: kubernetes.io/aws-ebs
    parameters:
      type: gp2
      encrypted: ""
```

Here's an example snippet for how to use this component.

```yaml
eks/storage-class:
  vars:
    ebs_storage_classes:
      gp2:
        make_default_storage_class: false
        include_tags: false
        # Preserve values originally set by eks/cluster.
        # Set to "" to omit.
        provisioner: kubernetes.io/aws-ebs
        parameters:
          type: gp2
          encrypted: ""
      gp3:
        make_default_storage_class: true
        parameters:
          type: gp3
    efs_storage_classes:
      efs-sc:
        make_default_storage_class: false
        efs_component_name: "efs" # Replace with the name of the EFS component, previously "eks/efs"
```

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.9.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.22.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.9.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.22.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_efs"></a> [efs](#module\_efs) | cloudposse/stack-config/yaml//modules/remote-state | 1.5.0 |
| <a name="module_eks"></a> [eks](#module\_eks) | cloudposse/stack-config/yaml//modules/remote-state | 1.5.0 |
| <a name="module_iam_roles"></a> [iam\_roles](#module\_iam\_roles) | ../../account-map/modules/iam-roles | n/a |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |

## Resources

| Name | Type |
|------|------|
| [kubernetes_storage_class_v1.ebs](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/storage_class_v1) | resource |
| [kubernetes_storage_class_v1.efs](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/storage_class_v1) | resource |
| [aws_eks_cluster_auth.eks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br>This is for some rare cases where resources want additional configuration of tags<br>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br>in the order they appear in the list. New attributes are appended to the<br>end of the list. The elements of the list are joined by the `delimiter`<br>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "descriptor_formats": {},<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "labels_as_tags": [<br>    "unset"<br>  ],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {},<br>  "tenant": null<br>}</pre> | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br>Map of maps. Keys are names of descriptors. Values are maps of the form<br>`{<br>   format = string<br>   labels = list(string)<br>}`<br>(Type is `any` so the map values can later be enhanced to provide additional options.)<br>`format` is a Terraform format string to be passed to the `format()` function.<br>`labels` is a list of labels, in order, to pass to `format()` function.<br>Label values will be normalized before being passed to `format()` so they will be<br>identical to how they appear in `id`.<br>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_ebs_storage_classes"></a> [ebs\_storage\_classes](#input\_ebs\_storage\_classes) | A map of storage class name to EBS parameters to create | <pre>map(object({<br>    make_default_storage_class = optional(bool, false)<br>    include_tags               = optional(bool, true) # If true, StorageClass will set our tags on created EBS volumes<br>    labels                     = optional(map(string), null)<br>    reclaim_policy             = optional(string, "Delete")<br>    volume_binding_mode        = optional(string, "WaitForFirstConsumer")<br>    mount_options              = optional(list(string), null)<br>    # Allowed topologies are poorly documented, and poorly implemented.<br>    # According to the API spec https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.26/#storageclass-v1-storage-k8s-io<br>    # it should be a list of objects with a `matchLabelExpressions` key, which is a list of objects with `key` and `values` keys.<br>    # However, the Terraform resource only allows a single object in a matchLabelExpressions block, not a list,<br>    # the EBS driver appears to only allow a single matchLabelExpressions block, and it is entirely unclear<br>    # what should happen if either of the lists has more than one element.<br>    # So we simplify it here to be singletons, not lists, and allow for a future change to the resource to support lists,<br>    # and a future replacement for this flattened object which can maintain backward compatibility.<br>    allowed_topologies_match_label_expressions = optional(object({<br>      key    = optional(string, "topology.ebs.csi.aws.com/zone")<br>      values = list(string)<br>    }), null)<br>    allow_volume_expansion = optional(bool, true)<br>    # parameters, see https://github.com/kubernetes-sigs/aws-ebs-csi-driver/blob/master/docs/parameters.md<br>    parameters = object({<br>      fstype                     = optional(string, "ext4") # "csi.storage.k8s.io/fstype"<br>      type                       = optional(string, "gp3")<br>      iopsPerGB                  = optional(string, null)<br>      allowAutoIOPSPerGBIncrease = optional(string, null) # "true" or "false"<br>      iops                       = optional(string, null)<br>      throughput                 = optional(string, null)<br><br>      encrypted    = optional(string, "true")<br>      kmsKeyId     = optional(string, null) # ARN of the KMS key to use for encryption. If not specified, the default key is used.<br>      blockExpress = optional(string, null) # "true" or "false"<br>      blockSize    = optional(string, null)<br>    })<br>    provisioner = optional(string, "ebs.csi.aws.com")<br><br>    # TODO: support tags<br>    # https://github.com/kubernetes-sigs/aws-ebs-csi-driver/blob/master/docs/tagging.md<br>  }))</pre> | `{}` | no |
| <a name="input_efs_storage_classes"></a> [efs\_storage\_classes](#input\_efs\_storage\_classes) | A map of storage class name to EFS parameters to create | <pre>map(object({<br>    make_default_storage_class = optional(bool, false)<br>    labels                     = optional(map(string), null)<br>    efs_component_name         = optional(string, "eks/efs")<br>    reclaim_policy             = optional(string, "Delete")<br>    volume_binding_mode        = optional(string, "Immediate")<br>    # Mount options are poorly documented.<br>    # TLS is now the default and need not be specified. https://github.com/kubernetes-sigs/aws-efs-csi-driver/tree/master/docs#encryption-in-transit<br>    # Other options include `lookupcache` and `iam`.<br>    mount_options = optional(list(string), null)<br>    parameters = optional(object({<br>      basePath         = optional(string, "/efs_controller")<br>      directoryPerms   = optional(string, "700")<br>      provisioningMode = optional(string, "efs-ap")<br>      gidRangeStart    = optional(string, null)<br>      gidRangeEnd      = optional(string, null)<br>      # Support for cross-account EFS mounts<br>      # See https://github.com/kubernetes-sigs/aws-efs-csi-driver/tree/master/examples/kubernetes/cross_account_mount<br>      # and for gritty details on secrets: https://kubernetes-csi.github.io/docs/secrets-and-credentials-storage-class.html<br>      az                           = optional(string, null)<br>      provisioner-secret-name      = optional(string, null) # "csi.storage.k8s.io/provisioner-secret-name"<br>      provisioner-secret-namespace = optional(string, null) # "csi.storage.k8s.io/provisioner-secret-namespace"<br>    }), {})<br>    provisioner = optional(string, "efs.csi.aws.com")<br>  }))</pre> | `{}` | no |
| <a name="input_eks_component_name"></a> [eks\_component\_name](#input\_eks\_component\_name) | The name of the EKS component for the cluster in which to create the storage classes | `string` | `"eks/cluster"` | no |
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
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br>Characters matching the regex will be removed from the ID elements.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region. | `string` | n/a | yes |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_storage_classes"></a> [storage\_classes](#output\_storage\_classes) | Storage classes created by this module |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## Related How-to Guides

- [EBS CSI Migration FAQ](https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi-migration-faq.html)
- [Migrating Clusters From gp2 to gp3 EBS Volumes](https://aws.amazon.com/blogs/containers/migrating-amazon-eks-clusters-from-gp2-to-gp3-ebs-volumes/)
- [Kubernetes: Change the Default StorageClass](https://kubernetes.io/docs/tasks/administer-cluster/change-default-storage-class/)

## References

- [Kubernetes Storage Classes](https://kubernetes.io/docs/concepts/storage/storage-classes)
-
- [EBS CSI driver (Amazon)](https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html)
- [EBS CSI driver (GitHub)](https://github.com/kubernetes-sigs/aws-ebs-csi-driver#documentation)
- [EBS CSI StorageClass Parameters](https://github.com/kubernetes-sigs/aws-ebs-csi-driver/blob/master/docs/parameters.md)
- [EFS CSI driver (Amazon)](https://docs.aws.amazon.com/eks/latest/userguide/efs-csi.html)
- [EFS CSI driver (GitHub)](https://github.com/kubernetes-sigs/aws-efs-csi-driver/blob/master/docs/README.md#examples)
- [EFS CSI StorageClass Parameters](https://github.com/kubernetes-sigs/aws-efs-csi-driver/tree/master/docs#storage-class-parameters-for-dynamic-provisioning)
- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/eks/cluster) -
  Cloud Posse's upstream component

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
