# Component: `eks/karpenter-node-pool`

This component deploys [Karpenter NodePools](https://karpenter.sh/docs/concepts/nodepools/) to an EKS cluster.

Karpenter is still in v0 and rapidly evolving. At this time, this component only supports a subset of the features
available in Karpenter. Support could be added for additional features as needed.

Not supported:

- Elements of NodePool:
  - [`template.spec.kubelet`](https://karpenter.sh/docs/concepts/nodepools/#spectemplatespeckubelet)
  - [`limits`](https://karpenter.sh/docs/concepts/nodepools/#limits) currently only supports `cpu` and `memory`. Other
    limits such as `nvidia.com/gpu` are not supported.
- Elements of NodeClass:
  - `subnetSelectorTerms`. This component only supports selecting all public or all private subnets of the referenced
    EKS cluster.
  - `securityGroupSelectorTerms`. This component only supports selecting the security group of the referenced EKS
    cluster.
  - `amiSelectorTerms`. Such terms override the `amiFamily` setting, which is the only AMI selection supported by this
    component.
  - `instanceStorePolicy`
  - `userData`
  - `detailedMonitoring`
  - `associatePublicIPAddress`

## Usage

**Stack Level**: Regional

If provisioning more than one NodePool, it is
[best practice](https://aws.github.io/aws-eks-best-practices/karpenter/#creating-nodepools) to create NodePools that are
mutually exclusive or weighted.

```yaml
components:
  terraform:
    eks/karpenter-node-pool:
      settings:
        spacelift:
          workspace_enabled: true
      vars:
        enabled: true
        eks_component_name: eks/cluster
        name: "karpenter-node-pool"
        # https://karpenter.sh/v0.36.0/docs/concepts/nodepools/
        node_pools:
          default:
            name: default
            # Whether to place EC2 instances launched by Karpenter into VPC private subnets. Set it to `false` to use public subnets
            private_subnets_enabled: true
            disruption:
              consolidation_policy: WhenUnderutilized
              consolidate_after: 1h
              max_instance_lifetime: 336h
              budgets:
                # This budget allows 0 disruptions during business hours (from 9am to 5pm) on weekdays
                - schedule: "0 9 * * mon-fri"
                  duration: 8h
                  nodes: "0"
            # The total cpu of the cluster. Maps to spec.limits.cpu in the Karpenter NodeClass
            total_cpu_limit: "100"
            # The total memory of the cluster. Maps to spec.limits.memory in the Karpenter NodeClass
            total_memory_limit: "1000Gi"
            # The weight of the node pool. See https://karpenter.sh/docs/concepts/scheduling/#weighted-nodepools
            weight: 50
            # Taints to apply to the nodes in the node pool. See https://karpenter.sh/docs/concepts/nodeclasses/#spectaints
            taints:
              - key: "node.kubernetes.io/unreachable"
                effect: "NoExecute"
                value: "true"
            # Taints to apply to the nodes in the node pool at startup. See https://karpenter.sh/docs/concepts/nodeclasses/#specstartuptaints
            startup_taints:
              - key: "node.kubernetes.io/unreachable"
                effect: "NoExecute"
                value: "true"
            # Metadata options for the node pool. See https://karpenter.sh/docs/concepts/nodeclasses/#specmetadataoptions
            metadata_options:
              httpEndpoint: "enabled" # allows the node to call the AWS metadata service
              httpProtocolIPv6: "disabled"
              httpPutResponseHopLimit: 2
              httpTokens: "required"
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
            # Set acceptable (In) and unacceptable (Out) Kubernetes and Karpenter values for node provisioning based on
            # Well-Known Labels and cloud-specific settings. These can include instance types, zones, computer architecture,
            # and capacity type (such as AWS spot or on-demand).
            # See https://karpenter.sh/v0.18.0/provisioner/#specrequirements for more details
            requirements:
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
```

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->



## Version Requirements

| Requirement | Version |
| --- | --- |
| `terraform` | >= 1.3.0 |
| `aws` | >= 4.9.0 |
| `helm` | >= 2.0 |
| `kubernetes` | >= 2.7.1, != 2.21.0 |


## Providers

| Provider | Version |
| --- | --- |
| `aws` | >= 4.9.0 |
| `kubernetes` | >= 2.7.1, != 2.21.0 |


## Modules

Name | Version | Source | Description
--- | --- | --- | ---
`eks` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a
`iam_roles` | latest | [`../../account-map/modules/iam-roles`](https://registry.terraform.io/modules/../../account-map/modules/iam-roles/) | n/a
`this` | 0.25.0 | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | n/a
`vpc` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a


## Resources

The following resources are used by this module:

  - [`kubernetes_manifest.ec2_node_class`](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) (resource)(ec2-node-class.tf#26)
  - [`kubernetes_manifest.node_pool`](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) (resource)(main.tf#15)

## Data Sources

The following data sources are used by this module:

  - [`aws_eks_cluster_auth.eks`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) (data source)

## Outputs

<dl>
  <dt><code>ec2_node_classes</code></dt>
  <dd>
    Deployed Karpenter EC2NodeClass<br/>

  </dd>
  <dt><code>node_pools</code></dt>
  <dd>
    Deployed Karpenter NodePool<br/>

  </dd>
</dl>

## Required Variables

Required variables are the minimum set of variables that must be set to use this module.

> [!IMPORTANT]
>
> To customize the names and tags of the resources created by this module, see the [context variables](#context-variables).
>
### `node_pools` <i>required</i>


Configuration for node pools. See code for details.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>Yes</dd>
>   <dt>Type</dt>
>   <dd>
>   
>
>   ```hcl
>   map(object({
    # The name of the Karpenter provisioner. The map key is used if this is not set.
    name = optional(string)
    # Whether to place EC2 instances launched by Karpenter into VPC private subnets. Set it to `false` to use public subnets.
    private_subnets_enabled = bool
    # The Disruption spec controls how Karpenter scales down the node group.
    # See the example (sadly not the specific `spec.disruption` documentation) at https://karpenter.sh/docs/concepts/nodepools/ for details
    disruption = optional(object({
      # Describes which types of Nodes Karpenter should consider for consolidation.
      # If using 'WhenUnderutilized', Karpenter will consider all nodes for consolidation and attempt to remove or
      # replace Nodes when it discovers that the Node is underutilized and could be changed to reduce cost.
      # If using `WhenEmpty`, Karpenter will only consider nodes for consolidation that contain no workload pods.
      consolidation_policy = optional(string, "WhenUnderutilized")

      # The amount of time Karpenter should wait after discovering a consolidation decision (`go` duration string, s, m, or h).
      # This value can currently (v0.36.0) only be set when the consolidationPolicy is 'WhenEmpty'.
      # You can choose to disable consolidation entirely by setting the string value 'Never' here.
      # Earlier versions of Karpenter called this field `ttl_seconds_after_empty`.
      consolidate_after = optional(string)

      # The amount of time a Node can live on the cluster before being removed (`go` duration string, s, m, or h).
      # You can choose to disable expiration entirely by setting the string value 'Never' here.
      # This module sets a default of 336 hours (14 days), while the Karpenter default is 720 hours (30 days).
      # Note that Karpenter calls this field "expiresAfter", and earlier versions called it `ttl_seconds_until_expired`,
      # but we call it "max_instance_lifetime" to match the corresponding field in EC2 Auto Scaling Groups.
      max_instance_lifetime = optional(string, "336h")

      # Budgets control the the maximum number of NodeClaims owned by this NodePool that can be terminating at once.
      # See https://karpenter.sh/docs/concepts/disruption/#disruption-budgets for details.
      # A percentage is the percentage of the total number of active, ready nodes not being deleted, rounded up.
      # If there are multiple active budgets, Karpenter uses the most restrictive value.
      # If left undefined, this will default to one budget with a value of nodes: 10%.
      # Note that budgets do not prevent or limit involuntary terminations.
      # Example:
      #   On Weekdays during business hours, don't do any deprovisioning.
      #     budgets = {
      #       schedule = "0 9 * * mon-fri"
      #       duration = 8h
      #       nodes    = "0"
      #     }
      budgets = optional(list(object({
        # The schedule specifies when a budget begins being active, using extended cronjob syntax.
        # See https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/#schedule-syntax for syntax details.
        # Timezones are not supported. This field is required if Duration is set.
        schedule = optional(string)
        # Duration determines how long a Budget is active after each Scheduled start.
        # If omitted, the budget is always active. This is required if Schedule is set.
        # Must be a whole number of minutes and hours, as cron does not work in seconds,
        # but since Go's `duration.String()` always adds a "0s" at the end, that is allowed.
        duration = optional(string)
        # The percentage or number of nodes that Karpenter can scale down during the budget.
        nodes = string
      })), [])
    }), {})
    # Karpenter provisioner total CPU limit for all pods running on the EC2 instances launched by Karpenter
    total_cpu_limit = string
    # Karpenter provisioner total memory limit for all pods running on the EC2 instances launched by Karpenter
    total_memory_limit = string
    # Set a weight for this node pool.
    # See https://karpenter.sh/docs/concepts/scheduling/#weighted-nodepools
    weight      = optional(number, 50)
    labels      = optional(map(string))
    annotations = optional(map(string))
    # Karpenter provisioner taints configuration. See https://aws.github.io/aws-eks-best-practices/karpenter/#create-provisioners-that-are-mutually-exclusive for more details
    taints = optional(list(object({
      key    = string
      effect = string
      value  = string
    })))
    startup_taints = optional(list(object({
      key    = string
      effect = string
      value  = string
    })))
    # Karpenter node metadata options. See https://karpenter.sh/docs/concepts/nodeclasses/#specmetadataoptions for more details
    metadata_options = optional(object({
      httpEndpoint            = optional(string, "enabled")
      httpProtocolIPv6        = optional(string, "disabled")
      httpPutResponseHopLimit = optional(number, 2)
      # httpTokens can be either "required" or "optional"
      httpTokens = optional(string, "required")
    }), {})
    # The AMI used by Karpenter provisioner when provisioning nodes. Based on the value set for amiFamily, Karpenter will automatically query for the appropriate EKS optimized AMI via AWS Systems Manager (SSM)
    ami_family = string
    # Karpenter nodes block device mappings. Controls the Elastic Block Storage volumes that Karpenter attaches to provisioned nodes.
    # Karpenter uses default block device mappings for the AMI Family specified.
    # For example, the Bottlerocket AMI Family defaults with two block device mappings,
    # and normally you only want to scale `/dev/xvdb` where Containers and there storage are stored.
    # Most other AMIs only have one device mapping at `/dev/xvda`.
    # See https://karpenter.sh/docs/concepts/nodeclasses/#specblockdevicemappings for more details
    block_device_mappings = list(object({
      deviceName = string
      ebs = optional(object({
        volumeSize          = string
        volumeType          = string
        deleteOnTermination = optional(bool, true)
        encrypted           = optional(bool, true)
        iops                = optional(number)
        kmsKeyID            = optional(string, "alias/aws/ebs")
        snapshotID          = optional(string)
        throughput          = optional(number)
      }))
    }))
    # Set acceptable (In) and unacceptable (Out) Kubernetes and Karpenter values for node provisioning based on Well-Known Labels and cloud-specific settings. These can include instance types, zones, computer architecture, and capacity type (such as AWS spot or on-demand). See https://karpenter.sh/v0.18.0/provisioner/#specrequirements for more details
    requirements = list(object({
      key      = string
      operator = string
      # Operators like "Exists" and "DoesNotExist" do not require a value
      values = optional(list(string))
    }))
  }))
>   ```
>
>   
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code></code>>   </dd>
> </dl>
>


### `region` (`string`) <i>required</i>


AWS Region<br/>

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
>    <code></code>>   </dd>
> </dl>
>



## Optional Variables
### `eks_component_name` (`string`) <i>optional</i>


The name of the eks component<br/>

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
>    <code>"eks/cluster"</code>>   </dd>
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
>    <code>false</code>>   </dd>
> </dl>
>


### `import_profile_name` (`string`) <i>optional</i>


AWS Profile name to use when importing a resource<br/>

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
>    <code>null</code>>   </dd>
> </dl>
>


### `import_role_arn` (`string`) <i>optional</i>


IAM Role ARN to use when importing a resource<br/>

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
>    <code>null</code>>   </dd>
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
>    <code>false</code>>   </dd>
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
>    <code>""</code>>   </dd>
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
>    <code>false</code>>   </dd>
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
>    <code>true</code>>   </dd>
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
>    <code>""</code>>   </dd>
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
>    <code>true</code>>   </dd>
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
>    <code>""</code>>   </dd>
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
>    <code>""</code>>   </dd>
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
>    <code>"client.authentication.k8s.io/v1beta1"</code>>   </dd>
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
>    <code>""</code>>   </dd>
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
>    <code>false</code>>   </dd>
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
>    <code>{}</code>>   </dd>
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
>    <code>[]</code>>   </dd>
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
>    ```hcl>
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
>>   </dd>
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
>    <code>null</code>>   </dd>
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
>    <code>{}</code>>   </dd>
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
>    <code>null</code>>   </dd>
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
>    <code>null</code>>   </dd>
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
>    <code>null</code>>   </dd>
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
>    <code>null</code>>   </dd>
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
>    <code>null</code>>   </dd>
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
>    <code>null</code>>   </dd>
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
>    ```hcl>
>    [
>
>      "default"
>
>    ]
>
>    ```
>>   </dd>
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
>    <code>null</code>>   </dd>
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
>    <code>null</code>>   </dd>
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
>    <code>null</code>>   </dd>
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
>    <code>null</code>>   </dd>
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
>    <code>{}</code>>   </dd>
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
>    <code>null</code>>   </dd>
> </dl>
>



</details>
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## References

- https://karpenter.sh
- https://aws.github.io/aws-eks-best-practices/karpenter
- https://karpenter.sh/docs/concepts/nodepools
- https://aws.amazon.com/blogs/aws/introducing-karpenter-an-open-source-high-performance-kubernetes-cluster-autoscaler
- https://github.com/aws/karpenter
- https://ec2spotworkshops.com/karpenter.html
- https://www.eksworkshop.com/docs/autoscaling/compute/karpenter/

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
