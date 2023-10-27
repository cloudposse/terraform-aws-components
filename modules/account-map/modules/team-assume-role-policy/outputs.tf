output "policy_document" {
  description = "JSON encoded string representing the \"Assume Role\" policy configured by the inputs"
  value       = join("", data.aws_iam_policy_document.assume_role[*].json)
}
