variable "region" {
  type        = string
  description = "AWS Region"
}

variable "eks_component_name" {
  type        = string
  description = "The name of the eks component"
  default     = "eks/cluster"
}

variable "ebs_csi_driver_version" {
  type        = string
  description = "The version of the EBS CSI driver"
  default     = "v1.6.2"
}

variable "ebs_csi_controller_image" {
  type        = string
  description = "The image to use for the EBS CSI controller"
  default     = "k8s.gcr.io/provider-aws/aws-ebs-csi-driver"
}
