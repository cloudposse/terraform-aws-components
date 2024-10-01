// ArgoCD variables

variable "alb_group_name" {
  type        = string
  description = "A name used in annotations to reuse an ALB (e.g. `argocd`) or to generate a new one"
  default     = null
}

variable "alb_name" {
  type        = string
  description = "The name of the ALB (e.g. `argocd`) provisioned by `alb-controller`. Works together with `var.alb_group_name`"
  default     = null
}

variable "alb_logs_bucket" {
  type        = string
  description = "The name of the bucket for ALB access logs. The bucket must have policy allowing the ELB logging principal"
  default     = ""
}

variable "alb_logs_prefix" {
  type        = string
  description = "`alb_logs_bucket` s3 bucket prefix"
  default     = ""
}

variable "certificate_issuer" {
  type        = string
  description = "Certificate manager cluster issuer"
  default     = "letsencrypt-staging"
}

variable "argocd_create_namespaces" {
  type        = bool
  description = "ArgoCD create namespaces policy"
  default     = false
}

variable "argocd_repositories" {
  type = map(object({
    environment = string # The environment where the `argocd_repo` component is deployed.
    stage       = string # The stage where the `argocd_repo` component is deployed.
    tenant      = string # The tenant where the `argocd_repo` component is deployed.
  }))
  description = "Map of objects defining an `argocd_repo` to configure.  The key is the name of the ArgoCD repository."
  default     = {}
}

variable "github_organization" {
  type        = string
  description = "GitHub Organization"
}

variable "ssm_store_account" {
  type        = string
  description = "Account storing SSM parameters"
}

variable "ssm_store_account_tenant" {
  type        = string
  description = <<-EOT
  Tenant of the account storing SSM parameters.

  If the tenant label is not used, leave this as null.
  EOT
  default     = null
}

variable "ssm_store_account_region" {
  type        = string
  description = "AWS region storing SSM parameters"
}

variable "ssm_oidc_client_id" {
  type        = string
  description = "The SSM Parameter Store path for the ID of the IdP client"
  default     = "/argocd/oidc/client_id"
}

variable "ssm_oidc_client_secret" {
  type        = string
  description = "The SSM Parameter Store path for the secret of the IdP client"
  default     = "/argocd/oidc/client_secret"
}

variable "host" {
  type        = string
  description = "Host name to use for ingress and ALB"
  default     = ""
}

variable "forecastle_enabled" {
  type        = bool
  description = "Toggles Forecastle integration in the deployed chart"
  default     = false
}

variable "admin_enabled" {
  type        = bool
  description = "Toggles Admin user creation the deployed chart"
  default     = false
}

variable "anonymous_enabled" {
  type        = bool
  description = "Toggles anonymous user access using default RBAC setting (Defaults to read-only)"
  default     = false
}

variable "oidc_enabled" {
  type        = bool
  description = "Toggles OIDC integration in the deployed chart"
  default     = false
}

variable "oidc_issuer" {
  type        = string
  description = "OIDC issuer URL"
  default     = ""
}

variable "oidc_name" {
  type        = string
  description = "Name of the OIDC resource"
  default     = ""
}

variable "oidc_rbac_scopes" {
  type        = string
  description = "OIDC RBAC scopes to request"
  default     = "[argocd_realm_access]"
}

variable "oidc_requested_scopes" {
  type        = string
  description = "Set of OIDC scopes to request"
  default     = "[\"openid\", \"profile\", \"email\", \"groups\"]"
}

variable "saml_enabled" {
  type        = bool
  description = "Toggles SAML integration in the deployed chart"
  default     = false
}

variable "saml_rbac_scopes" {
  type        = string
  description = "SAML RBAC scopes to request"
  default     = "[email,groups]"
}

variable "service_type" {
  type        = string
  default     = "NodePort"
  description = <<-EOT
  Service type for exposing the ArgoCD service. The available type values and their behaviors are:
    ClusterIP: Exposes the Service on a cluster-internal IP. Choosing this value makes the Service only reachable from within the cluster.
    NodePort: Exposes the Service on each Node's IP at a static port (the NodePort).
    LoadBalancer: Exposes the Service externally using a cloud provider's load balancer.
  EOT
}

variable "argocd_rbac_policies" {
  type        = list(string)
  default     = []
  description = <<-EOT
  List of ArgoCD RBAC Permission strings to be added to the argocd-rbac configmap policy.csv item.

  See https://argo-cd.readthedocs.io/en/stable/operator-manual/rbac/ for more information.
  EOT
}

variable "argocd_rbac_default_policy" {
  type        = string
  default     = "role:readonly"
  description = <<-EOT
  Default ArgoCD RBAC default role.

  See https://argo-cd.readthedocs.io/en/stable/operator-manual/rbac/#basic-built-in-roles for more information.
  EOT
}

variable "argocd_rbac_groups" {
  type = list(object({
    group = string,
    role  = string
  }))
  default     = []
  description = <<-EOT
  List of ArgoCD Group Role Assignment strings to be added to the argocd-rbac configmap policy.csv item.
  e.g.
  [
    {
      group: idp-group-name,
      role: argocd-role-name
    },
  ]
  becomes: `g, idp-group-name, role:argocd-role-name`
  See https://argo-cd.readthedocs.io/en/stable/operator-manual/rbac/ for more information.
  EOT
}

variable "eks_component_name" {
  type        = string
  default     = "eks/cluster"
  description = "The name of the eks component"
}

variable "saml_sso_providers" {
  type = map(object({
    component   = string
    environment = optional(string, null)
  }))

  default     = {}
  description = "SAML SSO providers components"
}
