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

You can then match that configuration, except that you cannot omit `allow_volume_exansion`.

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



## Version Requirements

| Requirement | Version |
| --- | --- |
| `terraform` | >= 1.3.0 |
| `aws` | >= 4.9.0 |
| `helm` | >= 2.0 |
| `kubernetes` | >= 2.22.0 |


## Providers

| Provider | Version |
| --- | --- |
| `aws` | >= 4.9.0 |
| `kubernetes` | >= 2.22.0 |


## Modules

Name | Version | Source | Description
--- | --- | --- | ---
`efs` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a
`eks` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a
`iam_roles` | latest | [`../../account-map/modules/iam-roles`](https://registry.terraform.io/modules/../../account-map/modules/iam-roles/) | n/a
`this` | 0.25.0 | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | n/a


## Resources

The following resources are used by this module:

  - [`kubernetes_storage_class_v1.ebs`](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/storage_class_v1) (resource)(main.tf#26)
  - [`kubernetes_storage_class_v1.efs`](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/storage_class_v1) (resource)(main.tf#71)

## Data Sources

The following data sources are used by this module:

  - [`aws_eks_cluster_auth.eks`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) (data source)

## Outputs

<dl>
  <dt><code>storage_classes</code></dt>
  <dd>
    Storage classes created by this module<br/>

  </dd>
</dl>

## Required Variables

Required variables are the minimum set of variables that must be set to use this module.

> [!IMPORTANT]
>
> To customize the names and tags of the resources created by this module, see the [context variables](#context-variables).
>
### `region` (`string`) <i>required</i>


AWS Region.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>Yes</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code></code>
>   </dd>
> </dl>
>



## Optional Variables
### `ebs_storage_classes` <i>optional</i>


A map of storage class name to EBS parameters to create<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   
>
>   ```hcl
>   map(object({
    make_default_storage_class = optional(bool, false)
    include_tags               = optional(bool, true) # If true, StorageClass will set our tags on created EBS volumes
    labels                     = optional(map(string), null)
    reclaim_policy             = optional(string, "Delete")
    volume_binding_mode        = optional(string, "WaitForFirstConsumer")
    mount_options              = optional(list(string), null)
    # Allowed topologies are poorly documented, and poorly implemented.
    # According to the API spec https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.26/#storageclass-v1-storage-k8s-io
    # it should be a list of objects with a `matchLabelExpressions` key, which is a list of objects with `key` and `values` keys.
    # However, the Terraform resource only allows a single object in a matchLabelExpressions block, not a list,
    # the EBS driver appears to only allow a single matchLabelExpressions block, and it is entirely unclear
    # what should happen if either of the lists has more than one element.
    # So we simplify it here to be singletons, not lists, and allow for a future change to the resource to support lists,
    # and a future replacement for this flattened object which can maintain backward compatibility.
    allowed_topologies_match_label_expressions = optional(object({
      key    = optional(string, "topology.ebs.csi.aws.com/zone")
      values = list(string)
    }), null)
    allow_volume_expansion = optional(bool, true)
    # parameters, see https://github.com/kubernetes-sigs/aws-ebs-csi-driver/blob/master/docs/parameters.md
    parameters = object({
      fstype                     = optional(string, "ext4") # "csi.storage.k8s.io/fstype"
      type                       = optional(string, "gp3")
      iopsPerGB                  = optional(string, null)
      allowAutoIOPSPerGBIncrease = optional(string, null) # "true" or "false"
      iops                       = optional(string, null)
      throughput                 = optional(string, null)

      encrypted    = optional(string, "true")
      kmsKeyId     = optional(string, null) # ARN of the KMS key to use for encryption. If not specified, the default key is used.
      blockExpress = optional(string, null) # "true" or "false"
      blockSize    = optional(string, null)
    })
    provisioner = optional(string, "ebs.csi.aws.com")

    # TODO: support tags
    # https://github.com/kubernetes-sigs/aws-ebs-csi-driver/blob/master/docs/tagging.md
  }))
>   ```
>
>   
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>{}</code>
>   </dd>
> </dl>
>


### `efs_storage_classes` <i>optional</i>


A map of storage class name to EFS parameters to create<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   
>
>   ```hcl
>   map(object({
    make_default_storage_class = optional(bool, false)
    labels                     = optional(map(string), null)
    efs_component_name         = optional(string, "eks/efs")
    reclaim_policy             = optional(string, "Delete")
    volume_binding_mode        = optional(string, "Immediate")
    # Mount options are poorly documented.
    # TLS is now the default and need not be specified. https://github.com/kubernetes-sigs/aws-efs-csi-driver/tree/master/docs#encryption-in-transit
    # Other options include `lookupcache` and `iam`.
    mount_options = optional(list(string), null)
    parameters = optional(object({
      basePath         = optional(string, "/efs_controller")
      directoryPerms   = optional(string, "700")
      provisioningMode = optional(string, "efs-ap")
      gidRangeStart    = optional(string, null)
      gidRangeEnd      = optional(string, null)
      # Support for cross-account EFS mounts
      # See https://github.com/kubernetes-sigs/aws-efs-csi-driver/tree/master/examples/kubernetes/cross_account_mount
      # and for gritty details on secrets: https://kubernetes-csi.github.io/docs/secrets-and-credentials-storage-class.html
      az                           = optional(string, null)
      provisioner-secret-name      = optional(string, null) # "csi.storage.k8s.io/provisioner-secret-name"
      provisioner-secret-namespace = optional(string, null) # "csi.storage.k8s.io/provisioner-secret-namespace"
    }), {})
    provisioner = optional(string, "efs.csi.aws.com")
  }))
>   ```
>
>   
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>{}</code>
>   </dd>
> </dl>
>


### `eks_component_name` (`string`) <i>optional</i>


The name of the EKS component for the cluster in which to create the storage classes<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>"eks/cluster"</code>
>   </dd>
> </dl>
>


### `helm_manifest_experiment_enabled` (`bool`) <i>optional</i>


Enable storing of the rendered manifest for helm_release so the full diff of what is changing can been seen in the plan<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>false</code>
>   </dd>
> </dl>
>


### `kube_data_auth_enabled` (`bool`) <i>optional</i>


If `true`, use an `aws_eks_cluster_auth` data source to authenticate to the EKS cluster.<br/>
Disabled by `kubeconfig_file_enabled` or `kube_exec_auth_enabled`.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>false</code>
>   </dd>
> </dl>
>


### `kube_exec_auth_aws_profile` (`string`) <i>optional</i>


The AWS config profile for `aws eks get-token` to use<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>""</code>
>   </dd>
> </dl>
>


### `kube_exec_auth_aws_profile_enabled` (`bool`) <i>optional</i>


If `true`, pass `kube_exec_auth_aws_profile` as the `profile` to `aws eks get-token`<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>false</code>
>   </dd>
> </dl>
>


### `kube_exec_auth_enabled` (`bool`) <i>optional</i>


If `true`, use the Kubernetes provider `exec` feature to execute `aws eks get-token` to authenticate to the EKS cluster.<br/>
Disabled by `kubeconfig_file_enabled`, overrides `kube_data_auth_enabled`.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>true</code>
>   </dd>
> </dl>
>


### `kube_exec_auth_role_arn` (`string`) <i>optional</i>


The role ARN for `aws eks get-token` to use<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>""</code>
>   </dd>
> </dl>
>


### `kube_exec_auth_role_arn_enabled` (`bool`) <i>optional</i>


If `true`, pass `kube_exec_auth_role_arn` as the role ARN to `aws eks get-token`<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>true</code>
>   </dd>
> </dl>
>


### `kubeconfig_context` (`string`) <i>optional</i>


Context to choose from the Kubernetes config file.<br/>
If supplied, `kubeconfig_context_format` will be ignored.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>""</code>
>   </dd>
> </dl>
>


### `kubeconfig_context_format` (`string`) <i>optional</i>


A format string to use for creating the `kubectl` context name when<br/>
`kubeconfig_file_enabled` is `true` and `kubeconfig_context` is not supplied.<br/>
Must include a single `%s` which will be replaced with the cluster name.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>""</code>
>   </dd>
> </dl>
>


### `kubeconfig_exec_auth_api_version` (`string`) <i>optional</i>


The Kubernetes API version of the credentials returned by the `exec` auth plugin<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>"client.authentication.k8s.io/v1beta1"</code>
>   </dd>
> </dl>
>


### `kubeconfig_file` (`string`) <i>optional</i>


The Kubernetes provider `config_path` setting to use when `kubeconfig_file_enabled` is `true`<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>""</code>
>   </dd>
> </dl>
>


### `kubeconfig_file_enabled` (`bool`) <i>optional</i>


If `true`, configure the Kubernetes provider with `kubeconfig_file` and use that kubeconfig file for authenticating to the EKS cluster<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>false</code>
>   </dd>
> </dl>
>



## Context Variables

The following variables are defined in the `context.tf` file of this module and part of the [terraform-null-label](https://registry.terraform.io/modules/cloudposse/label/null) pattern. These are identical in all Cloud Posse modules.

<details>
<summary>Click to expand</summary>


### `additional_tag_map` (`map(string)`) <i>optional</i>


Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br/>
This is for some rare cases where resources want additional configuration of tags<br/>
and therefore take a list of maps with tag key, value, and additional configuration.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>map(string)</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>{}</code>
>   </dd>
> </dl>
>


### `attributes` (`list(string)`) <i>optional</i>


ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br/>
in the order they appear in the list. New attributes are appended to the<br/>
end of the list. The elements of the list are joined by the `delimiter`<br/>
and treated as a single ID element.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>[]</code>
>   </dd>
> </dl>
>


### `context` (`any`) <i>optional</i>


Single object for setting entire context at once.<br/>
See description of individual variables for details.<br/>
Leave string and numeric variables as `null` to use default value.<br/>
Individual variable settings (non-null) override settings in context object,<br/>
except for attributes, tags, and additional_tag_map, which are merged.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>any</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    
>
>    ```hcl
>    >
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
>    
>   </dd>
> </dl>
>


### `delimiter` (`string`) <i>optional</i>


Delimiter to be used between ID elements.<br/>
Defaults to `-` (hyphen). Set to `""` to use no delimiter at all.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `descriptor_formats` (`any`) <i>optional</i>


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

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>any</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>{}</code>
>   </dd>
> </dl>
>


### `enabled` (`bool`) <i>optional</i>


Set to false to prevent the module from creating any resources<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `environment` (`string`) <i>optional</i>


ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT'<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `id_length_limit` (`number`) <i>optional</i>


Limit `id` to this many characters (minimum 6).<br/>
Set to `0` for unlimited length.<br/>
Set to `null` for keep the existing setting, which defaults to `0`.<br/>
Does not affect `id_full`.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>number</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `label_key_case` (`string`) <i>optional</i>


Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br/>
Does not affect keys of tags passed in via the `tags` input.<br/>
Possible values: `lower`, `title`, `upper`.<br/>
Default value: `title`.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `label_order` (`list(string)`) <i>optional</i>


The order in which the labels (ID elements) appear in the `id`.<br/>
Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br/>
You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `label_value_case` (`string`) <i>optional</i>


Controls the letter case of ID elements (labels) as included in `id`,<br/>
set as tag values, and output by this module individually.<br/>
Does not affect values of tags passed in via the `tags` input.<br/>
Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br/>
Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br/>
Default value: `lower`.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `labels_as_tags` (`set(string)`) <i>optional</i>


Set of labels (ID elements) to include as tags in the `tags` output.<br/>
Default is to include all labels.<br/>
Tags with empty values will not be included in the `tags` output.<br/>
Set to `[]` to suppress all generated tags.<br/>
**Notes:**<br/>
  The value of the `name` tag, if included, will be the `id`, not the `name`.<br/>
  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br/>
  changed in later chained modules. Attempts to change it will be silently ignored.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>set(string)</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    
>
>    ```hcl
>    >
>    [
>
>      "default"
>
>    ]
>
>    ```
>
>    
>   </dd>
> </dl>
>


### `name` (`string`) <i>optional</i>


ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br/>
This is the only ID element not also included as a `tag`.<br/>
The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `namespace` (`string`) <i>optional</i>


ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `regex_replace_chars` (`string`) <i>optional</i>


Terraform regular expression (regex) string.<br/>
Characters matching the regex will be removed from the ID elements.<br/>
If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `stage` (`string`) <i>optional</i>


ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release'<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `tags` (`map(string)`) <i>optional</i>


Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br/>
Neither the tag keys nor the tag values will be modified by this module.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>map(string)</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>{}</code>
>   </dd>
> </dl>
>


### `tenant` (`string`) <i>optional</i>


ID element _(Rarely used, not included by default)_. A customer identifier, indicating who this instance of a resource is for<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>



</details>
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
