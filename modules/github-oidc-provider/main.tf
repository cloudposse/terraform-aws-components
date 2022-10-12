locals {
  enabled = module.this.enabled
}

resource "aws_iam_openid_connect_provider" "oidc" {
  for_each = local.enabled ? toset(["github"]) : []

  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = var.thumbprint_list
  tags            = module.this.tags
}
