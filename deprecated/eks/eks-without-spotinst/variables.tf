variable "region" {
  type        = string
  description = "AWS Region"
}

variable "availability_zones" {
  type        = list(string)
  description = "AWS Availability Zones in which to deploy multi-AZ resources"
}

variable "availability_zone_abbreviation_type" {
  type        = string
  description = "Type of Availability Zone abbreviation (either `fixed` or `short`) to use in names. See https://github.com/cloudposse/terraform-aws-utils for details."
  default     = "fixed"
  validation {
    condition     = contains(["fixed", "short"], var.availability_zone_abbreviation_type)
    error_message = "The availability_zone_abbreviation_type must be either \"fixed\" or \"short\"."
  }
}

variable "managed_node_groups_enabled" {
  type        = bool
  description = "Set false to prevent the creation of EKS managed node groups."
  default     = true
}

variable "oidc_provider_enabled" {
  type        = bool
  description = "Create an IAM OIDC identity provider for the cluster, then you can create IAM roles to associate with a service account in the cluster, instead of using kiam or kube2iam. For more information, see https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html"
}

variable "cluster_endpoint_private_access" {
  type        = bool
  default     = false
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled. Default to AWS EKS resource and it is `false`"
}

variable "cluster_endpoint_public_access" {
  type        = bool
  default     = true
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled. Default to AWS EKS resource and it is `true`"
}

variable "cluster_kubernetes_version" {
  type        = string
  default     = null
  description = "Desired Kubernetes master version. If you do not specify a value, the latest available version is used"
}

variable "public_access_cidrs" {
  type        = list(string)
  default     = []
  description = "Indicates which CIDR blocks can access the Amazon EKS public API server endpoint when enabled. EKS defaults this to a list with 0.0.0.0/0."
}

variable "enabled_cluster_log_types" {
  type        = list(string)
  default     = []
  description = "A list of the desired control plane logging to enable. For more information, see https://docs.aws.amazon.com/en_us/eks/latest/userguide/control-plane-logs.html. Possible values [`api`, `audit`, `authenticator`, `controllerManager`, `scheduler`]"
}

variable "cluster_log_retention_period" {
  type        = number
  default     = 90
  description = "Number of days to retain cluster logs. Requires `enabled_cluster_log_types` to be set. See https://docs.aws.amazon.com/en_us/eks/latest/userguide/control-plane-logs.html."
}

variable "apply_config_map_aws_auth" {
  type        = bool
  default     = true
  description = "Whether to execute `kubectl apply` to apply the ConfigMap to allow worker nodes to join the EKS cluster"
}

variable "map_additional_aws_accounts" {
  description = "Additional AWS account numbers to add to `aws-auth` ConfigMap"
  type        = list(string)
  default     = []
}

variable "map_additional_worker_roles" {
  description = "AWS IAM Role ARNs of worker nodes to add to `aws-auth` ConfigMap"
  type        = list(string)
  default     = []
}

variable "primary_iam_roles" {
  description = "Primary IAM roles to add to `aws-auth` ConfigMap"

  type = list(object({
    role   = string
    groups = list(string)
  }))

  default = []
}

variable "delegated_iam_roles" {
  description = "Delegated IAM roles to add to `aws-auth` ConfigMap"

  type = list(object({
    role   = string
    groups = list(string)
  }))

  default = []
}

variable "map_additional_iam_roles" {
  description = "Additional IAM roles to add to `config-map-aws-auth` ConfigMap"

  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))

  default = []
}

variable "map_additional_iam_users" {
  description = "Additional IAM users to add to `aws-auth` ConfigMap"

  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))

  default = []
}

variable "allowed_security_groups" {
  type        = list(string)
  default     = []
  description = "List of Security Group IDs to be allowed to connect to the EKS cluster"
}

variable "allowed_cidr_blocks" {
  type        = list(string)
  default     = []
  description = "List of CIDR blocks to be allowed to connect to the EKS cluster"
}

variable "subnet_type_tag_key" {
  type        = string
  default     = null
  description = "The tag used to find the private subnets to find by availability zone. If null, will be looked up in vpc outputs."
}

variable "color" {
  type        = string
  default     = ""
  description = "The cluster stage represented by a color; e.g. blue, green"
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
}

variable "node_group_defaults" {
  # Any value in the node group that is null will be replaced
  # by the value in this object, which can also be null
  type = object({
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
}

variable "iam_roles_environment_name" {
  type        = string
  description = "The name of the environment where the IAM roles are provisioned"
  default     = "gbl"
}

variable "iam_primary_roles_stage_name" {
  type        = string
  description = "The name of the stage where the IAM primary roles are provisioned"
  default     = "identity"
}

variable "iam_primary_roles_tenant_name" {
  type        = string
  description = "The name of the tenant where the IAM primary roles are provisioned"
  default     = null
}

variable "cluster_encryption_config_enabled" {
  type        = bool
  default     = true
  description = "Set to `true` to enable Cluster Encryption Configuration"
}

variable "cluster_encryption_config_kms_key_id" {
  type        = string
  default     = ""
  description = "KMS Key ID to use for cluster encryption config"
}

variable "cluster_encryption_config_kms_key_enable_key_rotation" {
  type        = bool
  default     = true
  description = "Cluster Encryption Config KMS Key Resource argument - enable kms key rotation"
}

variable "cluster_encryption_config_kms_key_deletion_window_in_days" {
  type        = number
  default     = 10
  description = "Cluster Encryption Config KMS Key Resource argument - key deletion windows in days post destruction"
}

variable "cluster_encryption_config_kms_key_policy" {
  type        = string
  default     = null
  description = "Cluster Encryption Config KMS Key Resource argument - key policy"
}

variable "cluster_encryption_config_resources" {
  type        = list(any)
  default     = ["secrets"]
  description = "Cluster Encryption Config Resources to encrypt, e.g. ['secrets']"
}

variable "aws_ssm_agent_enabled" {
  type        = bool
  description = "Set true to attach the required IAM policy for AWS SSM agent to each EC2 instance's IAM Role"
  default     = false
}

variable "kubeconfig_file" {
  type        = string
  default     = ""
  description = "Name of `kubeconfig` file to use to configure Kubernetes provider"
}

variable "kubeconfig_file_enabled" {
  type        = bool
  default     = false
  description = <<-EOF
    Set true to configure Kubernetes provider with a `kubeconfig` file specified by `kubeconfig_file`.
    Mainly for when the standard configuration produces a Terraform error.
    EOF
}

variable "aws_auth_yaml_strip_quotes" {
  type        = bool
  default     = true
  description = "If true, remove double quotes from the generated aws-auth ConfigMap YAML to reduce spurious diffs in plans"
}

variable "cluster_private_subnets_only" {
  type        = bool
  default     = false
  description = "Whether or not to enable private subnets or both public and private subnets"
}

variable "allow_ingress_from_vpc_stages" {
  type        = list(string)
  default     = []
  description = "List of stages to pull VPC ingress CIDR and add to security group"
}

variable "eks_component_name" {
  type        = string
  description = "The name of the eks component"
  default     = "eks/cluster"
}
