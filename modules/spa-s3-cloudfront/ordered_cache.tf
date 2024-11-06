resource "aws_cloudfront_cache_policy" "created_cache_policies" {
  for_each = {
    for cache in var.ordered_cache : cache.cache_policy_name => cache if cache.cache_policy_id == null
  }

  comment     = var.comment
  default_ttl = each.value.default_ttl
  max_ttl     = each.value.max_ttl
  min_ttl     = each.value.min_ttl
  name        = each.value.cache_policy_name
  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }
    headers_config {
      header_behavior = "none"
    }
    query_strings_config {
      query_string_behavior = "none"
    }
  }
}

resource "aws_cloudfront_origin_request_policy" "created_origin_request_policies" {
  for_each = {
    for cache in var.ordered_cache : cache.origin_request_policy_name => cache if cache.origin_request_policy_id == null
  }

  comment = var.comment
  name    = each.value.origin_request_policy_name
  cookies_config {
    cookie_behavior = each.value.origin_request_policy.cookie_behavior
    dynamic "cookies" {
      for_each = length(each.value.origin_request_policy.cookies) > 0 ? [each.value.origin_request_policy.cookies] : []
      content {
        items = cookies.value
      }
    }
  }
  headers_config {
    header_behavior = each.value.origin_request_policy.header_behavior
    dynamic "headers" {
      for_each = length(each.value.origin_request_policy.headers) > 0 ? [each.value.origin_request_policy.headers] : []
      content {
        items = headers.value
      }
    }
  }
  query_strings_config {
    query_string_behavior = each.value.origin_request_policy.query_string_behavior
    dynamic "query_strings" {
      for_each = length(each.value.origin_request_policy.query_strings) > 0 ? [each.value.origin_request_policy.query_strings] : []
      content {
        items = query_strings.value
      }
    }
  }
}

locals {
  ordered_cache = [
    for cache in var.ordered_cache : merge(cache, {
      cache_policy_id          = cache.cache_policy_id == null ? aws_cloudfront_cache_policy.created_cache_policies[cache.cache_policy_name].id : cache.cache_policy_id
      origin_request_policy_id = cache.origin_request_policy_id == null ? aws_cloudfront_origin_request_policy.created_origin_request_policies[cache.origin_request_policy_name].id : cache.origin_request_policy_id
    })
  ]
}
