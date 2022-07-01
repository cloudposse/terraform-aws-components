variable "region" {
  type        = string
  description = "AWS Region"
}

variable "description" {
  type        = string
  description = "The description of the repository"
  default     = null
}

variable "environments" {
  type = list(object({
    tenant      = string
    environment = string
    stage       = string
    auto-sync   = bool
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
  description = "Use the value of this variable as the GitHub token instead of reading it from SSM"
  default     = null
}

variable "ssm_github_api_key" {
  type        = string
  description = "SSM path to the GitHub API key"
  default     = "/argocd/github/api_key"
}

variable "ssm_github_deploy_key_format" {
  type        = string
  description = "Format string of the SSM parameter path to which the deploy keys will be written to (%s will be replaced with the environment name)"
  default     = "/argocd/deploy_keys/%s"
}

variable "permissions" {
  type = list(object({
    team_slug  = string,
    permission = string
  }))
  description = <<-EOT
    A list of Repository Permission objects used to configure the team permissions of the repository

    `team_slug` should be the name of the team without the `@{org}` e.g. `@cloudposse/team` => `team`
    `permission` is just one of the available values listed below
  EOT

  default = []

  validation {
    condition = alltrue([
      for obj in var.permissions : can(contains(["pull", "triage", "push", "maintain", "admin"], obj.permission))
    ])

    error_message = "Permission value must be a subset of [pull, triage, push, maintain, admin]."
  }
}

variable "slack_channel" {
  type        = string
  description = "The name of the slack channel to configure ArgoCD notifications for"
  default     = null
}
