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
  type        = list(any)
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
  type        = list(any)
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
  type        = list(any)
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
  type        = list(any)
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
  type        = list(any)
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
  type        = list(any)
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

variable "regex_pattern_set_reference_statement_rules" {
  type        = list(any)
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
  type        = list(any)
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
  type        = list(any)
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
  type        = list(any)
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
  type        = list(any)
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
  type        = list(any)
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
