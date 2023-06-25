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

# https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.2/guide/ingress/annotations/
output "load_balancer_scheme" {
  description = "The value of the `alb.ingress.kubernetes.io/scheme` annotation of the Kubernetes Ingress"
  value       = local.scheme_annotation
}

# https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.2/guide/ingress/annotations/
output "ingress_class" {
  description = "The value of the `kubernetes.io/ingress.class` annotation of the Kubernetes Ingress"
  value       = local.class_annotation
}
