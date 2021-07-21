# This file is included by default in terraform plans

enabled = true

service_control_policies_config_paths = [
  "https://raw.githubusercontent.com/cloudposse/terraform-aws-service-control-policies/0.8.0/catalog/cloudwatch-logs-policies.yaml",
  "https://raw.githubusercontent.com/cloudposse/terraform-aws-service-control-policies/0.8.0/catalog/deny-all-policies.yaml",
  "https://raw.githubusercontent.com/cloudposse/terraform-aws-service-control-policies/0.8.0/catalog/ec2-policies.yaml",
  "https://raw.githubusercontent.com/cloudposse/terraform-aws-service-control-policies/0.8.0/catalog/iam-policies.yaml",
  "https://raw.githubusercontent.com/cloudposse/terraform-aws-service-control-policies/0.8.0/catalog/kms-policies.yaml",
  "https://raw.githubusercontent.com/cloudposse/terraform-aws-service-control-policies/0.8.0/catalog/organization-policies.yaml",
  "https://raw.githubusercontent.com/cloudposse/terraform-aws-service-control-policies/0.8.0/catalog/route53-policies.yaml",
  "https://raw.githubusercontent.com/cloudposse/terraform-aws-service-control-policies/0.8.0/catalog/s3-policies.yaml"
]
