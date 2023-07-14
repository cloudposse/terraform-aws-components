variable "region" {
  type        = string
  description = "AWS Region"
}

variable "availability_zones" {
  type        = list(string)
  description = <<-EOT
    AWS Availability Zones in which to deploy multi-AZ resources.
    If not provided, resources will be provisioned in every zone with a private subnet in the VPC.
    EOT
  default     = []
  nullable    = false
}

variable "availability_zone_abbreviation_type" {
  type        = string
  description = "Type of Availability Zone abbreviation (either `fixed` or `short`) to use in names. See https://github.com/cloudposse/terraform-aws-utils for details."
  default     = "fixed"
  nullable    = false

  validation {
    condition     = contains(["fixed", "short"], var.availability_zone_abbreviation_type)
    error_message = "The availability_zone_abbreviation_type must be either \"fixed\" or \"short\"."
  }
}

variable "managed_node_groups_enabled" {
  type        = bool
  description = "Set false to prevent the creation of EKS managed node groups."
  default     = true
  nullable    = false
}

variable "oidc_provider_enabled" {
  type        = bool
  description = "Create an IAM OIDC identity provider for the cluster, then you can create IAM roles to associate with a service account in the cluster, instead of using kiam or kube2iam. For more information, see https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html"
  default     = true
  nullable    = false
}

variable "cluster_endpoint_private_access" {
  type        = bool
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled. Default to AWS EKS resource and it is `false`"
  default     = false
  nullable    = false
}

variable "cluster_endpoint_public_access" {
  type        = bool
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled. Default to AWS EKS resource and it is `true`"
  default     = true
  nullable    = false
}

variable "cluster_kubernetes_version" {
  type        = string
  description = "Desired Kubernetes master version. If you do not specify a value, the latest available version is used"
  default     = null
}

variable "public_access_cidrs" {
  type        = list(string)
  description = "Indicates which CIDR blocks can access the Amazon EKS public API server endpoint when enabled. EKS defaults this to a list with 0.0.0.0/0."
  default     = ["0.0.0.0/0"]
  nullable    = false
}

variable "enabled_cluster_log_types" {
  type        = list(string)
  description = "A list of the desired control plane logging to enable. For more information, see https://docs.aws.amazon.com/en_us/eks/latest/userguide/control-plane-logs.html. Possible values [`api`, `audit`, `authenticator`, `controllerManager`, `scheduler`]"
  default     = []
  nullable    = false
}

variable "cluster_log_retention_period" {
  type        = number
  description = "Number of days to retain cluster logs. Requires `enabled_cluster_log_types` to be set. See https://docs.aws.amazon.com/en_us/eks/latest/userguide/control-plane-logs.html."
  default     = 0
  nullable    = false
}

variable "apply_config_map_aws_auth" {
  type        = bool
  description = "Whether to execute `kubectl apply` to apply the ConfigMap to allow worker nodes to join the EKS cluster"
  default     = true
  nullable    = false
}

variable "map_additional_aws_accounts" {
  type        = list(string)
  description = "Additional AWS account numbers to add to `aws-auth` ConfigMap"
  default     = []
  nullable    = false
}

variable "map_additional_worker_roles" {
  type        = list(string)
  description = "AWS IAM Role ARNs of worker nodes to add to `aws-auth` ConfigMap"
  default     = []
  nullable    = false
}

variable "aws_teams_rbac" {
  type = list(object({
    aws_team = string
    groups   = list(string)
  }))

  description = <<-EOT
    List of `aws-teams` to map to Kubernetes RBAC groups.
    This gives teams direct access to Kubernetes without having to assume a team-role.
    EOT

  default  = []
  nullable = false
}

variable "aws_team_roles_rbac" {
  type = list(object({
    aws_team_role = string
    groups        = list(string)
  }))

  description = "List of `aws-team-roles` (in the target AWS account) to map to Kubernetes RBAC groups."
  default     = []
  nullable    = false
}

variable "aws_sso_permission_sets_rbac" {
  type = list(object({
    aws_sso_permission_set = string
    groups                 = list(string)
  }))

  description = <<-EOT
    (Not Recommended): AWS SSO (IAM Identity Center) permission sets in the EKS deployment account to add to `aws-auth` ConfigMap.
    Unfortunately, `aws-auth` ConfigMap does not support SSO permission sets, so we map the generated
    IAM Role ARN corresponding to the permission set at the time Terraform runs. This is subject to change
    when any changes are made to the AWS SSO configuration, invalidating the mapping, and requiring a
    `terraform apply` in this project to update the `aws-auth` ConfigMap and restore access.
    EOT

  default  = []
  nullable = false
}

variable "map_additional_iam_roles" {
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))

  description = "Additional IAM roles to add to `config-map-aws-auth` ConfigMap"
  default     = []
  nullable    = false
}

variable "map_additional_iam_users" {
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))

  description = "Additional IAM users to add to `aws-auth` ConfigMap"
  default     = []
  nullable    = false
}

variable "allowed_security_groups" {
  type        = list(string)
  description = "List of Security Group IDs to be allowed to connect to the EKS cluster"
  default     = []
  nullable    = false
}

variable "allowed_cidr_blocks" {
  type        = list(string)
  description = "List of CIDR blocks to be allowed to connect to the EKS cluster"
  default     = []
  nullable    = false
}

variable "subnet_type_tag_key" {
  type        = string
  description = "The tag used to find the private subnets to find by availability zone. If null, will be looked up in vpc outputs."
  default     = null
}

variable "color" {
  type        = string
  description = "The cluster stage represented by a color; e.g. blue, green"
  default     = ""
  nullable    = false
}

variable "node_groups" {
  # will create 1 node group for each item in map
  type = map(object({
    # EKS AMI version to use, e.g. "1.16.13-20200821" (no "v").
    ami_release_version = string
    # Type of Amazon Machine Image (AMI) associated with the EKS Node Group
    ami_type = string
    # Additional attributes (e.g. `1`) for the node group
    attributes = list(string)
    # will create 1 auto scaling group in each specified availability zone
    # or all AZs with subnets if none are specified anywhere
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

  description = "List of objects defining a node group for the cluster"
  default     = {}
  nullable    = false
}

variable "node_group_defaults" {
  # Any value in the node group that is null will be replaced
  # by the value in this object, which can also be null
  type = object({
    ami_release_version        = string
    ami_type                   = string
    attributes                 = list(string)
    availability_zones         = list(string) # set to null to use var.availability_zones
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

  description = "Defaults for node groups in the cluster"

  default = {
    ami_release_version        = null
    ami_type                   = null
    attributes                 = null
    availability_zones         = null
    cluster_autoscaler_enabled = true
    create_before_destroy      = true
    desired_group_size         = 1
    disk_encryption_enabled    = true
    disk_size                  = 20
    instance_types             = ["t3.medium"]
    kubernetes_labels          = null
    kubernetes_taints          = null
    kubernetes_version         = null # set to null to use cluster_kubernetes_version
    max_group_size             = 100
    min_group_size             = null
    resources_to_tag           = null
    tags                       = null
  }
  nullable = false
}

variable "cluster_encryption_config_enabled" {
  type        = bool
  description = "Set to `true` to enable Cluster Encryption Configuration"
  default     = true
  nullable    = false
}

variable "cluster_encryption_config_kms_key_id" {
  type        = string
  description = "KMS Key ID to use for cluster encryption config"
  default     = ""
  nullable    = false
}

variable "cluster_encryption_config_kms_key_enable_key_rotation" {
  type        = bool
  description = "Cluster Encryption Config KMS Key Resource argument - enable kms key rotation"
  default     = true
  nullable    = false
}

variable "cluster_encryption_config_kms_key_deletion_window_in_days" {
  type        = number
  description = "Cluster Encryption Config KMS Key Resource argument - key deletion windows in days post destruction"
  default     = 10
  nullable    = false
}

variable "cluster_encryption_config_kms_key_policy" {
  type        = string
  description = "Cluster Encryption Config KMS Key Resource argument - key policy"
  default     = null
}

variable "cluster_encryption_config_resources" {
  type        = list(string)
  description = "Cluster Encryption Config Resources to encrypt, e.g. `[\"secrets\"]`"
  default     = ["secrets"]
  nullable    = false
}

variable "aws_ssm_agent_enabled" {
  type        = bool
  description = "Set true to attach the required IAM policy for AWS SSM agent to each EC2 instance's IAM Role"
  default     = false
  nullable    = false
}

variable "kubeconfig_file" {
  type        = string
  description = "Name of `kubeconfig` file to use to configure Kubernetes provider"
  default     = ""
}

variable "kubeconfig_file_enabled" {
  type = bool

  description = <<-EOF
    Set true to configure Kubernetes provider with a `kubeconfig` file specified by `kubeconfig_file`.
    Mainly for when the standard configuration produces a Terraform error.
    EOF

  default  = false
  nullable = false
}

variable "kube_exec_auth_role_arn" {
  type        = string
  description = "The role ARN for `aws eks get-token` to use. Defaults to the current caller's role."
  default     = null
}

variable "aws_auth_yaml_strip_quotes" {
  type        = bool
  description = "If true, remove double quotes from the generated aws-auth ConfigMap YAML to reduce spurious diffs in plans"
  default     = true
  nullable    = false
}

variable "cluster_private_subnets_only" {
  type        = bool
  description = "Whether or not to enable private subnets or both public and private subnets"
  default     = false
  nullable    = false
}

variable "allow_ingress_from_vpc_accounts" {
  type = any

  description = <<-EOF
    List of account contexts to pull VPC ingress CIDR and add to cluster security group.

    e.g.

    {
      environment = "ue2",
      stage       = "auto",
      tenant      = "core"
    }
  EOF

  default  = []
  nullable = false
}

variable "eks_component_name" {
  type        = string
  description = "The name of the eks component"
  default     = "eks/cluster"
  nullable    = false
}

variable "vpc_component_name" {
  type        = string
  description = "The name of the vpc component"
  default     = "vpc"
  nullable    = false
}

variable "karpenter_iam_role_enabled" {
  type        = bool
  description = "Flag to enable/disable creation of IAM role for EC2 Instance Profile that is attached to the nodes launched by Karpenter"
  default     = false
  nullable    = false
}

variable "fargate_profiles" {
  type = map(object({
    kubernetes_namespace = string
    kubernetes_labels    = map(string)
  }))

  description = "Fargate Profiles config"
  default     = {}
  nullable    = false
}

variable "fargate_profile_iam_role_kubernetes_namespace_delimiter" {
  type        = string
  description = "Delimiter for the Kubernetes namespace in the IAM Role name for Fargate Profiles"
  default     = "-"
  nullable    = false
}

variable "fargate_profile_iam_role_permissions_boundary" {
  type        = string
  description = "If provided, all Fargate Profiles IAM roles will be created with this permissions boundary attached"
  default     = null
}

variable "addons" {
  type = map(object({
    addon_version        = optional(string, null)
    configuration_values = optional(string, null)
    # Set default resolve_conflicts to OVERWRITE because it is required on initial installation of
    # add-ons that have self-managed versions installed by default (e.g. vpc-cni, coredns), and
    # because any custom configuration that you would want to preserve should be managed by Terraform.
    resolve_conflicts        = optional(string, "OVERWRITE")
    service_account_role_arn = optional(string, null)
    create_timeout           = optional(string, null)
    update_timeout           = optional(string, null)
    delete_timeout           = optional(string, null)
  }))

  description = "Manages [EKS addons](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon) resources"
  default     = {}
  nullable    = false
}

variable "deploy_addons_to_fargate" {
  type        = bool
  description = "Set to `true` to deploy addons to Fargate instead of initial node pool"
  default     = true
  nullable    = false
}

variable "addons_depends_on" {
  type = bool

  description = <<-EOT
    If set `true`, all addons will depend on managed node groups provisioned by this component and therefore not be installed until nodes are provisioned.
    See [issue #170](https://github.com/cloudposse/terraform-aws-eks-cluster/issues/170) for more details.
    EOT

  default  = false
  nullable = false
}

variable "legacy_fargate_1_role_per_profile_enabled" {
  type        = bool
  description = <<-EOT
    Set to `false` for new clusters to create a single Fargate Pod Execution role for the cluster.
    Set to `true` for existing clusters to preserve the old behavior of creating
    a Fargate Pod Execution role for each Fargate Profile.
    EOT
  default     = true
  nullable    = false
}
