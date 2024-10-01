variable "region" {
  type        = string
  description = "AWS Region"
}

variable "availability_zones" {
  type        = list(string)
  description = <<-EOT
    AWS Availability Zones in which to deploy multi-AZ resources.
    Ignored if `availability_zone_ids` is set.
    Can be the full name, e.g. `us-east-1a`, or just the part after the region, e.g. `a` to allow reusable values across regions.
    If not provided, resources will be provisioned in every zone with a private subnet in the VPC.
    EOT
  default     = []
  nullable    = false
}

variable "availability_zone_ids" {
  type        = list(string)
  description = <<-EOT
    List of Availability Zones IDs where subnets will be created. Overrides `availability_zones`.
    Can be the full name, e.g. `use1-az1`, or just the part after the AZ ID region code, e.g. `-az1`,
    to allow reusable values across regions. Consider contention for resources and spot pricing in each AZ when selecting.
    Useful in some regions when using only some AZs and you want to use the same ones across multiple accounts.
    EOT
  default     = []
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

# TODO:
# - Support EKS Access Policies
# - Support namespaced access limits
# - Support roles from other accounts
# - Either combine with Permission Sets or similarly enhance Permission Set support
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

# TODO:
# - Support EKS Access Policies
# - Support namespaced access limits
# - Combine with`map_additional_iam_users` into new input
variable "map_additional_iam_roles" {
  type = list(object({
    rolearn  = string
    username = optional(string)
    groups   = list(string)
  }))

  description = <<-EOT
    Additional IAM roles to grant access to the cluster.
    *WARNING*: Full Role ARN, including path, is required for `rolearn`.
    In earlier versions (with `aws-auth` ConfigMap), only the path
    had to be removed from the Role ARN. The path is now required.
    `username` is now ignored. This input is planned to be replaced
    in a future release with a more flexible input structure that consolidates
    `map_additional_iam_roles` and `map_additional_iam_users`.
    EOT
  default     = []
  nullable    = false
}

variable "map_additional_iam_users" {
  type = list(object({
    userarn  = string
    username = optional(string)
    groups   = list(string)
  }))

  description = <<-EOT
    Additional IAM roles to grant access to the cluster.
    `username` is now ignored. This input is planned to be replaced
    in a future release with a more flexible input structure that consolidates
    `map_additional_iam_roles` and `map_additional_iam_users`.
    EOT
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
    ami_release_version = optional(string, null)
    # Type of Amazon Machine Image (AMI) associated with the EKS Node Group
    ami_type = optional(string, null)
    # Additional attributes (e.g. `1`) for the node group
    attributes = optional(list(string), null)
    # will create 1 auto scaling group in each specified availability zone
    # or all AZs with subnets if none are specified anywhere
    availability_zones = optional(list(string), null)
    # Whether to enable Node Group to scale its AutoScaling Group
    cluster_autoscaler_enabled = optional(bool, null)
    # True to create new node_groups before deleting old ones, avoiding a temporary outage
    create_before_destroy = optional(bool, null)
    # Desired number of worker nodes when initially provisioned
    desired_group_size = optional(number, null)
    # Set of instance types associated with the EKS Node Group. Terraform will only perform drift detection if a configuration value is provided.
    instance_types = optional(list(string), null)
    # Key-value mapping of Kubernetes labels. Only labels that are applied with the EKS API are managed by this argument. Other Kubernetes labels applied to the EKS Node Group will not be managed
    kubernetes_labels = optional(map(string), null)
    # List of objects describing Kubernetes taints.
    kubernetes_taints = optional(list(object({
      key    = string
      value  = string
      effect = string
    })), null)
    node_userdata = optional(object({
      before_cluster_joining_userdata = optional(string)
      bootstrap_extra_args            = optional(string)
      kubelet_extra_args              = optional(string)
      after_cluster_joining_userdata  = optional(string)
    }), {})
    # Desired Kubernetes master version. If you do not specify a value, the latest available version is used
    kubernetes_version = optional(string, null)
    # The maximum size of the AutoScaling Group
    max_group_size = optional(number, null)
    # The minimum size of the AutoScaling Group
    min_group_size = optional(number, null)
    # List of auto-launched resource types to tag
    resources_to_tag = optional(list(string), null)
    tags             = optional(map(string), null)

    # block_device_map copied from cloudposse/terraform-aws-eks-node-group
    # Keep in sync via copy and paste, but make optional.
    # Most of the time you want "/dev/xvda". For BottleRocket, use "/dev/xvdb".
    block_device_map = optional(map(object({
      no_device    = optional(bool, null)
      virtual_name = optional(string, null)
      ebs = optional(object({
        delete_on_termination = optional(bool, true)
        encrypted             = optional(bool, true)
        iops                  = optional(number, null)
        kms_key_id            = optional(string, null)
        snapshot_id           = optional(string, null)
        throughput            = optional(number, null) # for gp3, MiB/s, up to 1000
        volume_size           = optional(number, 20)   # Disk size in GB
        volume_type           = optional(string, "gp3")

        # Catch common camel case typos. These have no effect, they just generate better errors.
        # It would be nice to actually use these, but volumeSize in particular is a number here
        # and in most places it is a string with a unit suffix (e.g. 20Gi)
        # Without these defined, they would be silently ignored and the default values would be used instead,
        # which is difficult to debug.
        deleteOnTermination = optional(any, null)
        kmsKeyId            = optional(any, null)
        snapshotId          = optional(any, null)
        volumeSize          = optional(any, null)
        volumeType          = optional(any, null)
      }))
    })), null)

    # DEPRECATED:
    # Enable disk encryption for the created launch template (if we aren't provided with an existing launch template)
    # DEPRECATED: disk_encryption_enabled is DEPRECATED, use `block_device_map` instead.
    disk_encryption_enabled = optional(bool, null)
    # Disk size in GiB for worker nodes. Terraform will only perform drift detection if a configuration value is provided.
    # DEPRECATED: disk_size is DEPRECATED, use `block_device_map` instead.
    disk_size = optional(number, null)

  }))

  description = "List of objects defining a node group for the cluster"
  default     = {}
  nullable    = false
}

variable "node_group_defaults" {
  # Any value in the node group that is null will be replaced
  # by the value in this object, which can also be null
  type = object({
    ami_release_version        = optional(string, null)
    ami_type                   = optional(string, null)
    attributes                 = optional(list(string), null)
    availability_zones         = optional(list(string)) # set to null to use var.availability_zones
    cluster_autoscaler_enabled = optional(bool, null)
    create_before_destroy      = optional(bool, null)
    desired_group_size         = optional(number, null)
    instance_types             = optional(list(string), null)
    kubernetes_labels          = optional(map(string), {})
    kubernetes_taints = optional(list(object({
      key    = string
      value  = string
      effect = string
    })), [])
    node_userdata = optional(object({
      before_cluster_joining_userdata = optional(string)
      bootstrap_extra_args            = optional(string)
      kubelet_extra_args              = optional(string)
      after_cluster_joining_userdata  = optional(string)
    }), {})
    kubernetes_version = optional(string, null) # set to null to use cluster_kubernetes_version
    max_group_size     = optional(number, null)
    min_group_size     = optional(number, null)
    resources_to_tag   = optional(list(string), null)
    tags               = optional(map(string), null)

    # block_device_map copied from cloudposse/terraform-aws-eks-node-group
    # Keep in sync via copy and paste, but make optional
    # Most of the time you want "/dev/xvda". For BottleRocket, use "/dev/xvdb".
    block_device_map = optional(map(object({
      no_device    = optional(bool, null)
      virtual_name = optional(string, null)
      ebs = optional(object({
        delete_on_termination = optional(bool, true)
        encrypted             = optional(bool, true)
        iops                  = optional(number, null)
        kms_key_id            = optional(string, null)
        snapshot_id           = optional(string, null)
        throughput            = optional(number, null) # for gp3, MiB/s, up to 1000
        volume_size           = optional(number, 50)   # disk  size in GB
        volume_type           = optional(string, "gp3")

        # Catch common camel case typos. These have no effect, they just generate better errors.
        # It would be nice to actually use these, but volumeSize in particular is a number here
        # and in most places it is a string with a unit suffix (e.g. 20Gi)
        # Without these defined, they would be silently ignored and the default values would be used instead,
        # which is difficult to debug.
        deleteOnTermination = optional(any, null)
        kmsKeyId            = optional(any, null)
        snapshotId          = optional(any, null)
        volumeSize          = optional(any, null)
        volumeType          = optional(any, null)
      }))
    })), null)

    # DEPRECATED: disk_encryption_enabled is DEPRECATED, use `block_device_map` instead.
    disk_encryption_enabled = optional(bool, null)
    # DEPRECATED: disk_size is DEPRECATED, use `block_device_map` instead.
    disk_size = optional(number, null)
  })

  description = "Defaults for node groups in the cluster"

  default = {
    desired_group_size = 1
    # t3.medium is kept as the default for backward compatibility.
    # Recommendation as of 2023-08-08 is c6a.large to provide reserve HA capacity regardless of Karpenter behavior.
    instance_types     = ["t3.medium"]
    kubernetes_version = null # set to null to use cluster_kubernetes_version
    max_group_size     = 100

    block_device_map = {
      "/dev/xvda" = {
        ebs = {
          encrypted   = true
          volume_size = 20    # GB
          volume_type = "gp2" # Should be gp3, but left as gp2 for backwards compatibility
        }
      }
    }
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
    enabled       = optional(bool, true)
    addon_version = optional(string, null)
    # configuration_values is a JSON string, such as '{"computeType": "Fargate"}'.
    configuration_values = optional(string, null)
    # Set default resolve_conflicts to OVERWRITE because it is required on initial installation of
    # add-ons that have self-managed versions installed by default (e.g. vpc-cni, coredns), and
    # because any custom configuration that you would want to preserve should be managed by Terraform.
    resolve_conflicts_on_create = optional(string, "OVERWRITE")
    resolve_conflicts_on_update = optional(string, "OVERWRITE")
    service_account_role_arn    = optional(string, null)
    create_timeout              = optional(string, null)
    update_timeout              = optional(string, null)
    delete_timeout              = optional(string, null)
  }))

  description = "Manages [EKS addons](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon) resources"
  default     = {}
  nullable    = false
}

variable "deploy_addons_to_fargate" {
  type        = bool
  description = "Set to `true` (not recommended) to deploy addons to Fargate instead of initial node pool"
  default     = false
  nullable    = false
}

variable "addons_depends_on" {
  type = bool

  description = <<-EOT
    If set `true` (recommended), all addons will depend on managed node groups provisioned by this component and therefore not be installed until nodes are provisioned.
    See [issue #170](https://github.com/cloudposse/terraform-aws-eks-cluster/issues/170) for more details.
    EOT

  default  = true
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

variable "legacy_do_not_create_karpenter_instance_profile" {
  type        = bool
  description = <<-EOT
    **Obsolete:** The issues this was meant to mitigate were fixed in AWS Terraform Provider v5.43.0
    and Karpenter v0.33.0. This variable will be removed in a future release.
    Remove this input from your configuration and leave it at default.
    **Old description:** When `true` (the default), suppresses creation of the IAM Instance Profile
    for nodes launched by Karpenter, to preserve the legacy behavior of
    the `eks/karpenter` component creating it.
    Set to `false` to enable creation of the IAM Instance Profile, which
    ensures that both the role and the instance profile have the same lifecycle,
    and avoids AWS Provider issue [#32671](https://github.com/hashicorp/terraform-provider-aws/issues/32671).
    Use in conjunction with `eks/karpenter` component `legacy_create_karpenter_instance_profile`.
    EOT
  default     = true
}

variable "access_config" {
  type = object({
    authentication_mode                         = optional(string, "API")
    bootstrap_cluster_creator_admin_permissions = optional(bool, false)
  })
  description = "Access configuration for the EKS cluster"
  default     = {}
  nullable    = false

  validation {
    condition     = !contains(["CONFIG_MAP"], var.access_config.authentication_mode)
    error_message = "The CONFIG_MAP authentication_mode is not supported."
  }
}
