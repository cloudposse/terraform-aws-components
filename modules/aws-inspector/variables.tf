variable "region" {
  type        = string
  description = "AWS region"
}

variable "enabled_rules" {
  type        = list(string)
  default     = []
  description = <<-DOC
    A list of AWS Inspector rules that should run on a periodic basis.

    Valid values are `cve`, `cis`, `nr`, `sbp` which map to the appropriate [Inspector rule arns by region](https://docs.aws.amazon.com/inspector/latest/userguide/inspector_rules-arns.html).
  DOC
}
