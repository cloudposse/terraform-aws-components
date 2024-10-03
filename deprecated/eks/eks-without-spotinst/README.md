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
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_delegated_roles"></a> [delegated\_roles](#module\_delegated\_roles) | cloudposse/stack-config/yaml//modules/remote-state | 1.4.1 |
| <a name="module_eks"></a> [eks](#module\_eks) | cloudposse/stack-config/yaml//modules/remote-state | 1.4.1 |
| <a name="module_eks_cluster"></a> [eks\_cluster](#module\_eks\_cluster) | cloudposse/eks-cluster/aws | 0.44.0 |
| <a name="module_iam_roles"></a> [iam\_roles](#module\_iam\_roles) | ../../account-map/modules/iam-roles | n/a |
| <a name="module_primary_roles"></a> [primary\_roles](#module\_primary\_roles) | cloudposse/stack-config/yaml//modules/remote-state | 1.4.1 |
| <a name="module_region_node_group"></a> [region\_node\_group](#module\_region\_node\_group) | ./modules/node_group_by_region | n/a |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | cloudposse/stack-config/yaml//modules/remote-state | 1.4.1 |
| <a name="module_vpc_ingress"></a> [vpc\_ingress](#module\_vpc\_ingress) | cloudposse/stack-config/yaml//modules/remote-state | 1.4.1 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br>This is for some rare cases where resources want additional configuration of tags<br>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_allow_ingress_from_vpc_stages"></a> [allow\_ingress\_from\_vpc\_stages](#input\_allow\_ingress\_from\_vpc\_stages) | List of stages to pull VPC ingress CIDR and add to security group | `list(string)` | `[]` | no |
| <a name="input_allowed_cidr_blocks"></a> [allowed\_cidr\_blocks](#input\_allowed\_cidr\_blocks) | List of CIDR blocks to be allowed to connect to the EKS cluster | `list(string)` | `[]` | no |
| <a name="input_allowed_security_groups"></a> [allowed\_security\_groups](#input\_allowed\_security\_groups) | List of Security Group IDs to be allowed to connect to the EKS cluster | `list(string)` | `[]` | no |
| <a name="input_apply_config_map_aws_auth"></a> [apply\_config\_map\_aws\_auth](#input\_apply\_config\_map\_aws\_auth) | Whether to execute `kubectl apply` to apply the ConfigMap to allow worker nodes to join the EKS cluster | `bool` | `true` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br>in the order they appear in the list. New attributes are appended to the<br>end of the list. The elements of the list are joined by the `delimiter`<br>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_availability_zone_abbreviation_type"></a> [availability\_zone\_abbreviation\_type](#input\_availability\_zone\_abbreviation\_type) | Type of Availability Zone abbreviation (either `fixed` or `short`) to use in names. See https://github.com/cloudposse/terraform-aws-utils for details. | `string` | `"fixed"` | no |
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | AWS Availability Zones in which to deploy multi-AZ resources | `list(string)` | n/a | yes |
| <a name="input_aws_auth_yaml_strip_quotes"></a> [aws\_auth\_yaml\_strip\_quotes](#input\_aws\_auth\_yaml\_strip\_quotes) | If true, remove double quotes from the generated aws-auth ConfigMap YAML to reduce spurious diffs in plans | `bool` | `true` | no |
| <a name="input_aws_ssm_agent_enabled"></a> [aws\_ssm\_agent\_enabled](#input\_aws\_ssm\_agent\_enabled) | Set true to attach the required IAM policy for AWS SSM agent to each EC2 instance's IAM Role | `bool` | `false` | no |
| <a name="input_cluster_encryption_config_enabled"></a> [cluster\_encryption\_config\_enabled](#input\_cluster\_encryption\_config\_enabled) | Set to `true` to enable Cluster Encryption Configuration | `bool` | `true` | no |
| <a name="input_cluster_encryption_config_kms_key_deletion_window_in_days"></a> [cluster\_encryption\_config\_kms\_key\_deletion\_window\_in\_days](#input\_cluster\_encryption\_config\_kms\_key\_deletion\_window\_in\_days) | Cluster Encryption Config KMS Key Resource argument - key deletion windows in days post destruction | `number` | `10` | no |
| <a name="input_cluster_encryption_config_kms_key_enable_key_rotation"></a> [cluster\_encryption\_config\_kms\_key\_enable\_key\_rotation](#input\_cluster\_encryption\_config\_kms\_key\_enable\_key\_rotation) | Cluster Encryption Config KMS Key Resource argument - enable kms key rotation | `bool` | `true` | no |
| <a name="input_cluster_encryption_config_kms_key_id"></a> [cluster\_encryption\_config\_kms\_key\_id](#input\_cluster\_encryption\_config\_kms\_key\_id) | KMS Key ID to use for cluster encryption config | `string` | `""` | no |
| <a name="input_cluster_encryption_config_kms_key_policy"></a> [cluster\_encryption\_config\_kms\_key\_policy](#input\_cluster\_encryption\_config\_kms\_key\_policy) | Cluster Encryption Config KMS Key Resource argument - key policy | `string` | `null` | no |
| <a name="input_cluster_encryption_config_resources"></a> [cluster\_encryption\_config\_resources](#input\_cluster\_encryption\_config\_resources) | Cluster Encryption Config Resources to encrypt, e.g. ['secrets'] | `list(any)` | <pre>[<br>  "secrets"<br>]</pre> | no |
| <a name="input_cluster_endpoint_private_access"></a> [cluster\_endpoint\_private\_access](#input\_cluster\_endpoint\_private\_access) | Indicates whether or not the Amazon EKS private API server endpoint is enabled. Default to AWS EKS resource and it is `false` | `bool` | `false` | no |
| <a name="input_cluster_endpoint_public_access"></a> [cluster\_endpoint\_public\_access](#input\_cluster\_endpoint\_public\_access) | Indicates whether or not the Amazon EKS public API server endpoint is enabled. Default to AWS EKS resource and it is `true` | `bool` | `true` | no |
| <a name="input_cluster_kubernetes_version"></a> [cluster\_kubernetes\_version](#input\_cluster\_kubernetes\_version) | Desired Kubernetes master version. If you do not specify a value, the latest available version is used | `string` | `null` | no |
| <a name="input_cluster_log_retention_period"></a> [cluster\_log\_retention\_period](#input\_cluster\_log\_retention\_period) | Number of days to retain cluster logs. Requires `enabled_cluster_log_types` to be set. See https://docs.aws.amazon.com/en_us/eks/latest/userguide/control-plane-logs.html. | `number` | `90` | no |
| <a name="input_cluster_private_subnets_only"></a> [cluster\_private\_subnets\_only](#input\_cluster\_private\_subnets\_only) | Whether or not to enable private subnets or both public and private subnets | `bool` | `false` | no |
| <a name="input_color"></a> [color](#input\_color) | The cluster stage represented by a color; e.g. blue, green | `string` | `""` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "descriptor_formats": {},<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "labels_as_tags": [<br>    "unset"<br>  ],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {},<br>  "tenant": null<br>}</pre> | no |
| <a name="input_delegated_iam_roles"></a> [delegated\_iam\_roles](#input\_delegated\_iam\_roles) | Delegated IAM roles to add to `aws-auth` ConfigMap | <pre>list(object({<br>    role   = string<br>    groups = list(string)<br>  }))</pre> | `[]` | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br>Map of maps. Keys are names of descriptors. Values are maps of the form<br>`{<br>   format = string<br>   labels = list(string)<br>}`<br>(Type is `any` so the map values can later be enhanced to provide additional options.)<br>`format` is a Terraform format string to be passed to the `format()` function.<br>`labels` is a list of labels, in order, to pass to `format()` function.<br>Label values will be normalized before being passed to `format()` so they will be<br>identical to how they appear in `id`.<br>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_eks_component_name"></a> [eks\_component\_name](#input\_eks\_component\_name) | The name of the eks component | `string` | `"eks/cluster"` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_enabled_cluster_log_types"></a> [enabled\_cluster\_log\_types](#input\_enabled\_cluster\_log\_types) | A list of the desired control plane logging to enable. For more information, see https://docs.aws.amazon.com/en_us/eks/latest/userguide/control-plane-logs.html. Possible values [`api`, `audit`, `authenticator`, `controllerManager`, `scheduler`] | `list(string)` | `[]` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_iam_primary_roles_stage_name"></a> [iam\_primary\_roles\_stage\_name](#input\_iam\_primary\_roles\_stage\_name) | The name of the stage where the IAM primary roles are provisioned | `string` | `"identity"` | no |
| <a name="input_iam_primary_roles_tenant_name"></a> [iam\_primary\_roles\_tenant\_name](#input\_iam\_primary\_roles\_tenant\_name) | The name of the tenant where the IAM primary roles are provisioned | `string` | `null` | no |
| <a name="input_iam_roles_environment_name"></a> [iam\_roles\_environment\_name](#input\_iam\_roles\_environment\_name) | The name of the environment where the IAM roles are provisioned | `string` | `"gbl"` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for keep the existing setting, which defaults to `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_kubeconfig_file"></a> [kubeconfig\_file](#input\_kubeconfig\_file) | Name of `kubeconfig` file to use to configure Kubernetes provider | `string` | `""` | no |
| <a name="input_kubeconfig_file_enabled"></a> [kubeconfig\_file\_enabled](#input\_kubeconfig\_file\_enabled) | Set true to configure Kubernetes provider with a `kubeconfig` file specified by `kubeconfig_file`.<br>Mainly for when the standard configuration produces a Terraform error. | `bool` | `false` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br>Does not affect keys of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br>set as tag values, and output by this module individually.<br>Does not affect values of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br>Default is to include all labels.<br>Tags with empty values will not be included in the `tags` output.<br>Set to `[]` to suppress all generated tags.<br>**Notes:**<br>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br>  "default"<br>]</pre> | no |
| <a name="input_managed_node_groups_enabled"></a> [managed\_node\_groups\_enabled](#input\_managed\_node\_groups\_enabled) | Set false to prevent the creation of EKS managed node groups. | `bool` | `true` | no |
| <a name="input_map_additional_aws_accounts"></a> [map\_additional\_aws\_accounts](#input\_map\_additional\_aws\_accounts) | Additional AWS account numbers to add to `aws-auth` ConfigMap | `list(string)` | `[]` | no |
| <a name="input_map_additional_iam_roles"></a> [map\_additional\_iam\_roles](#input\_map\_additional\_iam\_roles) | Additional IAM roles to add to `config-map-aws-auth` ConfigMap | <pre>list(object({<br>    rolearn  = string<br>    username = string<br>    groups   = list(string)<br>  }))</pre> | `[]` | no |
| <a name="input_map_additional_iam_users"></a> [map\_additional\_iam\_users](#input\_map\_additional\_iam\_users) | Additional IAM users to add to `aws-auth` ConfigMap | <pre>list(object({<br>    userarn  = string<br>    username = string<br>    groups   = list(string)<br>  }))</pre> | `[]` | no |
| <a name="input_map_additional_worker_roles"></a> [map\_additional\_worker\_roles](#input\_map\_additional\_worker\_roles) | AWS IAM Role ARNs of worker nodes to add to `aws-auth` ConfigMap | `list(string)` | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br>This is the only ID element not also included as a `tag`.<br>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_node_group_defaults"></a> [node\_group\_defaults](#input\_node\_group\_defaults) | Defaults for node groups in the cluster | <pre>object({<br>    ami_release_version        = string<br>    ami_type                   = string<br>    attributes                 = list(string)<br>    availability_zones         = list(string) # set to null to use var.region_availability_zones<br>    cluster_autoscaler_enabled = bool<br>    create_before_destroy      = bool<br>    desired_group_size         = number<br>    disk_encryption_enabled    = bool<br>    disk_size                  = number<br>    instance_types             = list(string)<br>    kubernetes_labels          = map(string)<br>    kubernetes_taints = list(object({<br>      key    = string<br>      value  = string<br>      effect = string<br>    }))<br>    kubernetes_version = string # set to null to use cluster_kubernetes_version<br>    max_group_size     = number<br>    min_group_size     = number<br>    resources_to_tag   = list(string)<br>    tags               = map(string)<br>  })</pre> | <pre>{<br>  "ami_release_version": null,<br>  "ami_type": null,<br>  "attributes": null,<br>  "availability_zones": null,<br>  "cluster_autoscaler_enabled": true,<br>  "create_before_destroy": true,<br>  "desired_group_size": 1,<br>  "disk_encryption_enabled": true,<br>  "disk_size": 20,<br>  "instance_types": [<br>    "t3.medium"<br>  ],<br>  "kubernetes_labels": null,<br>  "kubernetes_taints": null,<br>  "kubernetes_version": null,<br>  "max_group_size": 100,<br>  "min_group_size": null,<br>  "resources_to_tag": null,<br>  "tags": null<br>}</pre> | no |
| <a name="input_node_groups"></a> [node\_groups](#input\_node\_groups) | List of objects defining a node group for the cluster | <pre>map(object({<br>    # EKS AMI version to use, e.g. "1.16.13-20200821" (no "v").<br>    ami_release_version = string<br>    # Type of Amazon Machine Image (AMI) associated with the EKS Node Group<br>    ami_type = string<br>    # Additional attributes (e.g. `1`) for the node group<br>    attributes = list(string)<br>    # will create 1 auto scaling group in each specified availability zone<br>    availability_zones = list(string)<br>    # Whether to enable Node Group to scale its AutoScaling Group<br>    cluster_autoscaler_enabled = bool<br>    # True to create new node_groups before deleting old ones, avoiding a temporary outage<br>    create_before_destroy = bool<br>    # Desired number of worker nodes when initially provisioned<br>    desired_group_size = number<br>    # Enable disk encryption for the created launch template (if we aren't provided with an existing launch template)<br>    disk_encryption_enabled = bool<br>    # Disk size in GiB for worker nodes. Terraform will only perform drift detection if a configuration value is provided.<br>    disk_size = number<br>    # Set of instance types associated with the EKS Node Group. Terraform will only perform drift detection if a configuration value is provided.<br>    instance_types = list(string)<br>    # Key-value mapping of Kubernetes labels. Only labels that are applied with the EKS API are managed by this argument. Other Kubernetes labels applied to the EKS Node Group will not be managed<br>    kubernetes_labels = map(string)<br>    # List of objects describing Kubernetes taints.<br>    kubernetes_taints = list(object({<br>      key    = string<br>      value  = string<br>      effect = string<br>    }))<br>    # Desired Kubernetes master version. If you do not specify a value, the latest available version is used<br>    kubernetes_version = string<br>    # The maximum size of the AutoScaling Group<br>    max_group_size = number<br>    # The minimum size of the AutoScaling Group<br>    min_group_size = number<br>    # List of auto-launched resource types to tag<br>    resources_to_tag = list(string)<br>    tags             = map(string)<br>  }))</pre> | `{}` | no |
| <a name="input_oidc_provider_enabled"></a> [oidc\_provider\_enabled](#input\_oidc\_provider\_enabled) | Create an IAM OIDC identity provider for the cluster, then you can create IAM roles to associate with a service account in the cluster, instead of using kiam or kube2iam. For more information, see https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html | `bool` | n/a | yes |
| <a name="input_primary_iam_roles"></a> [primary\_iam\_roles](#input\_primary\_iam\_roles) | Primary IAM roles to add to `aws-auth` ConfigMap | <pre>list(object({<br>    role   = string<br>    groups = list(string)<br>  }))</pre> | `[]` | no |
| <a name="input_public_access_cidrs"></a> [public\_access\_cidrs](#input\_public\_access\_cidrs) | Indicates which CIDR blocks can access the Amazon EKS public API server endpoint when enabled. EKS defaults this to a list with 0.0.0.0/0. | `list(string)` | `[]` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br>Characters matching the regex will be removed from the ID elements.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_subnet_type_tag_key"></a> [subnet\_type\_tag\_key](#input\_subnet\_type\_tag\_key) | The tag used to find the private subnets to find by availability zone. If null, will be looked up in vpc outputs. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_eks_auth_worker_roles"></a> [eks\_auth\_worker\_roles](#output\_eks\_auth\_worker\_roles) | List of worker IAM roles that were included in the `auth-map` ConfigMap. |
| <a name="output_eks_cluster_arn"></a> [eks\_cluster\_arn](#output\_eks\_cluster\_arn) | The Amazon Resource Name (ARN) of the cluster |
| <a name="output_eks_cluster_certificate_authority_data"></a> [eks\_cluster\_certificate\_authority\_data](#output\_eks\_cluster\_certificate\_authority\_data) | The Kubernetes cluster certificate authority data |
| <a name="output_eks_cluster_endpoint"></a> [eks\_cluster\_endpoint](#output\_eks\_cluster\_endpoint) | The endpoint for the Kubernetes API server |
| <a name="output_eks_cluster_id"></a> [eks\_cluster\_id](#output\_eks\_cluster\_id) | The name of the cluster |
| <a name="output_eks_cluster_identity_oidc_issuer"></a> [eks\_cluster\_identity\_oidc\_issuer](#output\_eks\_cluster\_identity\_oidc\_issuer) | The OIDC Identity issuer for the cluster |
| <a name="output_eks_cluster_managed_security_group_id"></a> [eks\_cluster\_managed\_security\_group\_id](#output\_eks\_cluster\_managed\_security\_group\_id) | Security Group ID that was created by EKS for the cluster. EKS creates a Security Group and applies it to ENI that is attached to EKS Control Plane master nodes and to any managed workloads |
| <a name="output_eks_cluster_version"></a> [eks\_cluster\_version](#output\_eks\_cluster\_version) | The Kubernetes server version of the cluster |
| <a name="output_eks_managed_node_workers_role_arns"></a> [eks\_managed\_node\_workers\_role\_arns](#output\_eks\_managed\_node\_workers\_role\_arns) | List of ARNs for workers in managed node groups |
| <a name="output_eks_node_group_arns"></a> [eks\_node\_group\_arns](#output\_eks\_node\_group\_arns) | List of all the node group ARNs in the cluster |
| <a name="output_eks_node_group_count"></a> [eks\_node\_group\_count](#output\_eks\_node\_group\_count) | Count of the worker nodes |
| <a name="output_eks_node_group_ids"></a> [eks\_node\_group\_ids](#output\_eks\_node\_group\_ids) | EKS Cluster name and EKS Node Group name separated by a colon |
| <a name="output_eks_node_group_role_names"></a> [eks\_node\_group\_role\_names](#output\_eks\_node\_group\_role\_names) | List of worker nodes IAM role names |
| <a name="output_eks_node_group_statuses"></a> [eks\_node\_group\_statuses](#output\_eks\_node\_group\_statuses) | Status of the EKS Node Group |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## References

- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/master/modules/eks/eks-without-spotinst) - Cloud Posse's upstream component

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
