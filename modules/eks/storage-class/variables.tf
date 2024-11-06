variable "region" {
  description = "AWS Region."
  type        = string
}

variable "eks_component_name" {
  type        = string
  description = "The name of the EKS component for the cluster in which to create the storage classes"
  default     = "eks/cluster"
  nullable    = false
}

variable "ebs_storage_classes" {
  type = map(object({
    enabled                    = optional(bool, true)
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
  description = "A map of storage class name to EBS parameters to create"
  default     = {}
  nullable    = false
}

variable "efs_storage_classes" {
  type = map(object({
    enabled                    = optional(bool, true)
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
  description = "A map of storage class name to EFS parameters to create"
  default     = {}
  nullable    = false
}
