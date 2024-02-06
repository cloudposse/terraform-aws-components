# Required `tflint --init`
plugin "aws" {
    enabled    = true
    version    = "0.23.1"
    source     = "github.com/terraform-linters/tflint-ruleset-aws"
    # Used only in Spacelift: .spacelift/config.yml
    deep_check = false
    assume_role { role_arn = "" }

}

#
# https://github.com/terraform-linters/tflint/tree/master/docs/rules
#

rule "terraform_comment_syntax" {
    # Disallow `//` comments in favor of `#`
    enabled = true
}
rule "terraform_deprecated_index" {
    # Disallow legacy dot index syntax
    enabled = true
}
rule "terraform_deprecated_interpolation" {
    # Disallow deprecated (0.11-style) interpolation
    # Enabled by default
    enabled = true
}
rule "terraform_documented_outputs" {
    # Disallow output declarations without description
    enabled = true
}
rule "terraform_documented_variables" {
    # Disallow variable declarations without description
    enabled = true
}
rule "terraform_module_pinned_source" {
    # Disallow specifying a git or mercurial repository as a module source without pinning to a version
    # Enabled by default
    enabled = true
}
rule "terraform_module_version" {
    # Checks that Terraform modules sourced from a registry specify a version
    # Enabled by default
    enabled = true
}
rule "terraform_naming_convention" {
    # Enforces naming conventions for resources, data sources, etc
    enabled = true
}
rule "terraform_required_providers" {
    # Require that all providers have version constraints through required_providers
    enabled = true
}
rule "terraform_required_version" {
    # Disallow terraform declarations without require_version
    enabled = true
}
rule "terraform_standard_module_structure" {
    # Ensure that a module complies with the Terraform Standard Module Structure
    enabled = false # TODO p4: enable and fix
}
rule "terraform_typed_variables" {
    # Disallow variable declarations without type
    enabled = true
}
rule "terraform_unused_declarations" {
    # Disallow variables, data sources, and locals that are declared but never used
    enabled = true
}
rule "terraform_unused_required_providers" {
    # Check that all required_providers are used in the module
    enabled = true
}
rule "terraform_workspace_remote" {
    # terraform.workspace should not be used with a "remote" backend with remote execution.
    # Enabled by default
    enabled = true
}
rule "aws_db_instance_invalid_parameter_group" {
    # TODO: Figure out requirements to turn this back on; not sure it's providing value even as is due to AWS multi-account arch.
    enabled = false
}
config {
    variables = ["namespace=fake-namespace", "stage=fake-stage", "name=fake-name"]
}
