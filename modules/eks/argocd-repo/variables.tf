variable "region" {
  type        = string
  description = "AWS Region."
}

variable "description" {
  type        = string
  description = "Repository description."
  default     = null
}

variable "environments" {
  type = list(object({
    tenant               = string
    environment          = string
    stage                = string
    auto-sync            = bool
    auto-sync-namespaces = bool
    slack_channel        = string
  }))
  description = <<-EOT
  Environments to populate `applicationset.yaml` files and repository deploy keys (for ArgoCD) for.

  `auto-sync` determines whether or not the ArgoCD application will be automatically synced.
  EOT
  default     = []
}

variable "gitignore_entries" {
  type        = list(string)
  description = <<-EOT
  List of .gitignore entries to use when populating the .gitignore file.

  For example: `[".idea/", ".vscode/"]`.
  EOT
}

variable "github_base_url" {
  type        = string
  description = "This is the target GitHub base API endpoint. Providing a value is a requirement when working with GitHub Enterprise. It is optional to provide this value and it can also be sourced from the `GITHUB_BASE_URL` environment variable. The value must end with a slash, for example: `https://terraformtesting-ghe.westus.cloudapp.azure.com/`"
  default     = null
}

variable "github_codeowner_teams" {
  type        = list(string)
  description = <<-EOT
  List of teams to use when populating the CODEOWNERS file.

  For example: `["@ACME/cloud-admins", "@ACME/cloud-developers"]`.
  EOT
}

variable "github_user" {
  type        = string
  description = "Github user"
}

variable "github_user_email" {
  type        = string
  description = "Github user email"
}

variable "github_organization" {
  type        = string
  description = "GitHub Organization"
}

variable "github_token_override" {
  type        = string
  description = "TODO"
  default     = null
}

variable "ssm_github_api_key" {
  type        = string
  description = "SSM path to the GitHub API key"
  default     = "/argocd/github/api_key"
}

variable "deploy_key_generation_enabled" {
  type        = bool
  description = <<-EOT
  If true, the private keys for the GitHub Deploy Keys will be created and written to SSM Parameter Store.

  If false, it is expected that the private keys are exist in SSM beforehand.
  EOT
  default     = false
}

variable "ssm_github_deploy_key_format" {
  type        = string
  description = "Format string of the SSM parameter path to which the deploy keys will be written to (%s will be replaced with the environment name)."
  default     = "/argocd/deploy_keys/%s"
}

variable "applicationset_template" {
  type        = string
  description = <<-EOT
  The name of the applicationset template used to initialize each environment.
  Valid values are:
    apps.applicationset.yaml.tpl (default)
    config.applicationset.yaml.tpl
  EOT
  default     = "apps.applicationset.yaml.tpl"
}

variable "cluster_config_types" {
  type        = set(string)
  description = "Cluster configuration types to initialize when `var.applicationset_template == config.applicationset.yaml.tpl`"
  default     = []
}
