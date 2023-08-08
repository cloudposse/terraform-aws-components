locals {
  enabled = module.this.enabled

  efs_components = local.enabled ? toset([for k, v in var.efs_storage_classes : v.efs_component_name]) : []

  # In order to use `optional()`, the variable must be an object, but
  # object keys must be valid identifiers and cannot be like "csi.storage.k8s.io/fstype"
  # See https://github.com/hashicorp/terraform/issues/22681
  # So we have to convert the object to a map with the keys the StorageClass expects
  ebs_key_map = {
    fstype = "csi.storage.k8s.io/fstype"
  }
  old_ebs_key_map = {
    fstype = "fsType"
  }

  efs_key_map = {
    provisioner-secret-name      = "csi.storage.k8s.io/provisioner-secret-name"
    provisioner-secret-namespace = "csi.storage.k8s.io/provisioner-secret-namespace"
  }

  # Tag with cluster name rather than just stage ID.
  tags = merge(module.this.tags, { Name = module.eks.outputs.eks_cluster_id })
}

resource "kubernetes_storage_class_v1" "ebs" {
  for_each = local.enabled ? var.ebs_storage_classes : {}

  metadata {
    name = each.key
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = each.value.make_default_storage_class ? "true" : "false"
    }
    labels = each.value.labels
  }

  # Tags are implemented via parameters. We use "tagSpecification_n" as the key, starting at 1.
  # See https://github.com/kubernetes-sigs/aws-ebs-csi-driver/blob/master/docs/tagging.md#storageclass-tagging
  parameters = merge({ for k, v in each.value.parameters : (
    # provisioner kubernetes.io/aws-ebs uses the key "fsType" instead of "csi.storage.k8s.io/fstype"
    lookup((each.value.provisioner == "kubernetes.io/aws-ebs" ? local.old_ebs_key_map : local.ebs_key_map), k, k)) => v if v != null && v != "" },
    each.value.include_tags ? { for i, k in keys(local.tags) : "tagSpecification_${i + 1}" => "${k}=${local.tags[k]}" } : {},
  )

  storage_provisioner = each.value.provisioner
  reclaim_policy      = each.value.reclaim_policy
  volume_binding_mode = each.value.volume_binding_mode
  mount_options       = each.value.mount_options

  # Allowed topologies are poorly documented, and poorly implemented.
  # According to the API spec https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.26/#storageclass-v1-storage-k8s-io
  # it should be a list of objects with a `matchLabelExpressions` key, which is a list of objects with `key` and `values` keys.
  # However, the Terraform resource only allows a single object in a matchLabelExpressions block, not a list,,
  # the EBS driver appears to only allow a single matchLabelExpressions block, and it is entirely unclear
  # what should happen if either of the lists has more than one element. So we simplify it here to be singletons, not lists.
  dynamic "allowed_topologies" {
    for_each = each.value.allowed_topologies_match_label_expressions != null ? ["zones"] : []
    content {
      match_label_expressions {
        key    = each.value.allowed_topologies_match_label_expressions.key
        values = each.value.allowed_topologies_match_label_expressions.values
      }
    }
  }

  # Unfortunately, the provider always sets allow_volume_expansion to something whether you provide it or not.
  # There is no way to omit it.
  allow_volume_expansion = each.value.allow_volume_expansion
}

resource "kubernetes_storage_class_v1" "efs" {
  for_each = local.enabled ? var.efs_storage_classes : {}

  metadata {
    name = each.key
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = each.value.make_default_storage_class ? "true" : "false"
    }
    labels = each.value.labels
  }
  parameters = merge({ fileSystemId = module.efs[each.value.efs_component_name].outputs.efs_id },
  { for k, v in each.value.parameters : lookup(local.efs_key_map, k, k) => v if v != null && v != "" })

  storage_provisioner = each.value.provisioner
  reclaim_policy      = each.value.reclaim_policy
  volume_binding_mode = each.value.volume_binding_mode
  mount_options       = each.value.mount_options
}
