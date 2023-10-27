variable "region" {
  type        = string
  description = "AWS Region"
}

variable "datadog_aws_account_id" {
  type        = string
  description = "The AWS account ID Datadog's integration servers use for all integrations"
  default     = "464622532012"
}

variable "integrations" {
  type        = list(string)
  description = "List of AWS permission names to apply for different integrations (e.g. 'all', 'core')"
  default     = ["all"]
}

variable "filter_tags" {
  type        = list(string)
  description = "An array of EC2 tags (in the form `key:value`) that defines a filter that Datadog use when collecting metrics from EC2. Wildcards, such as ? (for single characters) and * (for multiple characters) can also be used"
  default     = []
}

variable "host_tags" {
  type        = list(string)
  description = "An array of tags (in the form `key:value`) to add to all hosts and metrics reporting through this integration"
  default     = []
}

variable "excluded_regions" {
  type        = list(string)
  description = "An array of AWS regions to exclude from metrics collection"
  default     = []
}

variable "included_regions" {
  type        = list(string)
  description = "An array of AWS regions to include in metrics collection"
  default     = []
}
variable "account_specific_namespace_rules" {
  type        = map(string)
  description = "An object, (in the form {\"namespace1\":true/false, \"namespace2\":true/false} ), that enables or disables metric collection for specific AWS namespaces for this AWS account only"
  default     = {}
}

variable "context_host_and_filter_tags" {
  type        = list(string)
  description = "Automatically add host and filter tags for these context keys"
  default     = ["namespace", "tenant", "stage"]
}

variable "cspm_resource_collection_enabled" {
  type        = bool
  default     = null
  description = <<-EOT
    Enable Datadog Cloud Security Posture Management scanning of your AWS account.
    See [announcement](https://www.datadoghq.com/product/cloud-security-management/cloud-security-posture-management/) for details.
    EOT
}

variable "metrics_collection_enabled" {
  type        = bool
  default     = null
  description = <<-EOT
    When enabled, a metric-by-metric crawl of the CloudWatch API pulls data and sends it
    to Datadog. New metrics are pulled every ten minutes, on average.
    EOT
}

variable "resource_collection_enabled" {
  type        = bool
  default     = null
  description = <<-EOT
    Some Datadog products leverage information about how your AWS resources
    (such as S3 Buckets, RDS snapshots, and CloudFront distributions) are configured.
    When `resource_collection_enabled` is `true`, Datadog collects this information
    by making read-only API calls into your AWS account.
    EOT
}
