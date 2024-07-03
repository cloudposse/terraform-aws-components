# Component: `eks`

This component is responsible for provisioning an end-to-end EKS Cluster, including managed node groups.
NOTE: This component can only be deployed after logging in to AWS via Federated login with SAML (e.g. GSuite) or assuming an IAM role (e.g. from a CI/CD system). It cannot be deployed if you login to AWS via AWS SSO, the reason being is that on initial deployment, the EKS cluster will be owned by the assumed role that provisioned it. If this were to be the AWS SSO Role, then we risk losing access to the EKS cluster once the ARN of the AWS SSO Role eventually changes.

If Spotinst is going to be used, the following course of action needs to be followed:

1. Create Spotinst account and subscribe to a Business Plan.
1. Provision [spotinst-integration](https://spot.io/), as documented in the component.
1. Provision EKS with Spotinst Ocean pool only.
1. Deploy core K8s components, including [metrics-server](https://docs.cloudposse.com/components/library/aws/eks/metrics-server), [external-dns](https://docs.cloudposse.com/components/library/aws/eks/external-dns), etc.
1. Deploy Spotinst [ocean-controller](https://docs.spot.io/ocean/tutorials/spot-kubernetes-controller/).

## Usage

**Stack Level**: Regional

Here's an example snippet for how to use this component.

```yaml
components:
  terraform:
    eks:
      vars:
        enabled: true
        cluster_kubernetes_version: "1.21"
        region_availability_zones: ["us-west-2a", "us-west-2b", "us-west-2c"]
        public_access_cidrs: ["72.107.0.0/24"]
        managed_node_groups_enabled: true
        node_groups: # null means use default set in defaults.auto.tf.vars
          main:
            # values of `null` will be replaced with default values
            # availability_zones = null will create 1 auto scaling group in
            # each availability zone in region_availability_zones
            availability_zones: null

            desired_group_size: 3 # number of instances to start with, must be >= number of AZs
            min_group_size: 3 # must be  >= number of AZs
            max_group_size: 6

            # Can only set one of ami_release_version or kubernetes_version
            # Leave both null to use latest AMI for Cluster Kubernetes version
            kubernetes_version: null # use cluster Kubernetes version
            ami_release_version: null # use latest AMI for Kubernetes version

            attributes: []
            create_before_destroy: true
            disk_size: 100
            cluster_autoscaler_enabled: true
            instance_types:
              - t3.medium
            ami_type: AL2_x86_64 # use "AL2_x86_64" for standard instances, "AL2_x86_64_GPU" for GPU instances
            kubernetes_labels: {}
            kubernetes_taints: {}
            resources_to_tag:
              - instance
              - volume
            tags: null
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


## Reference

### Version Requirements

- [`terraform`](https://registry.terraform.io/modules/terraform/>= 1.0.0), version: >= 1.0.0
- [`aws`](https://registry.terraform.io/modules/aws/>= 3.0), version: >= 3.0

https://registry.terraform.io/modules/cloudposse/stack-config/yaml//remote-state



### Modules

Name | Version | Source | Description
--- | --- | --- | ---
`delegated_roles` | 1.4.1 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.4.1) | n/a
`eks` | 1.4.1 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.4.1) | Yes, this is self-referential. It obtains the previous state of the cluster so that we can add to it rather than overwrite it (specifically the aws-auth configMap)
`eks_cluster` | 0.44.0 | [`cloudposse/eks-cluster/aws`](https://registry.terraform.io/modules/cloudposse/eks-cluster/aws/0.44.0) | n/a
`iam_roles` | latest | [`../../account-map/modules/iam-roles`](https://registry.terraform.io/modules/../../account-map/modules/iam-roles/) | n/a
`primary_roles` | 1.4.1 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.4.1) | n/a
`region_node_group` | latest | [`./modules/node_group_by_region`](https://registry.terraform.io/modules/./modules/node_group_by_region/) | n/a
`this` | 0.25.0 | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | n/a
`vpc` | 1.4.1 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.4.1) | n/a
`vpc_ingress` | 1.4.1 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.4.1) | n/a




### Context Variables

The following variables are defined in the `context.tf` file of this module and part of the [terraform-null-label](https://registry.terraform.io/modules/cloudposse/label/null) pattern. These are identical in all Cloud Posse modules.

<details>
<summary>Click to expand</summary>
  ### `additional_tag_map` (`map(string)`) <i>optional</i>


Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br/>
This is for some rare cases where resources want additional configuration of tags<br/>
and therefore take a list of maps with tag key, value, and additional configuration.<br/>
<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `map(string)`
  </dd>
  <dt>Default value</dt>
  <dd>
  `{}`
  </dd>
</dl>

---


  ### `attributes` (`list(string)`) <i>optional</i>


ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br/>
in the order they appear in the list. New attributes are appended to the<br/>
end of the list. The elements of the list are joined by the `delimiter`<br/>
and treated as a single ID element.<br/>
<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `list(string)`
  </dd>
  <dt>Default value</dt>
  <dd>
  `[]`
  </dd>
</dl>

---


  ### `context` (`any`) <i>optional</i>


Single object for setting entire context at once.<br/>
See description of individual variables for details.<br/>
Leave string and numeric variables as `null` to use default value.<br/>
Individual variable settings (non-null) override settings in context object,<br/>
except for attributes, tags, and additional_tag_map, which are merged.<br/>
<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `any`
  </dd>
  <dt>Default value</dt>
  <dd>
  
  ```hcl
  {
    "additional_tag_map": {},
    "attributes": [],
    "delimiter": null,
    "descriptor_formats": {},
    "enabled": true,
    "environment": null,
    "id_length_limit": null,
    "label_key_case": null,
    "label_order": [],
    "label_value_case": null,
    "labels_as_tags": [
      "unset"
    ],
    "name": null,
    "namespace": null,
    "regex_replace_chars": null,
    "stage": null,
    "tags": {},
    "tenant": null
  }
  ```
  
  </dd>
</dl>

---


  ### `delimiter` (`string`) <i>optional</i>


Delimiter to be used between ID elements.<br/>
Defaults to `-` (hyphen). Set to `""` to use no delimiter at all.<br/>
<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `string`
  </dd>
  <dt>Default value</dt>
  <dd>
  `null`
  </dd>
</dl>

---


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
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `any`
  </dd>
  <dt>Default value</dt>
  <dd>
  `{}`
  </dd>
</dl>

---


  ### `enabled` (`bool`) <i>optional</i>


Set to false to prevent the module from creating any resources<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `bool`
  </dd>
  <dt>Default value</dt>
  <dd>
  `null`
  </dd>
</dl>

---


  ### `environment` (`string`) <i>optional</i>


ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT'<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `string`
  </dd>
  <dt>Default value</dt>
  <dd>
  `null`
  </dd>
</dl>

---


  ### `id_length_limit` (`number`) <i>optional</i>


Limit `id` to this many characters (minimum 6).<br/>
Set to `0` for unlimited length.<br/>
Set to `null` for keep the existing setting, which defaults to `0`.<br/>
Does not affect `id_full`.<br/>
<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `number`
  </dd>
  <dt>Default value</dt>
  <dd>
  `null`
  </dd>
</dl>

---


  ### `label_key_case` (`string`) <i>optional</i>


Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br/>
Does not affect keys of tags passed in via the `tags` input.<br/>
Possible values: `lower`, `title`, `upper`.<br/>
Default value: `title`.<br/>
<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `string`
  </dd>
  <dt>Default value</dt>
  <dd>
  `null`
  </dd>
</dl>

---


  ### `label_order` (`list(string)`) <i>optional</i>


The order in which the labels (ID elements) appear in the `id`.<br/>
Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br/>
You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present.<br/>
<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `list(string)`
  </dd>
  <dt>Default value</dt>
  <dd>
  `null`
  </dd>
</dl>

---


  ### `label_value_case` (`string`) <i>optional</i>


Controls the letter case of ID elements (labels) as included in `id`,<br/>
set as tag values, and output by this module individually.<br/>
Does not affect values of tags passed in via the `tags` input.<br/>
Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br/>
Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br/>
Default value: `lower`.<br/>
<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `string`
  </dd>
  <dt>Default value</dt>
  <dd>
  `null`
  </dd>
</dl>

---


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
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `set(string)`
  </dd>
  <dt>Default value</dt>
  <dd>
  
  ```hcl
  [
    "default"
  ]
  ```
  
  </dd>
</dl>

---


  ### `name` (`string`) <i>optional</i>


ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br/>
This is the only ID element not also included as a `tag`.<br/>
The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input.<br/>
<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `string`
  </dd>
  <dt>Default value</dt>
  <dd>
  `null`
  </dd>
</dl>

---


  ### `namespace` (`string`) <i>optional</i>


ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `string`
  </dd>
  <dt>Default value</dt>
  <dd>
  `null`
  </dd>
</dl>

---


  ### `regex_replace_chars` (`string`) <i>optional</i>


Terraform regular expression (regex) string.<br/>
Characters matching the regex will be removed from the ID elements.<br/>
If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits.<br/>
<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `string`
  </dd>
  <dt>Default value</dt>
  <dd>
  `null`
  </dd>
</dl>

---


  ### `stage` (`string`) <i>optional</i>


ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release'<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `string`
  </dd>
  <dt>Default value</dt>
  <dd>
  `null`
  </dd>
</dl>

---


  ### `tags` (`map(string)`) <i>optional</i>


Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br/>
Neither the tag keys nor the tag values will be modified by this module.<br/>
<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `map(string)`
  </dd>
  <dt>Default value</dt>
  <dd>
  `{}`
  </dd>
</dl>

---


  ### `tenant` (`string`) <i>optional</i>


ID element _(Rarely used, not included by default)_. A customer identifier, indicating who this instance of a resource is for<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `string`
  </dd>
  <dt>Default value</dt>
  <dd>
  `null`
  </dd>
</dl>

---


</details>

### Required Inputs
  ### `availability_zones` (`list(string)`) <i>required</i>


AWS Availability Zones in which to deploy multi-AZ resources<br/>
<dl>
  <dt>Required</dt>
  <dd>Yes</dd>
  <dt>Type</dt>
  <dd>
  `list(string)`
  </dd>
  <dt>Default value</dt>
  <dd>
  ``
  </dd>
</dl>

---


  ### `oidc_provider_enabled` (`bool`) <i>required</i>


Create an IAM OIDC identity provider for the cluster, then you can create IAM roles to associate with a service account in the cluster, instead of using kiam or kube2iam. For more information, see https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html<br/>
<dl>
  <dt>Required</dt>
  <dd>Yes</dd>
  <dt>Type</dt>
  <dd>
  `bool`
  </dd>
  <dt>Default value</dt>
  <dd>
  ``
  </dd>
</dl>

---


  ### `region` (`string`) <i>required</i>


AWS Region<br/>
<dl>
  <dt>Required</dt>
  <dd>Yes</dd>
  <dt>Type</dt>
  <dd>
  `string`
  </dd>
  <dt>Default value</dt>
  <dd>
  ``
  </dd>
</dl>

---



### Optional Inputs
  ### `allow_ingress_from_vpc_stages` (`list(string)`) <i>optional</i>


List of stages to pull VPC ingress CIDR and add to security group<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `list(string)`
  </dd>
  <dt>Default value</dt>
  <dd>
  `[]`
  </dd>
</dl>

---


  ### `allowed_cidr_blocks` (`list(string)`) <i>optional</i>


List of CIDR blocks to be allowed to connect to the EKS cluster<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `list(string)`
  </dd>
  <dt>Default value</dt>
  <dd>
  `[]`
  </dd>
</dl>

---


  ### `allowed_security_groups` (`list(string)`) <i>optional</i>


List of Security Group IDs to be allowed to connect to the EKS cluster<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `list(string)`
  </dd>
  <dt>Default value</dt>
  <dd>
  `[]`
  </dd>
</dl>

---


  ### `apply_config_map_aws_auth` (`bool`) <i>optional</i>


Whether to execute `kubectl apply` to apply the ConfigMap to allow worker nodes to join the EKS cluster<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `bool`
  </dd>
  <dt>Default value</dt>
  <dd>
  `true`
  </dd>
</dl>

---


  ### `availability_zone_abbreviation_type` (`string`) <i>optional</i>


Type of Availability Zone abbreviation (either `fixed` or `short`) to use in names. See https://github.com/cloudposse/terraform-aws-utils for details.<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `string`
  </dd>
  <dt>Default value</dt>
  <dd>
  `"fixed"`
  </dd>
</dl>

---


  ### `aws_auth_yaml_strip_quotes` (`bool`) <i>optional</i>


If true, remove double quotes from the generated aws-auth ConfigMap YAML to reduce spurious diffs in plans<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `bool`
  </dd>
  <dt>Default value</dt>
  <dd>
  `true`
  </dd>
</dl>

---


  ### `aws_ssm_agent_enabled` (`bool`) <i>optional</i>


Set true to attach the required IAM policy for AWS SSM agent to each EC2 instance's IAM Role<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `bool`
  </dd>
  <dt>Default value</dt>
  <dd>
  `false`
  </dd>
</dl>

---


  ### `cluster_encryption_config_enabled` (`bool`) <i>optional</i>


Set to `true` to enable Cluster Encryption Configuration<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `bool`
  </dd>
  <dt>Default value</dt>
  <dd>
  `true`
  </dd>
</dl>

---


  ### `cluster_encryption_config_kms_key_deletion_window_in_days` (`number`) <i>optional</i>


Cluster Encryption Config KMS Key Resource argument - key deletion windows in days post destruction<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `number`
  </dd>
  <dt>Default value</dt>
  <dd>
  `10`
  </dd>
</dl>

---


  ### `cluster_encryption_config_kms_key_enable_key_rotation` (`bool`) <i>optional</i>


Cluster Encryption Config KMS Key Resource argument - enable kms key rotation<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `bool`
  </dd>
  <dt>Default value</dt>
  <dd>
  `true`
  </dd>
</dl>

---


  ### `cluster_encryption_config_kms_key_id` (`string`) <i>optional</i>


KMS Key ID to use for cluster encryption config<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `string`
  </dd>
  <dt>Default value</dt>
  <dd>
  `""`
  </dd>
</dl>

---


  ### `cluster_encryption_config_kms_key_policy` (`string`) <i>optional</i>


Cluster Encryption Config KMS Key Resource argument - key policy<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `string`
  </dd>
  <dt>Default value</dt>
  <dd>
  `null`
  </dd>
</dl>

---


  ### `cluster_encryption_config_resources` (`list(any)`) <i>optional</i>


Cluster Encryption Config Resources to encrypt, e.g. ['secrets']<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `list(any)`
  </dd>
  <dt>Default value</dt>
  <dd>
  
  ```hcl
  [
    "secrets"
  ]
  ```
  
  </dd>
</dl>

---


  ### `cluster_endpoint_private_access` (`bool`) <i>optional</i>


Indicates whether or not the Amazon EKS private API server endpoint is enabled. Default to AWS EKS resource and it is `false`<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `bool`
  </dd>
  <dt>Default value</dt>
  <dd>
  `false`
  </dd>
</dl>

---


  ### `cluster_endpoint_public_access` (`bool`) <i>optional</i>


Indicates whether or not the Amazon EKS public API server endpoint is enabled. Default to AWS EKS resource and it is `true`<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `bool`
  </dd>
  <dt>Default value</dt>
  <dd>
  `true`
  </dd>
</dl>

---


  ### `cluster_kubernetes_version` (`string`) <i>optional</i>


Desired Kubernetes master version. If you do not specify a value, the latest available version is used<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `string`
  </dd>
  <dt>Default value</dt>
  <dd>
  `null`
  </dd>
</dl>

---


  ### `cluster_log_retention_period` (`number`) <i>optional</i>


Number of days to retain cluster logs. Requires `enabled_cluster_log_types` to be set. See https://docs.aws.amazon.com/en_us/eks/latest/userguide/control-plane-logs.html.<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `number`
  </dd>
  <dt>Default value</dt>
  <dd>
  `90`
  </dd>
</dl>

---


  ### `cluster_private_subnets_only` (`bool`) <i>optional</i>


Whether or not to enable private subnets or both public and private subnets<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `bool`
  </dd>
  <dt>Default value</dt>
  <dd>
  `false`
  </dd>
</dl>

---


  ### `color` (`string`) <i>optional</i>


The cluster stage represented by a color; e.g. blue, green<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `string`
  </dd>
  <dt>Default value</dt>
  <dd>
  `""`
  </dd>
</dl>

---


  ### `delegated_iam_roles` <i>optional</i>


Delegated IAM roles to add to `aws-auth` ConfigMap<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  

  ```hcl
  list(object({
    role   = string
    groups = list(string)
  }))
  ```
  
  </dd>
  <dt>Default value</dt>
  <dd>
  `[]`
  </dd>
</dl>

---


  ### `eks_component_name` (`string`) <i>optional</i>


The name of the eks component<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `string`
  </dd>
  <dt>Default value</dt>
  <dd>
  `"eks/cluster"`
  </dd>
</dl>

---


  ### `enabled_cluster_log_types` (`list(string)`) <i>optional</i>


A list of the desired control plane logging to enable. For more information, see https://docs.aws.amazon.com/en_us/eks/latest/userguide/control-plane-logs.html. Possible values [`api`, `audit`, `authenticator`, `controllerManager`, `scheduler`]<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `list(string)`
  </dd>
  <dt>Default value</dt>
  <dd>
  `[]`
  </dd>
</dl>

---


  ### `iam_primary_roles_stage_name` (`string`) <i>optional</i>


The name of the stage where the IAM primary roles are provisioned<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `string`
  </dd>
  <dt>Default value</dt>
  <dd>
  `"identity"`
  </dd>
</dl>

---


  ### `iam_primary_roles_tenant_name` (`string`) <i>optional</i>


The name of the tenant where the IAM primary roles are provisioned<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `string`
  </dd>
  <dt>Default value</dt>
  <dd>
  `null`
  </dd>
</dl>

---


  ### `iam_roles_environment_name` (`string`) <i>optional</i>


The name of the environment where the IAM roles are provisioned<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `string`
  </dd>
  <dt>Default value</dt>
  <dd>
  `"gbl"`
  </dd>
</dl>

---


  ### `kubeconfig_file` (`string`) <i>optional</i>


Name of `kubeconfig` file to use to configure Kubernetes provider<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `string`
  </dd>
  <dt>Default value</dt>
  <dd>
  `""`
  </dd>
</dl>

---


  ### `kubeconfig_file_enabled` (`bool`) <i>optional</i>


Set true to configure Kubernetes provider with a `kubeconfig` file specified by `kubeconfig_file`.<br/>
Mainly for when the standard configuration produces a Terraform error.<br/>
<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `bool`
  </dd>
  <dt>Default value</dt>
  <dd>
  `false`
  </dd>
</dl>

---


  ### `managed_node_groups_enabled` (`bool`) <i>optional</i>


Set false to prevent the creation of EKS managed node groups.<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `bool`
  </dd>
  <dt>Default value</dt>
  <dd>
  `true`
  </dd>
</dl>

---


  ### `map_additional_aws_accounts` (`list(string)`) <i>optional</i>


Additional AWS account numbers to add to `aws-auth` ConfigMap<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `list(string)`
  </dd>
  <dt>Default value</dt>
  <dd>
  `[]`
  </dd>
</dl>

---


  ### `map_additional_iam_roles` <i>optional</i>


Additional IAM roles to add to `config-map-aws-auth` ConfigMap<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  

  ```hcl
  list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  ```
  
  </dd>
  <dt>Default value</dt>
  <dd>
  `[]`
  </dd>
</dl>

---


  ### `map_additional_iam_users` <i>optional</i>


Additional IAM users to add to `aws-auth` ConfigMap<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  

  ```hcl
  list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  ```
  
  </dd>
  <dt>Default value</dt>
  <dd>
  `[]`
  </dd>
</dl>

---


  ### `map_additional_worker_roles` (`list(string)`) <i>optional</i>


AWS IAM Role ARNs of worker nodes to add to `aws-auth` ConfigMap<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `list(string)`
  </dd>
  <dt>Default value</dt>
  <dd>
  `[]`
  </dd>
</dl>

---


  ### `node_group_defaults` <i>optional</i>


Defaults for node groups in the cluster<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  

  ```hcl
  object({
    ami_release_version        = string
    ami_type                   = string
    attributes                 = list(string)
    availability_zones         = list(string) # set to null to use var.region_availability_zones
    cluster_autoscaler_enabled = bool
    create_before_destroy      = bool
    desired_group_size         = number
    disk_encryption_enabled    = bool
    disk_size                  = number
    instance_types             = list(string)
    kubernetes_labels          = map(string)
    kubernetes_taints = list(object({
      key    = string
      value  = string
      effect = string
    }))
    kubernetes_version = string # set to null to use cluster_kubernetes_version
    max_group_size     = number
    min_group_size     = number
    resources_to_tag   = list(string)
    tags               = map(string)
  })
  ```
  
  </dd>
  <dt>Default value</dt>
  <dd>
  
  ```hcl
  {
    "ami_release_version": null,
    "ami_type": null,
    "attributes": null,
    "availability_zones": null,
    "cluster_autoscaler_enabled": true,
    "create_before_destroy": true,
    "desired_group_size": 1,
    "disk_encryption_enabled": true,
    "disk_size": 20,
    "instance_types": [
      "t3.medium"
    ],
    "kubernetes_labels": null,
    "kubernetes_taints": null,
    "kubernetes_version": null,
    "max_group_size": 100,
    "min_group_size": null,
    "resources_to_tag": null,
    "tags": null
  }
  ```
  
  </dd>
</dl>

---


  ### `node_groups` <i>optional</i>


List of objects defining a node group for the cluster<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  

  ```hcl
  map(object({
    # EKS AMI version to use, e.g. "1.16.13-20200821" (no "v").
    ami_release_version = string
    # Type of Amazon Machine Image (AMI) associated with the EKS Node Group
    ami_type = string
    # Additional attributes (e.g. `1`) for the node group
    attributes = list(string)
    # will create 1 auto scaling group in each specified availability zone
    availability_zones = list(string)
    # Whether to enable Node Group to scale its AutoScaling Group
    cluster_autoscaler_enabled = bool
    # True to create new node_groups before deleting old ones, avoiding a temporary outage
    create_before_destroy = bool
    # Desired number of worker nodes when initially provisioned
    desired_group_size = number
    # Enable disk encryption for the created launch template (if we aren't provided with an existing launch template)
    disk_encryption_enabled = bool
    # Disk size in GiB for worker nodes. Terraform will only perform drift detection if a configuration value is provided.
    disk_size = number
    # Set of instance types associated with the EKS Node Group. Terraform will only perform drift detection if a configuration value is provided.
    instance_types = list(string)
    # Key-value mapping of Kubernetes labels. Only labels that are applied with the EKS API are managed by this argument. Other Kubernetes labels applied to the EKS Node Group will not be managed
    kubernetes_labels = map(string)
    # List of objects describing Kubernetes taints.
    kubernetes_taints = list(object({
      key    = string
      value  = string
      effect = string
    }))
    # Desired Kubernetes master version. If you do not specify a value, the latest available version is used
    kubernetes_version = string
    # The maximum size of the AutoScaling Group
    max_group_size = number
    # The minimum size of the AutoScaling Group
    min_group_size = number
    # List of auto-launched resource types to tag
    resources_to_tag = list(string)
    tags             = map(string)
  }))
  ```
  
  </dd>
  <dt>Default value</dt>
  <dd>
  `{}`
  </dd>
</dl>

---


  ### `primary_iam_roles` <i>optional</i>


Primary IAM roles to add to `aws-auth` ConfigMap<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  

  ```hcl
  list(object({
    role   = string
    groups = list(string)
  }))
  ```
  
  </dd>
  <dt>Default value</dt>
  <dd>
  `[]`
  </dd>
</dl>

---


  ### `public_access_cidrs` (`list(string)`) <i>optional</i>


Indicates which CIDR blocks can access the Amazon EKS public API server endpoint when enabled. EKS defaults this to a list with 0.0.0.0/0.<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `list(string)`
  </dd>
  <dt>Default value</dt>
  <dd>
  `[]`
  </dd>
</dl>

---


  ### `subnet_type_tag_key` (`string`) <i>optional</i>


The tag used to find the private subnets to find by availability zone. If null, will be looked up in vpc outputs.<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `string`
  </dd>
  <dt>Default value</dt>
  <dd>
  `null`
  </dd>
</dl>

---



### Outputs

<dl>
  <dt>`eks_auth_worker_roles`</dt>
  <dd>
    List of worker IAM roles that were included in the `auth-map` ConfigMap.<br/>
  </dd>
  <dt>`eks_cluster_arn`</dt>
  <dd>
    The Amazon Resource Name (ARN) of the cluster<br/>
  </dd>
  <dt>`eks_cluster_certificate_authority_data`</dt>
  <dd>
    The Kubernetes cluster certificate authority data<br/>
  </dd>
  <dt>`eks_cluster_endpoint`</dt>
  <dd>
    The endpoint for the Kubernetes API server<br/>
  </dd>
  <dt>`eks_cluster_id`</dt>
  <dd>
    The name of the cluster<br/>
  </dd>
  <dt>`eks_cluster_identity_oidc_issuer`</dt>
  <dd>
    The OIDC Identity issuer for the cluster<br/>
  </dd>
  <dt>`eks_cluster_managed_security_group_id`</dt>
  <dd>
    Security Group ID that was created by EKS for the cluster. EKS creates a Security Group and applies it to ENI that is attached to EKS Control Plane master nodes and to any managed workloads<br/>
  </dd>
  <dt>`eks_cluster_version`</dt>
  <dd>
    The Kubernetes server version of the cluster<br/>
  </dd>
  <dt>`eks_managed_node_workers_role_arns`</dt>
  <dd>
    List of ARNs for workers in managed node groups<br/>
  </dd>
  <dt>`eks_node_group_arns`</dt>
  <dd>
    List of all the node group ARNs in the cluster<br/>
  </dd>
  <dt>`eks_node_group_count`</dt>
  <dd>
    Count of the worker nodes<br/>
  </dd>
  <dt>`eks_node_group_ids`</dt>
  <dd>
    EKS Cluster name and EKS Node Group name separated by a colon<br/>
  </dd>
  <dt>`eks_node_group_role_names`</dt>
  <dd>
    List of worker nodes IAM role names<br/>
  </dd>
  <dt>`eks_node_group_statuses`</dt>
  <dd>
    Status of the EKS Node Group<br/>
  </dd>
</dl>
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## References

- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/master/modules/eks/eks-without-spotinst) - Cloud Posse's upstream component

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
