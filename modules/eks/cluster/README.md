# Component: `eks/cluster`

This component is responsible for provisioning an end-to-end EKS Cluster, including managed node groups.


:::warning


This component should only be deployed after logging into AWS via Federated login with SAML (e.g. GSuite) or
assuming an IAM role (e.g. from a CI/CD system). It should not be deployed if you log into AWS via AWS SSO, the
reason being that on initial deployment, the EKS cluster will be owned by the assumed role that provisioned it,
and AWS SSO roles are ephemeral (replaced on every configuration change). If this were to be the AWS SSO Role, then
we risk losing access to the EKS cluster once the ARN of the AWS SSO Role eventually changes.

:::

## Usage

**Stack Level**: Regional

Here's an example snippet for how to use this component.

This example expects the [Cloud Posse Reference Architecture](https://docs.cloudposse.com/reference-architecture/)
Identity and Network designs deployed for mapping users to EKS service roles and granting access in a private network.
In addition, this example has the GitHub OIDC integration added and makes use of Karpenter to dynamically scale cluster nodes.

For more on these requirements, see
[Identity Reference Architecture](https://docs.cloudposse.com/reference-architecture/quickstart/iam-identity/),
[Network Reference Architecture](https://docs.cloudposse.com/reference-architecture/scaffolding/setup/network/),
the [Github OIDC component](https://docs.cloudposse.com/components/catalog/aws/github-oidc-provider/),
and the [Karpenter component](https://docs.cloudposse.com/components/catalog/aws/eks/karpenter/).

```yaml
components:
  terraform:
    eks/cluster:
      vars:
        enabled: true
        name: eks
        iam_primary_roles_tenant_name: core
        cluster_kubernetes_version: "1.25"
        # Your choice of availability zones or availability zone ids
        # availability_zones: ["us-east-1a", "us-east-1b", "us-east-1c"]
        availability_zone_ids: ["use1-az4", "use1-az5", "use1-az6"]
        aws_ssm_agent_enabled: true
        allow_ingress_from_vpc_accounts:
          - tenant: core
            stage: auto
          - tenant: core
            stage: corp
          - tenant: core
            stage: network
        public_access_cidrs: []
        allowed_cidr_blocks: []
        allowed_security_groups: []
        enabled_cluster_log_types:
          # Caution: enabling `api` log events may lead to a substantial increase in Cloudwatch Logs expenses.
          - api
          - audit
          - authenticator
          - controllerManager
          - scheduler
        oidc_provider_enabled: true

        # Allows GitHub OIDC role
        github_actions_iam_role_enabled: true
        github_actions_iam_role_attributes: [ "eks" ]
        github_actions_allowed_repos:
          - acme/infra

        # We use karpenter to provision nodes
        # See below for using node_groups
        managed_node_groups_enabled: false
        node_groups: {}

        # EKS IAM Authentication settings
        # By default, you can authenticate to EKS cluster only by assuming the role that created the cluster.
        # After the Auth Config Map is applied, the other IAM roles in
        # `primary_iam_roles`, `delegated_iam_roles`, and `sso_iam_roles` will be able to authenticate.
        apply_config_map_aws_auth: true
        availability_zone_abbreviation_type: fixed
        cluster_private_subnets_only: true
        cluster_encryption_config_enabled: true
        cluster_endpoint_private_access: true
        cluster_endpoint_public_access: false
        cluster_log_retention_period: 90
        # List of `aws-teams` to map to Kubernetes RBAC groups.
        # This gives teams direct access to Kubernetes without having to assume a team-role.
        # RBAC groups must be created elsewhere. The "system:" groups are predefined by Kubernetes.
        aws_teams_rbac:
        - groups:
          - system:masters
          aws_team: admin
        - groups:
          - idp:poweruser
          - system:authenticated
          aws_team: poweruser
        - groups:
          - idp:observer
          - system:authenticated
          aws_team: observer
        # List of `aws-teams-roles` (in the account where the EKS cluster is deployed) to map to Kubernetes RBAC groups
        aws_team_roles_rbac:
        - groups:
          - system:masters
          aws_team_role: admin
        - groups:
          - idp:poweruser
          - system:authenticated
          aws_team_role: poweruser
        - groups:
          - idp:observer
          - system:authenticated
          aws_team_role: observer
        - groups:
          - system:masters
          aws_team_role: terraform
        - groups:
          - system:masters
          aws_team_role: helm
        # Permission sets from AWS SSO allowing cluster access
        # See `aws-sso` component.
        aws_sso_permission_sets_rbac:
        - aws_sso_permission_set: PowerUserAccess
          groups:
          - idp:poweruser
          - system:authenticated
        fargate_profiles:
          karpenter:
            kubernetes_namespace: karpenter
            kubernetes_labels: null
        karpenter_iam_role_enabled: true
```

### Usage with Node Groups

The `eks/cluster` component also supports managed node groups. In order to add a set list of nodes to
provision with the cluster, add values for `var.managed_node_groups_enabled` and `var.node_groups`.

:::info
You can use managed node groups in conjunction with Karpenter node groups, though in most cases,
Karpenter is all you need.

:::

For example:

```yaml
        managed_node_groups_enabled: true
        node_groups: # for most attributes, setting null here means use setting from node_group_defaults
          main:
            # availability_zones = null will create one autoscaling group
            # in every private subnet in the VPC
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
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.9.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.9.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eks"></a> [eks](#module\_eks) | cloudposse/stack-config/yaml//modules/remote-state | 1.4.1 |
| <a name="module_eks_cluster"></a> [eks\_cluster](#module\_eks\_cluster) | cloudposse/eks-cluster/aws | 2.6.0 |
| <a name="module_fargate_profile"></a> [fargate\_profile](#module\_fargate\_profile) | cloudposse/eks-fargate-profile/aws | 1.1.0 |
| <a name="module_iam_arns"></a> [iam\_arns](#module\_iam\_arns) | ../../account-map/modules/roles-to-principals | n/a |
| <a name="module_iam_roles"></a> [iam\_roles](#module\_iam\_roles) | ../../account-map/modules/iam-roles | n/a |
| <a name="module_karpenter_label"></a> [karpenter\_label](#module\_karpenter\_label) | cloudposse/label/null | 0.25.0 |
| <a name="module_region_node_group"></a> [region\_node\_group](#module\_region\_node\_group) | ./modules/node_group_by_region | n/a |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | cloudposse/stack-config/yaml//modules/remote-state | 1.4.1 |
| <a name="module_vpc_ingress"></a> [vpc\_ingress](#module\_vpc\_ingress) | cloudposse/stack-config/yaml//modules/remote-state | 1.4.1 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.ipv6_eks_cni_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.karpenter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.amazon_ec2_container_registry_readonly](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.amazon_eks_worker_node_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.amazon_ssm_managed_instance_core](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ipv6_eks_cni_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ipv6_eks_cni_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_roles.sso_roles](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_roles) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br>This is for some rare cases where resources want additional configuration of tags<br>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_addons"></a> [addons](#input\_addons) | Manages [`aws_eks_addon`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon) resources | <pre>list(object({<br>    addon_name               = string<br>    addon_version            = string<br>    resolve_conflicts        = string<br>    service_account_role_arn = string<br>  }))</pre> | `[]` | no |
| <a name="input_allow_ingress_from_vpc_accounts"></a> [allow\_ingress\_from\_vpc\_accounts](#input\_allow\_ingress\_from\_vpc\_accounts) | List of account contexts to pull VPC ingress CIDR and add to cluster security group.<br><br>e.g.<br><br>{<br>  environment = "ue2",<br>  stage       = "auto",<br>  tenant      = "core"<br>} | `any` | `[]` | no |
| <a name="input_allowed_cidr_blocks"></a> [allowed\_cidr\_blocks](#input\_allowed\_cidr\_blocks) | List of CIDR blocks to be allowed to connect to the EKS cluster | `list(string)` | `[]` | no |
| <a name="input_allowed_security_groups"></a> [allowed\_security\_groups](#input\_allowed\_security\_groups) | List of Security Group IDs to be allowed to connect to the EKS cluster | `list(string)` | `[]` | no |
| <a name="input_apply_config_map_aws_auth"></a> [apply\_config\_map\_aws\_auth](#input\_apply\_config\_map\_aws\_auth) | Whether to execute `kubectl apply` to apply the ConfigMap to allow worker nodes to join the EKS cluster | `bool` | `true` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br>in the order they appear in the list. New attributes are appended to the<br>end of the list. The elements of the list are joined by the `delimiter`<br>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_availability_zone_abbreviation_type"></a> [availability\_zone\_abbreviation\_type](#input\_availability\_zone\_abbreviation\_type) | Type of Availability Zone abbreviation (either `fixed` or `short`) to use in names. See https://github.com/cloudposse/terraform-aws-utils for details. | `string` | `"fixed"` | no |
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | AWS Availability Zones in which to deploy multi-AZ resources.<br>If not provided, resources will be provisioned in every private subnet in the VPC. | `list(string)` | `[]` | no |
| <a name="input_aws_auth_yaml_strip_quotes"></a> [aws\_auth\_yaml\_strip\_quotes](#input\_aws\_auth\_yaml\_strip\_quotes) | If true, remove double quotes from the generated aws-auth ConfigMap YAML to reduce spurious diffs in plans | `bool` | `true` | no |
| <a name="input_aws_ssm_agent_enabled"></a> [aws\_ssm\_agent\_enabled](#input\_aws\_ssm\_agent\_enabled) | Set true to attach the required IAM policy for AWS SSM agent to each EC2 instance's IAM Role | `bool` | `false` | no |
| <a name="input_aws_sso_permission_sets_rbac"></a> [aws\_sso\_permission\_sets\_rbac](#input\_aws\_sso\_permission\_sets\_rbac) | (Not Recommended): AWS SSO (IAM Identity Center) permission sets in the EKS deployment account to add to `aws-auth` ConfigMap.<br>Unfortunately, `aws-auth` ConfigMap does not support SSO permission sets, so we map the generated<br>IAM Role ARN corresponding to the permission set at the time Terraform runs. This is subject to change<br>when any changes are made to the AWS SSO configuration, invalidating the mapping, and requiring a<br>`terraform apply` in this project to update the `aws-auth` ConfigMap and restore access. | <pre>list(object({<br>    aws_sso_permission_set = string<br>    groups                 = list(string)<br>  }))</pre> | `[]` | no |
| <a name="input_aws_team_roles_rbac"></a> [aws\_team\_roles\_rbac](#input\_aws\_team\_roles\_rbac) | List of `aws-team-roles` (in the target AWSS account) to map to Kubernetes RBAC groups. | <pre>list(object({<br>    aws_team_role = string<br>    groups        = list(string)<br>  }))</pre> | `[]` | no |
| <a name="input_aws_teams_rbac"></a> [aws\_teams\_rbac](#input\_aws\_teams\_rbac) | List of `aws-teams` to map to Kubernetes RBAC groups.<br>This gives teams direct access to Kubernetes without having to assume a team-role. | <pre>list(object({<br>    aws_team = string<br>    groups   = list(string)<br>  }))</pre> | `[]` | no |
| <a name="input_cluster_encryption_config_enabled"></a> [cluster\_encryption\_config\_enabled](#input\_cluster\_encryption\_config\_enabled) | Set to `true` to enable Cluster Encryption Configuration | `bool` | `true` | no |
| <a name="input_cluster_encryption_config_kms_key_deletion_window_in_days"></a> [cluster\_encryption\_config\_kms\_key\_deletion\_window\_in\_days](#input\_cluster\_encryption\_config\_kms\_key\_deletion\_window\_in\_days) | Cluster Encryption Config KMS Key Resource argument - key deletion windows in days post destruction | `number` | `10` | no |
| <a name="input_cluster_encryption_config_kms_key_enable_key_rotation"></a> [cluster\_encryption\_config\_kms\_key\_enable\_key\_rotation](#input\_cluster\_encryption\_config\_kms\_key\_enable\_key\_rotation) | Cluster Encryption Config KMS Key Resource argument - enable kms key rotation | `bool` | `true` | no |
| <a name="input_cluster_encryption_config_kms_key_id"></a> [cluster\_encryption\_config\_kms\_key\_id](#input\_cluster\_encryption\_config\_kms\_key\_id) | KMS Key ID to use for cluster encryption config | `string` | `""` | no |
| <a name="input_cluster_encryption_config_kms_key_policy"></a> [cluster\_encryption\_config\_kms\_key\_policy](#input\_cluster\_encryption\_config\_kms\_key\_policy) | Cluster Encryption Config KMS Key Resource argument - key policy | `string` | `null` | no |
| <a name="input_cluster_encryption_config_resources"></a> [cluster\_encryption\_config\_resources](#input\_cluster\_encryption\_config\_resources) | Cluster Encryption Config Resources to encrypt, e.g. ['secrets'] | `list(any)` | <pre>[<br>  "secrets"<br>]</pre> | no |
| <a name="input_cluster_endpoint_private_access"></a> [cluster\_endpoint\_private\_access](#input\_cluster\_endpoint\_private\_access) | Indicates whether or not the Amazon EKS private API server endpoint is enabled. Default to AWS EKS resource and it is `false` | `bool` | `false` | no |
| <a name="input_cluster_endpoint_public_access"></a> [cluster\_endpoint\_public\_access](#input\_cluster\_endpoint\_public\_access) | Indicates whether or not the Amazon EKS public API server endpoint is enabled. Default to AWS EKS resource and it is `true` | `bool` | `true` | no |
| <a name="input_cluster_kubernetes_version"></a> [cluster\_kubernetes\_version](#input\_cluster\_kubernetes\_version) | Desired Kubernetes master version. If you do not specify a value, the latest available version is used | `string` | `null` | no |
| <a name="input_cluster_log_retention_period"></a> [cluster\_log\_retention\_period](#input\_cluster\_log\_retention\_period) | Number of days to retain cluster logs. Requires `enabled_cluster_log_types` to be set. See https://docs.aws.amazon.com/en_us/eks/latest/userguide/control-plane-logs.html. | `number` | `0` | no |
| <a name="input_cluster_private_subnets_only"></a> [cluster\_private\_subnets\_only](#input\_cluster\_private\_subnets\_only) | Whether or not to enable private subnets or both public and private subnets | `bool` | `false` | no |
| <a name="input_color"></a> [color](#input\_color) | The cluster stage represented by a color; e.g. blue, green | `string` | `""` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "descriptor_formats": {},<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "labels_as_tags": [<br>    "unset"<br>  ],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {},<br>  "tenant": null<br>}</pre> | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br>Map of maps. Keys are names of descriptors. Values are maps of the form<br>`{<br>   format = string<br>   labels = list(string)<br>}`<br>(Type is `any` so the map values can later be enhanced to provide additional options.)<br>`format` is a Terraform format string to be passed to the `format()` function.<br>`labels` is a list of labels, in order, to pass to `format()` function.<br>Label values will be normalized before being passed to `format()` so they will be<br>identical to how they appear in `id`.<br>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_eks_component_name"></a> [eks\_component\_name](#input\_eks\_component\_name) | The name of the eks component | `string` | `"eks/cluster"` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_enabled_cluster_log_types"></a> [enabled\_cluster\_log\_types](#input\_enabled\_cluster\_log\_types) | A list of the desired control plane logging to enable. For more information, see https://docs.aws.amazon.com/en_us/eks/latest/userguide/control-plane-logs.html. Possible values [`api`, `audit`, `authenticator`, `controllerManager`, `scheduler`] | `list(string)` | `[]` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_fargate_profile_iam_role_kubernetes_namespace_delimiter"></a> [fargate\_profile\_iam\_role\_kubernetes\_namespace\_delimiter](#input\_fargate\_profile\_iam\_role\_kubernetes\_namespace\_delimiter) | Delimiter for the Kubernetes namespace in the IAM Role name for Fargate Profiles | `string` | `"-"` | no |
| <a name="input_fargate_profile_iam_role_permissions_boundary"></a> [fargate\_profile\_iam\_role\_permissions\_boundary](#input\_fargate\_profile\_iam\_role\_permissions\_boundary) | If provided, all Fargate Profiles IAM roles will be created with this permissions boundary attached | `string` | `null` | no |
| <a name="input_fargate_profiles"></a> [fargate\_profiles](#input\_fargate\_profiles) | Fargate Profiles config | <pre>map(object({<br>    kubernetes_namespace = string<br>    kubernetes_labels    = map(string)<br>  }))</pre> | `{}` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for keep the existing setting, which defaults to `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_import_role_arn"></a> [import\_role\_arn](#input\_import\_role\_arn) | IAM Role ARN to use when importing a resource | `string` | `null` | no |
| <a name="input_karpenter_iam_role_enabled"></a> [karpenter\_iam\_role\_enabled](#input\_karpenter\_iam\_role\_enabled) | Flag to enable/disable creation of IAM role for EC2 Instance Profile that is attached to the nodes launched by Karpenter | `bool` | `false` | no |
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
| <a name="input_node_group_defaults"></a> [node\_group\_defaults](#input\_node\_group\_defaults) | Defaults for node groups in the cluster | <pre>object({<br>    ami_release_version        = string<br>    ami_type                   = string<br>    attributes                 = list(string)<br>    availability_zones         = list(string) # set to null to use var.availability_zones<br>    cluster_autoscaler_enabled = bool<br>    create_before_destroy      = bool<br>    desired_group_size         = number<br>    disk_encryption_enabled    = bool<br>    disk_size                  = number<br>    instance_types             = list(string)<br>    kubernetes_labels          = map(string)<br>    kubernetes_taints = list(object({<br>      key    = string<br>      value  = string<br>      effect = string<br>    }))<br>    kubernetes_version = string # set to null to use cluster_kubernetes_version<br>    max_group_size     = number<br>    min_group_size     = number<br>    resources_to_tag   = list(string)<br>    tags               = map(string)<br>  })</pre> | <pre>{<br>  "ami_release_version": null,<br>  "ami_type": null,<br>  "attributes": null,<br>  "availability_zones": null,<br>  "cluster_autoscaler_enabled": true,<br>  "create_before_destroy": true,<br>  "desired_group_size": 1,<br>  "disk_encryption_enabled": true,<br>  "disk_size": 20,<br>  "instance_types": [<br>    "t3.medium"<br>  ],<br>  "kubernetes_labels": null,<br>  "kubernetes_taints": null,<br>  "kubernetes_version": null,<br>  "max_group_size": 100,<br>  "min_group_size": null,<br>  "resources_to_tag": null,<br>  "tags": null<br>}</pre> | no |
| <a name="input_node_groups"></a> [node\_groups](#input\_node\_groups) | List of objects defining a node group for the cluster | <pre>map(object({<br>    # EKS AMI version to use, e.g. "1.16.13-20200821" (no "v").<br>    ami_release_version = string<br>    # Type of Amazon Machine Image (AMI) associated with the EKS Node Group<br>    ami_type = string<br>    # Additional attributes (e.g. `1`) for the node group<br>    attributes = list(string)<br>    # will create 1 auto scaling group in each specified availability zone<br>    availability_zones = list(string)<br>    # Whether to enable Node Group to scale its AutoScaling Group<br>    cluster_autoscaler_enabled = bool<br>    # True to create new node_groups before deleting old ones, avoiding a temporary outage<br>    create_before_destroy = bool<br>    # Desired number of worker nodes when initially provisioned<br>    desired_group_size = number<br>    # Enable disk encryption for the created launch template (if we aren't provided with an existing launch template)<br>    disk_encryption_enabled = bool<br>    # Disk size in GiB for worker nodes. Terraform will only perform drift detection if a configuration value is provided.<br>    disk_size = number<br>    # Set of instance types associated with the EKS Node Group. Terraform will only perform drift detection if a configuration value is provided.<br>    instance_types = list(string)<br>    # Key-value mapping of Kubernetes labels. Only labels that are applied with the EKS API are managed by this argument. Other Kubernetes labels applied to the EKS Node Group will not be managed<br>    kubernetes_labels = map(string)<br>    # List of objects describing Kubernetes taints.<br>    kubernetes_taints = list(object({<br>      key    = string<br>      value  = string<br>      effect = string<br>    }))<br>    # Desired Kubernetes master version. If you do not specify a value, the latest available version is used<br>    kubernetes_version = string<br>    # The maximum size of the AutoScaling Group<br>    max_group_size = number<br>    # The minimum size of the AutoScaling Group<br>    min_group_size = number<br>    # List of auto-launched resource types to tag<br>    resources_to_tag = list(string)<br>    tags             = map(string)<br>  }))</pre> | `{}` | no |
| <a name="input_oidc_provider_enabled"></a> [oidc\_provider\_enabled](#input\_oidc\_provider\_enabled) | Create an IAM OIDC identity provider for the cluster, then you can create IAM roles to associate with a service account in the cluster, instead of using kiam or kube2iam. For more information, see https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html | `bool` | n/a | yes |
| <a name="input_public_access_cidrs"></a> [public\_access\_cidrs](#input\_public\_access\_cidrs) | Indicates which CIDR blocks can access the Amazon EKS public API server endpoint when enabled. EKS defaults this to a list with 0.0.0.0/0. | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
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
| <a name="output_fargate_profile_role_arns"></a> [fargate\_profile\_role\_arns](#output\_fargate\_profile\_role\_arns) | Fargate Profile Role ARNs |
| <a name="output_fargate_profile_role_names"></a> [fargate\_profile\_role\_names](#output\_fargate\_profile\_role\_names) | Fargate Profile Role names |
| <a name="output_fargate_profiles"></a> [fargate\_profiles](#output\_fargate\_profiles) | Fargate Profiles |
| <a name="output_karpenter_iam_role_arn"></a> [karpenter\_iam\_role\_arn](#output\_karpenter\_iam\_role\_arn) | Karpenter IAM Role ARN |
| <a name="output_karpenter_iam_role_name"></a> [karpenter\_iam\_role\_name](#output\_karpenter\_iam\_role\_name) | Karpenter IAM Role name |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Related How-to Guides

- [How to Load Test in AWS](/reference-architecture/how-to-guides/tutorials/how-to-load-test-in-aws)
- [How to Tune EKS with AWS Managed Node Groups](/reference-architecture/how-to-guides/tutorials/how-to-tune-eks-with-aws-managed-node-groups)
- [How to Keep Everything Up to Date](/reference-architecture/how-to-guides/upgrades/how-to-keep-everything-up-to-date)
- [How to Tune SpotInst Parameters for EKS](/reference-architecture/how-to-guides/tutorials/how-to-tune-spotinst-parameters-for-eks)
- [How to Upgrade EKS Cluster Addons](/reference-architecture/how-to-guides/upgrades/how-to-upgrade-eks-cluster-addons)
- [How to Upgrade EKS](/reference-architecture/how-to-guides/upgrades/how-to-upgrade-eks)

## References

- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/master/modules/eks/cluster) - Cloud Posse's upstream component

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
