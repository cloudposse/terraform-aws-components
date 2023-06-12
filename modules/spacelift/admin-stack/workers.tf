locals {
  # This loops through all of the stacks in the atmos config and extracts the worker_name. It then creates a set of all
  # of the unique worker_names so we can use that to make sure that the worker pool exists in Spacelift.
  #
  # If a worker pool is not defined in the atmos config, then it will default to a fake "public" value so we can
  # check below if any stacks are configured to use public workers.
  unique_workers_from_config = toset([for k, v in {
    for k, v in module.child_stacks_config.spacelift_stacks : k => coalesce(try(v.settings.spacelift.worker_pool_name, var.worker_pool_name), "public")
    if try(v.settings.spacelift.workspace_enabled, false) == true
  } : v])

  # Create a map of all the worker pools that exist in spacelift {worker_pool_name = worker_pool_id}
  worker_pools = { for k, v in data.spacelift_worker_pools.this.worker_pools : v.name => v.worker_pool_id }

  # Create a list of all the worker pools that are defined in config but missing from Spacelift
  missing_workers = setunion(setsubtract(local.unique_workers_from_config, keys(local.worker_pools)))
}

data "spacelift_worker_pools" "this" {
}

# Ensure no stacks are configured to use public workers if they are not allowed
resource "null_resource" "public_workers_precondition" {
  count = local.enabled ? 1 : 0
  lifecycle {
    precondition {
      condition     = var.allow_public_workers == true || contains(local.missing_workers, "public") == false
      error_message = "Use of public workers is not allowed. Please create worker pool(s) in Spacelift and assign all stacks to a worker before running this module."
    }
  }
}

# Ensure all of the spaces referenced in the atmos config exist in Spacelift
resource "null_resource" "workers_precondition" {
  count = local.enabled ? 1 : 0

  depends_on = [null_resource.public_workers_precondition]

  lifecycle {
    precondition {
      condition = (var.allow_public_workers == false && length(local.missing_workers) == 0) || (
        var.allow_public_workers == true &&
        length(local.missing_workers) == 1
        && contains(local.missing_workers, "public")
      )
      error_message = "Please create the following workers in Spacelift before running this module: ${join(", ", local.missing_workers)}"
    }
  }
}
