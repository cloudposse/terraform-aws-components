data "aws_cloudfront_distribution" "cloudfront_distribution" {
  for_each = local.cloudfront_distribution_protection_enabled ? toset(var.cloudfront_distribution_ids) : []

  id = each.key
}

resource "aws_shield_protection" "cloudfront_shield_protection" {
  for_each = local.cloudfront_distribution_protection_enabled ? data.aws_cloudfront_distribution.cloudfront_distribution : {}

  name         = data.aws_cloudfront_distribution.cloudfront_distribution[each.key].domain_name
  resource_arn = data.aws_cloudfront_distribution.cloudfront_distribution[each.key].arn

  tags = local.tags
}
