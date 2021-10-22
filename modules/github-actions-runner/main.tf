locals {
  enabled          = module.this.enabled
  enabled_iam_role = local.enabled && var.iam_role_enabled
  # Loop through each supplied runner_configuration to determine if the runner is an organization (org) or repository (repo) runner type
  runners = [for r in var.runner_configurations : merge(r, tomap({
    "type"   = lower(coalesce(contains(keys(r), "repo") ? "repo" : "", contains(keys(r), "org") ? "org" : "")),
    "target" = lower(coalesce(lookup(r, "org", ""), lookup(r, "repo", "")))
    }))
  ]
}

data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

module "github_action_controller_label" {
  source     = "cloudposse/label/null"
  version    = "0.25.0"
  context    = module.this.context
  attributes = ["github-actions-controller"]
}

# You cannot have a directory with the same name as the chart you are installing from repo
# https://github.com/hashicorp/terraform-provider-helm/issues/735
resource "helm_release" "actions_runner_controller" {
  count = local.enabled ? 1 : 0

  name       = var.controller_chart_release_name # module.github_action_controller_label.tags["Attributes"]
  chart      = var.controller_chart_name
  repository = var.controller_chart_repo
  version    = var.controller_chart_version

  namespace        = var.controller_chart_namespace
  create_namespace = var.controller_chart_namespace_create

  set {
    name  = "image.repository"
    value = var.controller_chart_image
    type  = "string"
  }

  set {
    name  = "image.tag"
    value = var.controller_chart_image_tag
    type  = "string"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.eks_iam_role.service_account_role_arn
    type  = "string"
  }

  set {
    name  = "serviceAccount.name"
    value = "github-action-runner"
    type  = "string"
  }

  values = [
    # remove comments
    yamlencode(yamldecode(
      file("${path.module}/runners/actions-runner-controller/values.yaml"))
    ),
    yamlencode(var.controller_chart_values),
  ]
}

module "github_action_helm_label" {
  count = local.enabled ? length(local.runners) : 0

  source  = "cloudposse/label/null"
  version = "0.25.0"
  context = module.this.context
  attributes = [
    local.runners[count.index]["type"],
    replace(local.runners[count.index]["target"], "/", "-"),
  ]
}

resource "helm_release" "actions_runner" {
  count = local.enabled ? length(local.runners) : 0

  name      = module.github_action_helm_label[count.index].tags["Attributes"]
  chart     = "${path.module}/runners/actions-runner/chart"
  namespace = "actions-runner-system"

  values = [
    yamlencode({
      release_name         = module.github_action_helm_label[count.index].tags["Attributes"]
      service_account_name = "github-action-runner"
      type                 = local.runners[count.index]["type"]
      target               = local.runners[count.index]["target"]
      runners_image        = var.runner_chart_image
      role_arn             = module.eks_iam_role.service_account_role_arn
      runner_resources     = var.runner_types[coalesce(lookup(local.runners[count.index], "runner_type", ""), var.runner_type)]
      autoscale            = var.autoscale_types[var.autoscale_type]
    }),
    yamlencode(var.runner_chart_values),
  ]

  depends_on = [
    helm_release.actions_runner_controller
  ]
}
