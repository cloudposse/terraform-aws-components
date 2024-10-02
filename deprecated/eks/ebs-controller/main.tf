locals {
  enabled = module.this.enabled
}

module "ebs_csi_driver_controller" {
  count = local.enabled ? 1 : 0

  # https://github.com/DrFaust92/terraform-kubernetes-ebs-csi-driver
  source  = "DrFaust92/ebs-csi-driver/kubernetes"
  version = "3.5.0"

  ebs_csi_driver_version                     = var.ebs_csi_driver_version
  ebs_csi_controller_image                   = var.ebs_csi_controller_image
  ebs_csi_controller_role_name               = "ebs-csi-${module.eks.outputs.cluster_shortname}"
  ebs_csi_controller_role_policy_name_prefix = "ebs-csi-${module.eks.outputs.cluster_shortname}"
  oidc_url                                   = replace(module.eks.outputs.eks_cluster_identity_oidc_issuer, "https://", "")
  enable_volume_resizing                     = true
}

# Remove non encrypted default storage class
resource "kubernetes_annotations" "default_storage_class" {
  count      = local.enabled ? 1 : 0
  depends_on = [module.ebs_csi_driver_controller]

  api_version = "storage.k8s.io/v1"
  kind        = "StorageClass"
  force       = "true"

  metadata {
    name = "gp2"
  }

  annotations = {
    "storageclass.kubernetes.io/is-default-class" = "false"
  }
}

# Create the new StorageClass and make it default
resource "kubernetes_storage_class" "gp3_enc" {
  count      = local.enabled ? 1 : 0
  depends_on = [module.ebs_csi_driver_controller]
  metadata {
    name = "gp3-enc"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }
  storage_provisioner    = "ebs.csi.aws.com"
  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion = true
  parameters = {
    "encrypted" = "true"
    "fsType"    = "ext4"
    "type"      = "gp3"
  }
}
