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
    tenant      = optional(string, null)
    environment = string
    stage       = string
    attributes  = optional(list(string), [])
    auto-sync   = bool
    ignore-differences = optional(list(object({
      group         = string,
      kind          = string,
      json-pointers = list(string)
    })), [])
  }))
  description = <<-EOT
  Environments to populate `applicationset.yaml` files and repository deploy keys (for ArgoCD) for.

  `auto-sync` determines whether or not the ArgoCD application will be automatically synced.

  `ignore-differences` determines whether or not the ArgoCD application will ignore the number of
  replicas in the deployment. Read more on ignore differences here:
  https://argo-cd.readthedocs.io/en/stable/user-guide/sync-options/#respect-ignore-difference-configs

  Example:
  ```
  tenant: plat
  environment: use1
  stage: sandbox
  auto-sync: true
  ignore-differences:
    - group: apps
      kind: Deployment
      json-pointers:
        - /spec/replicas
  ```
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

variable "github_default_notifications_enabled" {
  type        = string
  description = "Enable default GitHub commit statuses notifications (required for CD sync mode)"
  default     = true
}

variable "create_repo" {
  type        = bool
  description = "Whether or not to create the repository or use an existing one"
  default     = true
}

variable "required_pull_request_reviews" {
  type        = bool
  description = "Enforce restrictions for pull request reviews"
  default     = true
}

variable "push_restrictions_enabled" {
  type        = bool
  description = "Enforce who can push to the main branch"
  default     = true
}

variable "vulnerability_alerts_enabled" {
  type        = bool
  description = "Enable security alerts for vulnerable dependencies"
  default     = false
}

variable "restrict_pushes_blocks_creations" {
  type        = bool
  description = "Setting this to `false` allows people, teams, or apps to create new branches matching this rule"
  default     = true
}

variable "slack_notifications_channel" {
  type        = string
  default     = ""
  description = "If given, the Slack channel to for deployment notifications."
}

variable "manifest_kubernetes_namespace" {
  type        = string
  default     = "argocd"
  description = "The namespace used for the ArgoCD application"
}

variable "github_notifications" {
  type = list(string)
  default = [
    "notifications.argoproj.io/subscribe.on-deploy-started.app-repo-github-commit-status: \"\"",
    "notifications.argoproj.io/subscribe.on-deploy-started.argocd-repo-github-commit-status: \"\"",
    "notifications.argoproj.io/subscribe.on-deploy-succeded.app-repo-github-commit-status: \"\"",
    "notifications.argoproj.io/subscribe.on-deploy-succeded.argocd-repo-github-commit-status: \"\"",
    "notifications.argoproj.io/subscribe.on-deploy-failed.app-repo-github-commit-status: \"\"",
    "notifications.argoproj.io/subscribe.on-deploy-failed.argocd-repo-github-commit-status: \"\"",
  ]
  description = <<EOT
    ArgoCD notification annotations for subscribing to GitHub.

    The default value given uses the same notification template names as defined in the `eks/argocd` component. If want to add additional notifications, include any existing notifications from this list that you want to keep in addition.
  EOT
}

variable "web_commit_signoff_required" {
  type        = bool
  description = "Require contributors to sign off on web-based commits"
  default     = false
}
