locals {
  metadata = {
    kube_version = {
      component = var.eks_component_name
      output    = "eks_cluster_version"
    }
  }
}

module "store_write" {
  source  = "cloudposse/ssm-parameter-store/aws"
  version = "0.11.0"

  parameter_write = concat(
    [for k, v in var.references :
      {
        name        = format("%s/%s", format(var.ssm_platform_path, module.eks.outputs.eks_cluster_id, var.platform_environment), k)
        value       = local.result[k]
        type        = "SecureString"
        overwrite   = true
        description = "Platform config for ${var.platform_environment} at ${module.eks.outputs.eks_cluster_id} cluster"
      }
    ],
    [for k, v in local.metadata :
      {
        name        = format("%s/%s", format(var.ssm_platform_path, module.eks.outputs.eks_cluster_id, "_metadata"), k)
        value       = lookup(module.remote[k].outputs, v.output)
        type        = "SecureString"
        overwrite   = true
        description = "Platform metadata for ${module.eks.outputs.eks_cluster_id} cluster"
      }
  ])

  context = module.this.context
}

data "jq_query" "default" {
  for_each = var.references
  data     = jsonencode(module.remote[each.key].outputs)
  # Query is left to be free form since setting this to something like `.` would
  # mean you cannot handle arrays. For example, if you wanted to get the first
  # element of an array, you would need to use `[0]` as the query, but having a
  # query of `.` would not allow you to do that. It would render as '.[0]'
  query = each.value.output
}

locals {
  result = { for k, v in data.jq_query.default : k => jsondecode(v.result) }
}
