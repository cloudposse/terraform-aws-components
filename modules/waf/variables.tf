variable "region" {
  type        = string
  description = "AWS Region"
}

variable "ssm_path_prefix" {
  type        = string
  default     = "/waf"
  description = "SSM path prefix (with leading but not trailing slash) under which to store all WAF info"
}

variable "acl_name" {
  type        = string
  description = "Friendly name of the ACL. The ACL ARN will be stored in SSM under {ssm_path_prefix}/{acl_name}/arn"
}

variable "description" {
  type        = string
  default     = "Managed by Terraform"
  description = "A friendly description of the WebACL."
}

variable "default_action" {
  type        = string
  default     = "block"
  description = "Specifies that AWS WAF should allow requests by default. Possible values: `allow`, `block`."
  nullable    = false
  validation {
    condition     = contains(["allow", "block"], var.default_action)
    error_message = "Allowed values: `allow`, `block`."
  }
}

variable "default_block_response" {
  type        = string
  default     = null
  description = <<-DOC
    A HTTP response code that is sent when default action is used. Only takes effect if default_action is set to `block`.
  DOC
  nullable    = true
}

variable "custom_response_body" {
  type = map(object({
    content      = string
    content_type = string
  }))

  description = <<-DOC
    Defines custom response bodies that can be referenced by custom_response actions.
    The map keys are used as the `key` attribute which is a unique key identifying the custom response body.
    content:
      Payload of the custom response.
      The response body can be plain text, HTML or JSON and cannot exceed 4KB in size.
    content_type:
      Content Type of Response Body.
      Valid values are `TEXT_PLAIN`, `TEXT_HTML`, or `APPLICATION_JSON`.
  DOC
  default     = {}
  nullable    = false
}

variable "scope" {
  type        = string
  default     = "REGIONAL"
  description = <<-DOC
    Specifies whether this is for an AWS CloudFront distribution or for a regional application.
    Possible values are `CLOUDFRONT` or `REGIONAL`.
    To work with CloudFront, you must also specify the region us-east-1 (N. Virginia) on the AWS provider.
  DOC
  nullable    = false
  validation {
    condition     = contains(["CLOUDFRONT", "REGIONAL"], var.scope)
    error_message = "Allowed values: `CLOUDFRONT`, `REGIONAL`."
  }
}

variable "visibility_config" {
  type = object({
    cloudwatch_metrics_enabled = bool
    metric_name                = string
    sampled_requests_enabled   = bool
  })
  description = <<-DOC
    Defines and enables Amazon CloudWatch metrics and web request sample collection.

    cloudwatch_metrics_enabled:
      Whether the associated resource sends metrics to CloudWatch.
    metric_name:
      A friendly name of the CloudWatch metric.
    sampled_requests_enabled:
      Whether AWS WAF should store a sampling of the web requests that match the rules.
  DOC
  nullable    = false
}

variable "token_domains" {
  type        = list(string)
  description = <<-DOC
    Specifies the domains that AWS WAF should accept in a web request token.
    This enables the use of tokens across multiple protected websites.
    When AWS WAF provides a token, it uses the domain of the AWS resource that the web ACL is protecting.
    If you don't specify a list of token domains, AWS WAF accepts tokens only for the domain of the protected resource.
    With a token domain list, AWS WAF accepts the resource's host domain plus all domains in the token domain list,
    including their prefixed subdomains.
  DOC
  default     = null
}

# Logging configuration
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl_logging_configuration.html
variable "log_destination_configs" {
  type        = list(string)
  default     = []
  description = "The Amazon Kinesis Data Firehose, CloudWatch Log log group, or S3 bucket Amazon Resource Names (ARNs) that you want to associate with the web ACL"
}

variable "redacted_fields" {
  type = map(object({
    method        = optional(bool, false)
    uri_path      = optional(bool, false)
    query_string  = optional(bool, false)
    single_header = optional(list(string), null)
  }))
  default     = {}
  description = <<-DOC
    The parts of the request that you want to keep out of the logs.
    You can only specify one of the following: `method`, `query_string`, `single_header`, or `uri_path`

    method:
      Whether to enable redaction of the HTTP method.
      The method indicates the type of operation that the request is asking the origin to perform.
    uri_path:
      Whether to enable redaction of the URI path.
      This is the part of a web request that identifies a resource.
    query_string:
      Whether to enable redaction of the query string.
      This is the part of a URL that appears after a `?` character, if any.
    single_header:
      The list of names of the query headers to redact.
  DOC
  nullable    = false
}

variable "logging_filter" {
  type = object({
    default_behavior = string
    filter = list(object({
      behavior    = string
      requirement = string
      condition = list(object({
        action_condition = optional(object({
          action = string
        }), null)
        label_name_condition = optional(object({
          label_name = string
        }), null)
      }))
    }))
  })
  default     = null
  description = <<-DOC
    A configuration block that specifies which web requests are kept in the logs and which are dropped.
    You can filter on the rule action and on the web request labels that were applied by matching rules during web ACL evaluation.
  DOC
}

# Association resources
variable "association_resource_arns" {
  type        = list(string)
  default     = []
  description = <<-DOC
    A list of ARNs of the resources to associate with the web ACL.
    This must be an ARN of an Application Load Balancer, Amazon API Gateway stage, or AWS AppSync.

    Do not use this variable to associate a Cloudfront Distribution.
    Instead, you should use the `web_acl_id` property on the `cloudfront_distribution` resource.
    For more details, refer to https://docs.aws.amazon.com/waf/latest/APIReference/API_AssociateWebACL.html
  DOC
  nullable    = false
}

variable "alb_names" {
  description = "list of ALB names to associate with the web ACL."
  type        = list(string)
  default     = []
  nullable    = false
}

variable "alb_tags" {
  description = "list of tags to match one or more ALBs to associate with the web ACL."
  type        = list(map(string))
  default     = []
  nullable    = false
}

variable "association_resource_component_selectors" {
  type = list(object({
    component            = string
    namespace            = optional(string, null)
    tenant               = optional(string, null)
    environment          = optional(string, null)
    stage                = optional(string, null)
    component_arn_output = string
  }))
  default     = []
  description = <<-DOC
    A list of Atmos component selectors to get from the remote state and associate their ARNs with the web ACL.
    The components must be Application Load Balancers, Amazon API Gateway stages, or AWS AppSync.

    component:
      Atmos component name
    component_arn_output:
      The component output that defines the component ARN

    Do not use this variable to select a Cloudfront Distribution component.
    Instead, you should use the `web_acl_id` property on the `cloudfront_distribution` resource.
    For more details, refer to https://docs.aws.amazon.com/waf/latest/APIReference/API_AssociateWebACL.html
  DOC
  nullable    = false
}

# Rules
variable "byte_match_statement_rules" {
  type = list(object({
    name     = string
    priority = number
    action   = string
    captcha_config = optional(object({
      immunity_time_property = object({
        immunity_time = number
      })
    }), null)
    rule_label = optional(list(string), null)
    statement  = any
    visibility_config = optional(object({
      cloudwatch_metrics_enabled = optional(bool)
      metric_name                = string
      sampled_requests_enabled   = optional(bool)
    }), null)
  }))
  default     = null
  description = <<-DOC
    A rule statement that defines a string match search for AWS WAF to apply to web requests.

    action:
      The action that AWS WAF should take on a web request when it matches the rule's statement.
    name:
      A friendly name of the rule.
    priority:
      If you define more than one Rule in a WebACL,
      AWS WAF evaluates each request against the rules in order based on the value of priority.
      AWS WAF processes rules with lower priority first.

    captcha_config:
     Specifies how AWS WAF should handle CAPTCHA evaluations.

     immunity_time_property:
       Defines custom immunity time.

       immunity_time:
       The amount of time, in seconds, that a CAPTCHA or challenge timestamp is considered valid by AWS WAF. The default setting is 300.

    rule_label:
       A List of labels to apply to web requests that match the rule match statement

    statement:
      positional_constraint:
        Area within the portion of a web request that you want AWS WAF to search for search_string. Valid values include the following: EXACTLY, STARTS_WITH, ENDS_WITH, CONTAINS, CONTAINS_WORD.
      search_string
        String value that you want AWS WAF to search for. AWS WAF searches only in the part of web requests that you designate for inspection in field_to_match.
      field_to_match:
        The part of a web request that you want AWS WAF to inspect.
        See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl#field-to-match
      text_transformation:
        Text transformations eliminate some of the unusual formatting that attackers use in web requests in an effort to bypass detection.
        See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl#text-transformation

    visibility_config:
      Defines and enables Amazon CloudWatch metrics and web request sample collection.

      cloudwatch_metrics_enabled:
        Whether the associated resource sends metrics to CloudWatch.
      metric_name:
        A friendly name of the CloudWatch metric.
      sampled_requests_enabled:
        Whether AWS WAF should store a sampling of the web requests that match the rules.
  DOC
}

variable "geo_allowlist_statement_rules" {
  type = list(object({
    name     = string
    priority = number
    action   = string
    captcha_config = optional(object({
      immunity_time_property = object({
        immunity_time = number
      })
    }), null)
    rule_label = optional(list(string), null)
    statement  = any
    visibility_config = optional(object({
      cloudwatch_metrics_enabled = optional(bool)
      metric_name                = string
      sampled_requests_enabled   = optional(bool)
    }), null)
  }))
  default     = null
  description = <<-DOC
    A rule statement used to identify a list of allowed countries which should not be blocked by the WAF.

    name:
      A friendly name of the rule.
    priority:
      If you define more than one Rule in a WebACL,
      AWS WAF evaluates each request against the rules in order based on the value of priority.
      AWS WAF processes rules with lower priority first.

    captcha_config:
     Specifies how AWS WAF should handle CAPTCHA evaluations.

     immunity_time_property:
       Defines custom immunity time.

       immunity_time:
       The amount of time, in seconds, that a CAPTCHA or challenge timestamp is considered valid by AWS WAF. The default setting is 300.

    rule_label:
       A List of labels to apply to web requests that match the rule match statement

    statement:
      country_codes:
        A list of two-character country codes.
      forwarded_ip_config:
        fallback_behavior:
          The match status to assign to the web request if the request doesn't have a valid IP address in the specified position.
          Possible values: `MATCH`, `NO_MATCH`
        header_name:
          The name of the HTTP header to use for the IP address.

    visibility_config:
      Defines and enables Amazon CloudWatch metrics and web request sample collection.

      cloudwatch_metrics_enabled:
        Whether the associated resource sends metrics to CloudWatch.
      metric_name:
        A friendly name of the CloudWatch metric.
      sampled_requests_enabled:
        Whether AWS WAF should store a sampling of the web requests that match the rules.
  DOC
}

variable "geo_match_statement_rules" {
  type = list(object({
    name     = string
    priority = number
    action   = string
    captcha_config = optional(object({
      immunity_time_property = object({
        immunity_time = number
      })
    }), null)
    rule_label = optional(list(string), null)
    statement  = any
    visibility_config = optional(object({
      cloudwatch_metrics_enabled = optional(bool)
      metric_name                = string
      sampled_requests_enabled   = optional(bool)
    }), null)
  }))
  default     = null
  description = <<-DOC
    A rule statement used to identify web requests based on country of origin.

    action:
      The action that AWS WAF should take on a web request when it matches the rule's statement.
    name:
      A friendly name of the rule.
    priority:
      If you define more than one Rule in a WebACL,
      AWS WAF evaluates each request against the rules in order based on the value of priority.
      AWS WAF processes rules with lower priority first.

    captcha_config:
     Specifies how AWS WAF should handle CAPTCHA evaluations.

     immunity_time_property:
       Defines custom immunity time.

       immunity_time:
       The amount of time, in seconds, that a CAPTCHA or challenge timestamp is considered valid by AWS WAF. The default setting is 300.

    rule_label:
       A List of labels to apply to web requests that match the rule match statement

    statement:
      country_codes:
        A list of two-character country codes.
      forwarded_ip_config:
        fallback_behavior:
          The match status to assign to the web request if the request doesn't have a valid IP address in the specified position.
          Possible values: `MATCH`, `NO_MATCH`
        header_name:
          The name of the HTTP header to use for the IP address.

    visibility_config:
      Defines and enables Amazon CloudWatch metrics and web request sample collection.

      cloudwatch_metrics_enabled:
        Whether the associated resource sends metrics to CloudWatch.
      metric_name:
        A friendly name of the CloudWatch metric.
      sampled_requests_enabled:
        Whether AWS WAF should store a sampling of the web requests that match the rules.
  DOC
}

variable "ip_set_reference_statement_rules" {
  type = list(object({
    name     = string
    priority = number
    action   = string
    captcha_config = optional(object({
      immunity_time_property = object({
        immunity_time = number
      })
    }), null)
    rule_label = optional(list(string), null)
    statement  = any
    visibility_config = optional(object({
      cloudwatch_metrics_enabled = optional(bool)
      metric_name                = string
      sampled_requests_enabled   = optional(bool)
    }), null)
  }))
  default     = null
  description = <<-DOC
    A rule statement used to detect web requests coming from particular IP addresses or address ranges.

    action:
      The action that AWS WAF should take on a web request when it matches the rule's statement.
    name:
      A friendly name of the rule.
    priority:
      If you define more than one Rule in a WebACL,
      AWS WAF evaluates each request against the rules in order based on the value of priority.
      AWS WAF processes rules with lower priority first.

    captcha_config:
     Specifies how AWS WAF should handle CAPTCHA evaluations.

     immunity_time_property:
       Defines custom immunity time.

       immunity_time:
       The amount of time, in seconds, that a CAPTCHA or challenge timestamp is considered valid by AWS WAF. The default setting is 300.

    rule_label:
       A List of labels to apply to web requests that match the rule match statement

    statement:
      arn:
        The ARN of the IP Set that this statement references.
      ip_set:
        Defines a new IP Set

        description:
          A friendly description of the IP Set
        addresses:
          Contains an array of strings that specifies zero or more IP addresses or blocks of IP addresses.
          All addresses must be specified using Classless Inter-Domain Routing (CIDR) notation.
        ip_address_version:
          Specify `IPV4` or `IPV6`
      ip_set_forwarded_ip_config:
        fallback_behavior:
          The match status to assign to the web request if the request doesn't have a valid IP address in the specified position.
          Possible values: `MATCH`, `NO_MATCH`
        header_name:
          The name of the HTTP header to use for the IP address.
        position:
          The position in the header to search for the IP address.
          Possible values include: `FIRST`, `LAST`, or `ANY`.

    visibility_config:
      Defines and enables Amazon CloudWatch metrics and web request sample collection.

      cloudwatch_metrics_enabled:
        Whether the associated resource sends metrics to CloudWatch.
      metric_name:
        A friendly name of the CloudWatch metric.
      sampled_requests_enabled:
        Whether AWS WAF should store a sampling of the web requests that match the rules.
  DOC
}

variable "managed_rule_group_statement_rules" {
  type = list(object({
    name            = string
    priority        = number
    override_action = optional(string)
    captcha_config = optional(object({
      immunity_time_property = object({
        immunity_time = number
      })
    }), null)
    rule_label = optional(list(string), null)
    statement = object({
      name        = string
      vendor_name = string
      version     = optional(string)
      rule_action_override = optional(map(object({
        action = string
        custom_request_handling = optional(object({
          insert_header = object({
            name  = string
            value = string
          })
        }), null)
        custom_response = optional(object({
          response_code = string
          response_header = optional(object({
            name  = string
            value = string
          }), null)
        }), null)
      })), null)
      managed_rule_group_configs = optional(list(object({
        aws_managed_rules_bot_control_rule_set = optional(object({
          inspection_level        = string
          enable_machine_learning = optional(bool, true)
        }), null)
        aws_managed_rules_atp_rule_set = optional(object({
          enable_regex_in_path = optional(bool)
          login_path           = string
          request_inspection = optional(object({
            payload_type = string
            password_field = object({
              identifier = string
            })
            username_field = object({
              identifier = string
            })
          }), null)
          response_inspection = optional(object({
            body_contains = optional(object({
              success_strings = list(string)
              failure_strings = list(string)
            }), null)
            header = optional(object({
              name           = string
              success_values = list(string)
              failure_values = list(string)
            }), null)
            json = optional(object({

              identifier      = string
              success_strings = list(string)
              failure_strings = list(string)
            }), null)
            status_code = optional(object({
              success_codes = list(string)
              failure_codes = list(string)
            }), null)
          }), null)
        }), null)
      })), null)
    })
    visibility_config = optional(object({
      cloudwatch_metrics_enabled = optional(bool)
      metric_name                = string
      sampled_requests_enabled   = optional(bool)
    }), null)
  }))
  default     = null
  description = <<-DOC
    A rule statement used to run the rules that are defined in a managed rule group.

    name:
      A friendly name of the rule.
    priority:
      If you define more than one Rule in a WebACL,
      AWS WAF evaluates each request against the rules in order based on the value of priority.
      AWS WAF processes rules with lower priority first.

    override_action:
      The override action to apply to the rules in a rule group.
      Possible values: `count`, `none`

    captcha_config:
     Specifies how AWS WAF should handle CAPTCHA evaluations.

     immunity_time_property:
       Defines custom immunity time.

       immunity_time:
       The amount of time, in seconds, that a CAPTCHA or challenge timestamp is considered valid by AWS WAF. The default setting is 300.

    rule_label:
       A List of labels to apply to web requests that match the rule match statement

    statement:
      name:
        The name of the managed rule group.
      vendor_name:
        The name of the managed rule group vendor.
      version:
        The version of the managed rule group.
        You can set `Version_1.0` or `Version_1.1` etc. If you want to use the default version, do not set anything.
      rule_action_override:
        Action settings to use in the place of the rule actions that are configured inside the rule group.
        You specify one override for each rule whose action you want to change.
      managed_rule_group_configs:
        Additional information that's used by a managed rule group. Only one rule attribute is allowed in each config.
        Refer to https://docs.aws.amazon.com/waf/latest/developerguide/aws-managed-rule-groups-list.html for more details.

    visibility_config:
      Defines and enables Amazon CloudWatch metrics and web request sample collection.

      cloudwatch_metrics_enabled:
        Whether the associated resource sends metrics to CloudWatch.
      metric_name:
        A friendly name of the CloudWatch metric.
      sampled_requests_enabled:
        Whether AWS WAF should store a sampling of the web requests that match the rules.
  DOC
}

variable "rate_based_statement_rules" {
  type = list(object({
    name     = string
    priority = number
    action   = string
    captcha_config = optional(object({
      immunity_time_property = object({
        immunity_time = number
      })
    }), null)
    rule_label = optional(list(string), null)
    statement = object({
      limit                 = number
      aggregate_key_type    = string
      evaluation_window_sec = optional(number)
      forwarded_ip_config = optional(object({
        fallback_behavior = string
        header_name       = string
      }), null)
      scope_down_statement = optional(object({
        byte_match_statement = object({
          positional_constraint = string
          search_string         = string
          field_to_match = object({
            all_query_arguments   = optional(bool)
            body                  = optional(bool)
            method                = optional(bool)
            query_string          = optional(bool)
            single_header         = optional(object({ name = string }))
            single_query_argument = optional(object({ name = string }))
            uri_path              = optional(bool)
          })
          text_transformation = list(object({
            priority = number
            type     = string
          }))
        })
      }), null)
    })
    visibility_config = optional(object({
      cloudwatch_metrics_enabled = optional(bool)
      metric_name                = string
      sampled_requests_enabled   = optional(bool)
    }), null)
  }))
  default     = null
  description = <<-DOC
    A rate-based rule tracks the rate of requests for each originating IP address,
    and triggers the rule action when the rate exceeds a limit that you specify on the number of requests in any 5-minute time span.

    action:
      The action that AWS WAF should take on a web request when it matches the rule's statement.
    name:
      A friendly name of the rule.
    priority:
      If you define more than one Rule in a WebACL,
      AWS WAF evaluates each request against the rules in order based on the value of priority.
      AWS WAF processes rules with lower priority first.

    captcha_config:
     Specifies how AWS WAF should handle CAPTCHA evaluations.

     immunity_time_property:
       Defines custom immunity time.

       immunity_time:
       The amount of time, in seconds, that a CAPTCHA or challenge timestamp is considered valid by AWS WAF. The default setting is 300.

    rule_label:
       A List of labels to apply to web requests that match the rule match statement

    statement:
      aggregate_key_type:
         Setting that indicates how to aggregate the request counts.
         Possible values include: `FORWARDED_IP` or `IP`
      limit:
        The limit on requests per 5-minute period for a single originating IP address.
      evaluation_window_sec:
        The amount of time, in seconds, that AWS WAF should include in its request counts, looking back from the current time.
        Valid values are 60, 120, 300, and 600. Defaults to 300 (5 minutes).
      forwarded_ip_config:
        fallback_behavior:
          The match status to assign to the web request if the request doesn't have a valid IP address in the specified position.
          Possible values: `MATCH`, `NO_MATCH`
        header_name:
          The name of the HTTP header to use for the IP address.
      byte_match_statement:
        field_to_match:
          Part of a web request that you want AWS WAF to inspect.
        positional_constraint:
          Area within the portion of a web request that you want AWS WAF to search for search_string.
          Valid values include the following: `EXACTLY`, `STARTS_WITH`, `ENDS_WITH`, `CONTAINS`, `CONTAINS_WORD`.
        search_string:
          String value that you want AWS WAF to search for.
          AWS WAF searches only in the part of web requests that you designate for inspection in `field_to_match`.
          The maximum length of the value is 50 bytes.
        text_transformation:
          Text transformations eliminate some of the unusual formatting that attackers use in web requests in an effort to bypass detection.
          See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl#text-transformation

    visibility_config:
      Defines and enables Amazon CloudWatch metrics and web request sample collection.

      cloudwatch_metrics_enabled:
        Whether the associated resource sends metrics to CloudWatch.
      metric_name:
        A friendly name of the CloudWatch metric.
      sampled_requests_enabled:
        Whether AWS WAF should store a sampling of the web requests that match the rules.
  DOC
}

variable "regex_pattern_set_reference_statement_rules" {
  type = list(object({
    name     = string
    priority = number
    action   = string
    captcha_config = optional(object({
      immunity_time_property = object({
        immunity_time = number
      })
    }), null)
    rule_label = optional(list(string), null)
    statement  = any
    visibility_config = optional(object({
      cloudwatch_metrics_enabled = optional(bool)
      metric_name                = string
      sampled_requests_enabled   = optional(bool)
    }), null)
  }))
  default     = null
  description = <<-DOC
    A rule statement used to search web request components for matches with regular expressions.

    action:
      The action that AWS WAF should take on a web request when it matches the rule's statement.
    name:
      A friendly name of the rule.
    priority:
      If you define more than one Rule in a WebACL,
      AWS WAF evaluates each request against the rules in order based on the value of priority.
      AWS WAF processes rules with lower priority first.

    captcha_config:
     Specifies how AWS WAF should handle CAPTCHA evaluations.

     immunity_time_property:
       Defines custom immunity time.

       immunity_time:
       The amount of time, in seconds, that a CAPTCHA or challenge timestamp is considered valid by AWS WAF. The default setting is 300.

    rule_label:
       A List of labels to apply to web requests that match the rule match statement

    statement:
      arn:
         The Amazon Resource Name (ARN) of the Regex Pattern Set that this statement references.
      field_to_match:
        The part of a web request that you want AWS WAF to inspect.
        See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl#field-to-match
      text_transformation:
        Text transformations eliminate some of the unusual formatting that attackers use in web requests in an effort to bypass detection.
        See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl#text-transformation

    visibility_config:
      Defines and enables Amazon CloudWatch metrics and web request sample collection.

      cloudwatch_metrics_enabled:
        Whether the associated resource sends metrics to CloudWatch.
      metric_name:
        A friendly name of the CloudWatch metric.
      sampled_requests_enabled:
        Whether AWS WAF should store a sampling of the web requests that match the rules.
  DOC
}

variable "regex_match_statement_rules" {
  type = list(object({
    name     = string
    priority = number
    action   = string
    captcha_config = optional(object({
      immunity_time_property = object({
        immunity_time = number
      })
    }), null)
    rule_label = optional(list(string), null)
    statement  = any
    visibility_config = optional(object({
      cloudwatch_metrics_enabled = optional(bool)
      metric_name                = string
      sampled_requests_enabled   = optional(bool)
    }), null)
  }))
  default     = null
  description = <<-DOC
    A rule statement used to search web request components for a match against a single regular expression.

    action:
      The action that AWS WAF should take on a web request when it matches the rule's statement.
    name:
      A friendly name of the rule.
    priority:
      If you define more than one Rule in a WebACL,
      AWS WAF evaluates each request against the rules in order based on the value of priority.
      AWS WAF processes rules with lower priority first.

    captcha_config:
     Specifies how AWS WAF should handle CAPTCHA evaluations.

     immunity_time_property:
       Defines custom immunity time.

       immunity_time:
       The amount of time, in seconds, that a CAPTCHA or challenge timestamp is considered valid by AWS WAF. The default setting is 300.

    rule_label:
       A List of labels to apply to web requests that match the rule match statement

    statement:
      regex_string:
         String representing the regular expression. Minimum of 1 and maximum of 512 characters.
      field_to_match:
        The part of a web request that you want AWS WAF to inspect.
        See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl.html#field_to_match
      text_transformation:
        Text transformations eliminate some of the unusual formatting that attackers use in web requests in an effort to bypass detection. At least one required.
        See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl#text-transformation

    visibility_config:
      Defines and enables Amazon CloudWatch metrics and web request sample collection.

      cloudwatch_metrics_enabled:
        Whether the associated resource sends metrics to CloudWatch.
      metric_name:
        A friendly name of the CloudWatch metric.
      sampled_requests_enabled:
        Whether AWS WAF should store a sampling of the web requests that match the rules.
  DOC
}

variable "rule_group_reference_statement_rules" {
  type = list(object({
    name            = string
    priority        = number
    override_action = optional(string)
    captcha_config = optional(object({
      immunity_time_property = object({
        immunity_time = number
      })
    }), null)
    rule_label = optional(list(string), null)
    statement = object({
      arn = string
      rule_action_override = optional(map(object({
        action = string
        custom_request_handling = optional(object({
          insert_header = object({
            name  = string
            value = string
          })
        }), null)
        custom_response = optional(object({
          response_code = string
          response_header = optional(object({
            name  = string
            value = string
          }), null)
        }), null)
      })), null)
    })
    visibility_config = optional(object({
      cloudwatch_metrics_enabled = optional(bool)
      metric_name                = string
      sampled_requests_enabled   = optional(bool)
    }), null)
  }))
  default     = null
  description = <<-DOC
    A rule statement used to run the rules that are defined in an WAFv2 Rule Group.

    name:
      A friendly name of the rule.
    priority:
      If you define more than one Rule in a WebACL,
      AWS WAF evaluates each request against the rules in order based on the value of priority.
      AWS WAF processes rules with lower priority first.

    override_action:
      The override action to apply to the rules in a rule group.
      Possible values: `count`, `none`

    captcha_config:
     Specifies how AWS WAF should handle CAPTCHA evaluations.

     immunity_time_property:
       Defines custom immunity time.

       immunity_time:
       The amount of time, in seconds, that a CAPTCHA or challenge timestamp is considered valid by AWS WAF. The default setting is 300.

    rule_label:
       A List of labels to apply to web requests that match the rule match statement

    statement:
      arn:
        The ARN of the `aws_wafv2_rule_group` resource.
      rule_action_override:
        Action settings to use in the place of the rule actions that are configured inside the rule group.
        You specify one override for each rule whose action you want to change.

    visibility_config:
      Defines and enables Amazon CloudWatch metrics and web request sample collection.

      cloudwatch_metrics_enabled:
        Whether the associated resource sends metrics to CloudWatch.
      metric_name:
        A friendly name of the CloudWatch metric.
      sampled_requests_enabled:
        Whether AWS WAF should store a sampling of the web requests that match the rules.
  DOC
}

variable "size_constraint_statement_rules" {
  type = list(object({
    name     = string
    priority = number
    action   = string
    captcha_config = optional(object({
      immunity_time_property = object({
        immunity_time = number
      })
    }), null)
    rule_label = optional(list(string), null)
    statement  = any
    visibility_config = optional(object({
      cloudwatch_metrics_enabled = optional(bool)
      metric_name                = string
      sampled_requests_enabled   = optional(bool)
    }), null)
  }))
  default     = null
  description = <<-DOC
    A rule statement that uses a comparison operator to compare a number of bytes against the size of a request component.

    action:
      The action that AWS WAF should take on a web request when it matches the rule's statement.
    name:
      A friendly name of the rule.
    priority:
      If you define more than one Rule in a WebACL,
      AWS WAF evaluates each request against the rules in order based on the value of priority.
      AWS WAF processes rules with lower priority first.

    captcha_config:
     Specifies how AWS WAF should handle CAPTCHA evaluations.

     immunity_time_property:
       Defines custom immunity time.

       immunity_time:
       The amount of time, in seconds, that a CAPTCHA or challenge timestamp is considered valid by AWS WAF. The default setting is 300.

    rule_label:
       A List of labels to apply to web requests that match the rule match statement

    statement:
      comparison_operator:
         The operator to use to compare the request part to the size setting.
         Possible values: `EQ`, `NE`, `LE`, `LT`, `GE`, or `GT`.
      size:
        The size, in bytes, to compare to the request part, after any transformations.
        Valid values are integers between `0` and `21474836480`, inclusive.
      field_to_match:
        The part of a web request that you want AWS WAF to inspect.
        See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl#field-to-match
      text_transformation:
        Text transformations eliminate some of the unusual formatting that attackers use in web requests in an effort to bypass detection.
        See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl#text-transformation

    visibility_config:
      Defines and enables Amazon CloudWatch metrics and web request sample collection.

      cloudwatch_metrics_enabled:
        Whether the associated resource sends metrics to CloudWatch.
      metric_name:
        A friendly name of the CloudWatch metric.
      sampled_requests_enabled:
        Whether AWS WAF should store a sampling of the web requests that match the rules.
  DOC
}

variable "sqli_match_statement_rules" {
  type = list(object({
    name     = string
    priority = number
    action   = string
    captcha_config = optional(object({
      immunity_time_property = object({
        immunity_time = number
      })
    }), null)
    rule_label = optional(list(string), null)
    statement  = any
    visibility_config = optional(object({
      cloudwatch_metrics_enabled = optional(bool)
      metric_name                = string
      sampled_requests_enabled   = optional(bool)
    }), null)
  }))
  default     = null
  description = <<-DOC
    An SQL injection match condition identifies the part of web requests,
    such as the URI or the query string, that you want AWS WAF to inspect.

    action:
      The action that AWS WAF should take on a web request when it matches the rule's statement.
    name:
      A friendly name of the rule.
    priority:
      If you define more than one Rule in a WebACL,
      AWS WAF evaluates each request against the rules in order based on the value of priority.
      AWS WAF processes rules with lower priority first.

    rule_label:
       A List of labels to apply to web requests that match the rule match statement

    captcha_config:
     Specifies how AWS WAF should handle CAPTCHA evaluations.

     immunity_time_property:
       Defines custom immunity time.

       immunity_time:
       The amount of time, in seconds, that a CAPTCHA or challenge timestamp is considered valid by AWS WAF. The default setting is 300.

    statement:
      field_to_match:
        The part of a web request that you want AWS WAF to inspect.
        See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl#field-to-match
      text_transformation:
        Text transformations eliminate some of the unusual formatting that attackers use in web requests in an effort to bypass detection.
        See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl#text-transformation

    visibility_config:
      Defines and enables Amazon CloudWatch metrics and web request sample collection.

      cloudwatch_metrics_enabled:
        Whether the associated resource sends metrics to CloudWatch.
      metric_name:
        A friendly name of the CloudWatch metric.
      sampled_requests_enabled:
        Whether AWS WAF should store a sampling of the web requests that match the rules.
  DOC
}

variable "xss_match_statement_rules" {
  type = list(object({
    name     = string
    priority = number
    action   = string
    captcha_config = optional(object({
      immunity_time_property = object({
        immunity_time = number
      })
    }), null)
    rule_label = optional(list(string), null)
    statement  = any
    visibility_config = optional(object({
      cloudwatch_metrics_enabled = optional(bool)
      metric_name                = string
      sampled_requests_enabled   = optional(bool)
    }), null)
  }))
  default     = null
  description = <<-DOC
    A rule statement that defines a cross-site scripting (XSS) match search for AWS WAF to apply to web requests.

    action:
      The action that AWS WAF should take on a web request when it matches the rule's statement.
    name:
      A friendly name of the rule.
    priority:
      If you define more than one Rule in a WebACL,
      AWS WAF evaluates each request against the rules in order based on the value of priority.
      AWS WAF processes rules with lower priority first.

    captcha_config:
     Specifies how AWS WAF should handle CAPTCHA evaluations.

     immunity_time_property:
       Defines custom immunity time.

       immunity_time:
       The amount of time, in seconds, that a CAPTCHA or challenge timestamp is considered valid by AWS WAF. The default setting is 300.

    rule_label:
       A List of labels to apply to web requests that match the rule match statement

    statement:
      field_to_match:
        The part of a web request that you want AWS WAF to inspect.
        See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl#field-to-match
      text_transformation:
        Text transformations eliminate some of the unusual formatting that attackers use in web requests in an effort to bypass detection.
        See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl#text-transformation

    visibility_config:
      Defines and enables Amazon CloudWatch metrics and web request sample collection.

      cloudwatch_metrics_enabled:
        Whether the associated resource sends metrics to CloudWatch.
      metric_name:
        A friendly name of the CloudWatch metric.
      sampled_requests_enabled:
        Whether AWS WAF should store a sampling of the web requests that match the rules.
  DOC
}

# Logging configuration
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl_logging_configuration.html
variable "log_destination_configs" {
  type        = list(string)
  default     = []
  description = <<-DOC
    A list of resource names/ARNs to associate Amazon Kinesis Data Firehose, Cloudwatch Log log group, or S3 bucket with the WAF logs.
    Note: data firehose, log group, or bucket name must be prefixed with `aws-waf-logs-`,
    e.g. `aws-waf-logs-example-firehose`, `aws-waf-logs-example-log-group`, or `aws-waf-logs-example-bucket`.
  DOC
}

variable "redacted_fields" {
  type = map(object({
    method        = optional(bool, false)
    uri_path      = optional(bool, false)
    query_string  = optional(bool, false)
    single_header = optional(list(string), null)
  }))
  default     = {}
  description = <<-DOC
    The parts of the request that you want to keep out of the logs.
    You can only specify one of the following: `method`, `query_string`, `single_header`, or `uri_path`

    method:
      Whether to enable redaction of the HTTP method.
      The method indicates the type of operation that the request is asking the origin to perform.
    uri_path:
      Whether to enable redaction of the URI path.
      This is the part of a web request that identifies a resource.
    query_string:
      Whether to enable redaction of the query string.
      This is the part of a URL that appears after a `?` character, if any.
    single_header:
      The list of names of the query headers to redact.
  DOC
  nullable    = false
}

variable "logging_filter" {
  type = object({
    default_behavior = string
    filter = list(object({
      behavior    = string
      requirement = string
      condition = list(object({
        action_condition = optional(object({
          action = string
        }), null)
        label_name_condition = optional(object({
          label_name = string
        }), null)
      }))
    }))
  })
  default     = null
  description = <<-DOC
    A configuration block that specifies which web requests are kept in the logs and which are dropped.
    You can filter on the rule action and on the web request labels that were applied by matching rules during web ACL evaluation.
  DOC
}

variable "log_destination_component_selectors" {
  type = list(object({
    component        = string
    namespace        = optional(string, null)
    tenant           = optional(string, null)
    environment      = optional(string, null)
    stage            = optional(string, null)
    component_output = string
  }))
  default     = []
  description = <<-DOC
    A list of Atmos component selectors to get from the remote state and associate their names/ARNs with the WAF logs.
    The components must be Amazon Kinesis Data Firehose, CloudWatch Log Group, or S3 bucket.

    component:
      Atmos component name
    component_output:
      The component output that defines the component name or ARN

    Set `tenant`, `environment` and `stage` if the components are in different OUs, regions or accounts.

    Note: data firehose, log group, or bucket name must be prefixed with `aws-waf-logs-`,
    e.g. `aws-waf-logs-example-firehose`, `aws-waf-logs-example-log-group`, or `aws-waf-logs-example-bucket`.
 DOC
  nullable    = false
}

# Association resources
variable "association_resource_arns" {
  type        = list(string)
  default     = []
  description = <<-DOC
    A list of ARNs of the resources to associate with the web ACL.
    This must be an ARN of an Application Load Balancer, Amazon API Gateway stage, or AWS AppSync.

    Do not use this variable to associate a Cloudfront Distribution.
    Instead, you should use the `web_acl_id` property on the `cloudfront_distribution` resource.
    For more details, refer to https://docs.aws.amazon.com/waf/latest/APIReference/API_AssociateWebACL.html
  DOC
  nullable    = false
}

variable "association_resource_component_selectors" {
  type = list(object({
    component            = string
    namespace            = optional(string, null)
    tenant               = optional(string, null)
    environment          = optional(string, null)
    stage                = optional(string, null)
    component_arn_output = string
  }))
  default     = []
  description = <<-DOC
    A list of Atmos component selectors to get from the remote state and associate their ARNs with the web ACL.
    The components must be Application Load Balancers, Amazon API Gateway stages, or AWS AppSync.

    component:
      Atmos component name
    component_arn_output:
      The component output that defines the component ARN

    Set `tenant`, `environment` and `stage` if the components are in different OUs, regions or accounts.

    Do not use this variable to select a Cloudfront Distribution component.
    Instead, you should use the `web_acl_id` property on the `cloudfront_distribution` resource.
    For more details, refer to https://docs.aws.amazon.com/waf/latest/APIReference/API_AssociateWebACL.html
  DOC
  nullable    = false
}
