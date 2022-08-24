resource "aws_cognito_user_pool_domain" "domain" {
  count = !local.enabled || var.domain == null || var.domain == "" ? 0 : 1

  domain          = var.domain
  certificate_arn = var.domain_certificate_arn
  user_pool_id    = join("", aws_cognito_user_pool.pool.*.id)
}
