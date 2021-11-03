# output "eks_spotinst_ocean_controller_ids" {
#   description = "The ID of the Ocean controller"
#   value       = local.spotinst_enabled ? toset(values(module.spotinst_oceans)[*].ocean_controller_id) : null
# }
