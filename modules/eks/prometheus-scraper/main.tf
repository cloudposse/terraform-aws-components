locals {
  enabled = module.this.enabled

  # This will be used as the name of the ClusterRole and bound User
  aps_clusterrole_identity = module.this.id

  # Amazon EKS requires a different format for this ARN. You must adjust the format of the returned ARN
  # arn:aws:iam::account-id:role/AWSServiceRoleForAmazonPrometheusScraper_unique-id
  #
  # For example,
  # arn:aws:iam::111122223333:role/aws-service-role/scraper.aps.amazonaws.com/AWSServiceRoleForAmazonPrometheusScraper_1234abcd-56ef-7
  # must be changed be to
  # arn:aws:iam::111122223333:role/AWSServiceRoleForAmazonPrometheusScraper_1234abcd-56ef-7
  aps_clusterrole_username = replace(aws_prometheus_scraper.this[0].role_arn, "role/aws-service-role/scraper.aps.amazonaws.com", "role")

}

resource "aws_prometheus_scraper" "this" {
  count = local.enabled ? 1 : 0

  source {
    eks {
      cluster_arn        = module.eks.outputs.eks_cluster_arn
      security_group_ids = [module.eks.outputs.eks_cluster_managed_security_group_id]
      subnet_ids         = module.vpc.outputs.private_subnet_ids
    }
  }

  destination {
    amp {
      workspace_arn = module.prometheus.outputs.workspace_arn
    }
  }

  scrape_configuration = var.eks_scrape_configuration
}

module "scraper_access" {
  source  = "cloudposse/helm-release/aws"
  version = "0.10.1"

  enabled = local.enabled

  name        = length(module.this.name) > 0 ? module.this.name : "prometheus"
  chart       = "${path.module}/charts/scraper-access"
  description = var.chart_description

  kubernetes_namespace = var.kubernetes_namespace
  create_namespace     = var.create_namespace

  verify          = var.verify
  wait            = var.wait
  atomic          = var.atomic
  cleanup_on_fail = var.cleanup_on_fail
  timeout         = var.timeout

  eks_cluster_oidc_issuer_url = replace(module.eks.outputs.eks_cluster_identity_oidc_issuer, "https://", "")

  values = compact([
    yamlencode({
      cluster_role_name = local.aps_clusterrole_identity
      cluster_user_name = local.aps_clusterrole_identity
    }),
    yamlencode(var.chart_values),
  ])

  context = module.this.context
}
