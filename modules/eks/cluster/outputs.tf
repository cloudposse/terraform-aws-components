output "eks_cluster_id" {
  description = "The name of the cluster"
  value       = module.eks_cluster.eks_cluster_id
}

output "eks_cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster"
  value       = module.eks_cluster.eks_cluster_arn
}

output "eks_cluster_endpoint" {
  description = "The endpoint for the Kubernetes API server"
  value       = module.eks_cluster.eks_cluster_endpoint
}

output "eks_cluster_identity_oidc_issuer" {
  description = "The OIDC Identity issuer for the cluster"
  value       = module.eks_cluster.eks_cluster_identity_oidc_issuer
}

output "eks_cluster_certificate_authority_data" {
  description = "The Kubernetes cluster certificate authority data"
  value       = module.eks_cluster.eks_cluster_certificate_authority_data
}

output "eks_cluster_managed_security_group_id" {
  description = "Security Group ID that was created by EKS for the cluster. EKS creates a Security Group and applies it to ENI that is attached to EKS Control Plane master nodes and to any managed workloads"
  value       = module.eks_cluster.eks_cluster_managed_security_group_id
}

output "eks_cluster_version" {
  description = "The Kubernetes server version of the cluster"
  value       = module.eks_cluster.eks_cluster_version
}

output "eks_node_group_arns" {
  description = "List of all the node group ARNs in the cluster"
  value       = local.node_group_arns
}

output "eks_managed_node_workers_role_arns" {
  description = "List of ARNs for workers in managed node groups"
  value       = local.node_group_role_arns
}

output "eks_node_group_count" {
  description = "Count of the worker nodes"
  value       = length(local.node_group_arns)
}

output "eks_node_group_ids" {
  description = "EKS Cluster name and EKS Node Group name separated by a colon"
  value       = compact([for group in local.node_groups : group.eks_node_group_id])
}

output "eks_node_group_role_names" {
  description = "List of worker nodes IAM role names"
  value       = compact(flatten([for group in local.node_groups : group.eks_node_group_role_name]))
}

output "eks_auth_worker_roles" {
  description = "List of worker IAM roles that were included in the `auth-map` ConfigMap."
  value       = local.linux_worker_role_arns
}

output "eks_node_group_statuses" {
  description = "Status of the EKS Node Group"
  value       = compact([for group in local.node_groups : group.eks_node_group_status])
}

output "karpenter_iam_role_arn" {
  description = "Karpenter IAM Role ARN"
  value       = one(aws_iam_role.karpenter[*].arn)
}

output "karpenter_iam_role_name" {
  description = "Karpenter IAM Role name"
  value       = one(aws_iam_role.karpenter[*].name)
}

output "fargate_profiles" {
  description = "Fargate Profiles"
  value       = merge(module.fargate_profile, local.addon_fargate_profiles)
}

output "fargate_profile_role_arns" {
  description = "Fargate Profile Role ARNs"
  value = distinct(compact(concat(values(module.fargate_profile)[*].eks_fargate_profile_role_arn,
    [one(module.fargate_pod_execution_role[*].eks_fargate_pod_execution_role_arn)]
  )))

}

output "fargate_profile_role_names" {
  description = "Fargate Profile Role names"
  value = distinct(compact(concat(values(module.fargate_profile)[*].eks_fargate_profile_role_name,
    [one(module.fargate_pod_execution_role[*].eks_fargate_pod_execution_role_name)]
  )))
}

output "vpc_cidr" {
  description = "The CIDR of the VPC where this cluster is deployed."
  value       = local.vpc_outputs.vpc_cidr
}

output "availability_zones" {
  description = "Availability Zones in which the cluster is provisioned"
  value       = local.availability_zones
}

output "eks_addons_versions" {
  description = "Map of enabled EKS Addons names and versions"
  value       = module.eks_cluster.eks_addons_versions
}
