output "storage_classes" {
  value       = merge(kubernetes_storage_class_v1.ebs, kubernetes_storage_class_v1.efs)
  description = "Storage classes created by this module"
}
