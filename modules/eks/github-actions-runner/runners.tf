locals {
  github_app_enabled   = var.github_app_id != null && var.github_app_installation_id != null
  create_github_secret = local.enabled && var.create_github_kubernetes_secret
  github_secret_name   = var.github_kubernetes_secret_name

  github_secrets = {
    app = {
      github_app_id              = var.github_app_id
      github_app_installation_id = var.github_app_installation_id
      github_app_private_key     = one(data.aws_ssm_parameter.github_token[*].value)
    }
    pat = {
      github_token = one(data.aws_ssm_parameter.github_token[*].value)
    }
  }
}

data "aws_ssm_parameter" "github_token" {
  count = local.create_github_secret ? 1 : 0

  name            = var.ssm_github_secret_path
  with_decryption = true
  provider        = aws.ssm
}

resource "kubernetes_namespace" "runner" {
  for_each = local.runner_namespaces_to_create

  metadata {
    name = each.value
  }

  # During destroy, we may need the IAM role preserved in order to run finalizers
  # which remove resources. This depends_on ensures that the IAM role is not
  # destroyed until after the namespace is destroyed.
  depends_on = [module.gha_runners.service_account_role_unique_id]
}

resource "kubernetes_secret_v1" "github_secret" {
  for_each = local.create_github_secret ? local.runner_only_namespaces : []

  metadata {
    name      = local.github_secret_name
    namespace = each.value
  }

  data = local.github_secrets[local.github_app_enabled ? "app" : "pat"]

  depends_on = [kubernetes_namespace.runner]
}

resource "kubernetes_secret_v1" "image_pull_secret" {
  for_each = local.create_image_pull_secret ? local.runner_only_namespaces : []

  metadata {
    name      = local.image_pull_secret_name
    namespace = each.value
  }

  binary_data = { ".dockercfg" = local.image_pull_secret }

  type = "kubernetes.io/dockercfg"

  depends_on = [kubernetes_namespace.runner]
}

module "gha_runners" {
  for_each = local.enabled ? local.enabled_runners : {}

  source  = "cloudposse/helm-release/aws"
  version = "0.10.0"

  name            = each.key
  chart           = coalesce(var.charts["runner_sets"].chart, local.runner_chart_name)
  repository      = var.charts["runner_sets"].chart_repository
  description     = var.charts["runner_sets"].chart_description
  chart_version   = var.charts["runner_sets"].chart_version
  wait            = var.charts["runner_sets"].wait
  atomic          = var.charts["runner_sets"].atomic
  cleanup_on_fail = var.charts["runner_sets"].cleanup_on_fail
  timeout         = var.charts["runner_sets"].timeout

  kubernetes_namespace = coalesce(each.value.kubernetes_namespace, local.controller_namespace)
  create_namespace     = false # will be created above to manage duplicate namespaces

  eks_cluster_oidc_issuer_url = module.eks.outputs.eks_cluster_identity_oidc_issuer

  iam_role_enabled = false

  values = compact([
    # hardcoded values
    try(file("${path.module}/resources/values-runner.yaml"), null),
    yamlencode({
      githubConfigUrl = each.value.github_url
      maxRunners      = each.value.max_replicas
      minRunners      = each.value.min_replicas
      runnerGroup     = each.value.group

      # Create an explicit dependency on the secret to be sure it is created first.
      githubConfigSecret = coalesce(each.value.kubernetes_namespace, local.controller_namespace) == local.controller_namespace ? (
        try(kubernetes_secret_v1.controller_ns_github_secret[local.controller_namespace].metadata[0].name, local.github_secret_name)
        ) : (
        try(kubernetes_secret_v1.github_secret[each.value.kubernetes_namespace].metadata[0].name, local.github_secret_name)
      )

      containerMode = {
        type = each.value.mode
        kubernetesModeWorkVolumeClaim = {
          accessModes      = ["ReadWriteOnce"]
          storageClassName = each.value.ephemeral_pvc_storage_class
          resources = {
            requests = {
              storage = each.value.ephemeral_pvc_storage
            }
          }
        }
        kubernetesModeServiceAccount = {
          annotations = each.value.kubernetes_mode_service_account_annotations
        }
      }
      template = {
        metadata = {
          annotations = each.value.pod_annotations
          labels      = each.value.pod_labels
        }
        spec = merge(
          local.image_pull_secret_enabled ? {
            # We want to wait until the secret is created before creating the runner,
            # but the secret might be the `controller_image_pull_secret`. That is O.K.
            # because we separately depend on the controller, which depends on the secret.
            imagePullSecrets = [{ name = try(kubernetes_secret_v1.image_pull_secret[each.value.kubernetes_namespace].metadata[0].name, var.image_pull_kubernetes_secret_name) }]
          } : {},
          try(length(each.value.ephemeral_pvc_storage), 0) > 0 ? {
            volumes = [{
              name = "work"
              ephemeral = {
                volumeClaimTemplate = {
                  spec = merge(
                    try(length(each.value.ephemeral_pvc_storage_class), 0) > 0 ? {
                      storageClassName = each.value.ephemeral_pvc_storage_class
                    } : {},
                    {
                      accessModes = ["ReadWriteOnce"]
                      resources = {
                        requests = {
                          storage = each.value.ephemeral_pvc_storage
                        }
                      }
                  })
                }
              }
            }]
          } : {},
          {
            affinity     = each.value.affinity
            nodeSelector = each.value.node_selector
            tolerations  = each.value.tolerations
            containers = [merge({
              name  = "runner"
              image = each.value.image
              # command from https://github.com/actions/actions-runner-controller/blob/0bfa57ac504dfc818128f7185fc82830cbdb83f1/charts/gha-runner-scale-set/values.yaml#L193
              command = ["/home/runner/run.sh"]
              },
              each.value.resources == null ? {} : {
                resources = merge(
                  try(each.value.resources.requests, null) == null ? {} : { requests = { for k, v in each.value.resources.requests : k => v if v != null } },
                  try(each.value.resources.limits, null) == null ? {} : { limits = { for k, v in each.value.resources.limits : k => v if v != null } },
                )
              },
            )]
          }
        )
      }
    }),
    local.image_pull_secret_enabled ? yamlencode({
      listenerTemplate = {
        spec = {
          imagePullSecrets = [{ name = try(kubernetes_secret_v1.image_pull_secret[each.value.kubernetes_namespace].metadata[0].name, var.image_pull_kubernetes_secret_name) }]
          containers       = []
    } } }) : null
  ])

  # Cannot depend on the namespace directly, because that would create a circular dependency (see above).
  depends_on = [module.gha_runner_controller, kubernetes_secret_v1.controller_ns_github_secret]
}
