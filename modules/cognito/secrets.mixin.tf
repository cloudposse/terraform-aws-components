# secrets.mixin.tf provides an abstract way for components to consume secret values from external sources
# Right now, this includes SOPS files or SSM Parameter, but it could be expanded to include more like AWS Secrets Manager + Hashi Vault
# This enables component users to bring their own secrets and allows component authors to not have to concern their code with where secrets will live
# The secret_mapping variable provides the input to map where a secret at a particular name should be pulled from.
# All secrets that are pulled are provided to the component via `local.secrets`
# NOTE: This does require the carlpett/sops provider regardless if sops is used or not.
# NOTE: This could be expanded in the future to pull non-secret values as well if that is ever of use.

variable "secret_mapping" {
  type = list(object({
    name = string
    type = string
    path = string
    file = string
  }))
  default     = []
  description = "The list of secret mappings the application will need. This creates secret values for the component to consume at `local.secrets[name]`."
}

locals {
  # Filter out our sops mappings
  sops_secret_mapping = [
    for mapping in var.secret_mapping :
    mapping if mapping.type == "sops"
  ]

  # Filter the unique set of sops files we need to pull
  sops_files = toset(distinct([
    for mapping in local.sops_secret_mapping :
    mapping.file
  ]))

  # Collect our sops file values as a map of "sops file path => map of values"
  sops_yamls = {
    for sops_file in local.sops_files :
    sops_file => yamldecode(data.sops_file.sops_secrets[sops_file].raw)
  }

  # Create our sops secret name to value map
  sops_secrets = {
    for mapping in local.sops_secret_mapping :
    mapping.name => lookup(local.sops_yamls[mapping.file], mapping.path, null)
  }

  # Filter out our ssm mappings
  ssm_secret_mapping = [
    for mapping in var.secret_mapping :
    mapping if mapping.type == "ssm"
  ]

  # Collect the ssm paths we need to pull
  ssm_paths = toset(distinct([
    for mapping in local.ssm_secret_mapping :
    mapping.path
  ]))

  # Create our ssm secret name to value map
  ssm_secrets = {
    for mapping in local.ssm_secret_mapping :
    mapping.name => data.aws_ssm_parameter.ssm_secrets[mapping.path].value
  }

  # Merge the final ssm secrets + sops secrets for generic consumption in the component.
  secrets = merge(local.sops_secrets, local.ssm_secrets)
}

data "sops_file" "sops_secrets" {
  for_each    = local.sops_files
  source_file = "${path.root}/${each.value}"
}

data "aws_ssm_parameter" "ssm_secrets" {
  for_each = local.ssm_paths
  name     = each.value
}
