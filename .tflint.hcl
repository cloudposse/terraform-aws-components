# https://github.com/terraform-linters/tflint-ruleset-aws
plugin "aws" {
  enabled    = true
  version    = "0.8.0"
  source     = "github.com/terraform-linters/tflint-ruleset-aws"
  deep_check = true
}

rule "aws_resource_missing_tags" {
  enabled = true
  tags    = ["namespace"]
}

rule "terraform_deprecated_index" { enabled = true }
rule "terraform_unused_declarations" { enabled = true } 
rule "terraform_documented_outputs" { enabled = true }
rule "terraform_required_providers" { enabled = true }
rule "terraform_unused_required_providers" { enabled = true }
