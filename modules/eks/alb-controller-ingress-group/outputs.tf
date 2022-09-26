output "annotations" {
  description = "The annotations of the Ingress"
  value       = local.annotations
}

output "group_name" {
  description = "The value of `alb.ingress.kubernetes.io/group.name` of the Ingress"
  value       = local.group_name_annotation
}

output "load_balancer_name" {
  description = "The name of the load balancer created by the Ingress"
  value       = local.load_balancer_name
}

output "host" {
  description = "The name of the host used by the Ingress"
  value       = local.host
}

output "message_body_length" {
  description = "The length of the message body to ensure it's lower than the maximum limit"
  value       = length(local.message_body)
}
