locals {
  kubernetes_labels                  = { for k, v in merge(module.this.tags, { name = var.kubernetes_namespace }) : k => replace(v, "/", "_") if local.enabled }
  kubernetes_role_name               = format("%s-service-account", var.kubernetes_service_account_name)
  kubernetes_service_account_enabled = local.enabled && var.kubernetes_service_account_enabled
}

# Create Kubernetes secret for the workers running on Kubernetes to connect to Spacelift servers
resource "kubernetes_secret" "default" {
  count = local.enabled ? 1 : 0

  metadata {
    name      = module.this.name
    namespace = var.kubernetes_namespace
    labels    = local.kubernetes_labels
  }

  data = {
    token      = one(spacelift_worker_pool.default[*].config)
    privateKey = one(spacelift_worker_pool.default[*].private_key)
  }
}

# https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account_v1
resource "kubernetes_service_account_v1" "default" {
  count = local.kubernetes_service_account_enabled ? 1 : 0

  metadata {
    name      = var.kubernetes_service_account_name
    namespace = var.kubernetes_namespace
    labels    = local.kubernetes_labels

    annotations = {
      "eks.amazonaws.com/role-arn" = module.eks_iam_role.service_account_role_arn
    }
  }
}

# Before using the service account with a Pod, the service account must be bound to an existing Kubernetes Role,
# or ClusterRole that includes the Kubernetes permissions that you require for the service account.
# https://docs.aws.amazon.com/eks/latest/userguide/associate-service-account-role.html
# https://docs.aws.amazon.com/eks/latest/userguide/pod-configuration.html
# https://kubernetes.io/docs/reference/access-authn-authz/rbac/

# https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/role_v1
resource "kubernetes_role_v1" "default" {
  count = local.kubernetes_service_account_enabled ? 1 : 0

  metadata {
    name      = local.kubernetes_role_name
    namespace = var.kubernetes_namespace
    labels    = local.kubernetes_labels
  }

  rule {
    api_groups     = var.kubernetes_role_api_groups
    resources      = var.kubernetes_role_resources
    resource_names = var.kubernetes_role_resource_names
    verbs          = var.kubernetes_role_verbs
  }
}

# https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/role_binding_v1
resource "kubernetes_role_binding_v1" "default" {
  count = local.kubernetes_service_account_enabled ? 1 : 0

  metadata {
    name      = local.kubernetes_role_name
    namespace = var.kubernetes_namespace
    labels    = local.kubernetes_labels
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = try(kubernetes_role_v1.default[0].metadata[0].name, "")
  }

  subject {
    api_group = null
    kind      = "ServiceAccount"
    name      = try(kubernetes_service_account_v1.default[0].metadata[0].name, "")
    namespace = var.kubernetes_namespace
  }
}

# Create worker pools in Kubernetes
# https://docs.spacelift.io/concepts/worker-pools#configuration
resource "kubernetes_manifest" "spacelift_worker_pool" {
  count = local.enabled ? 1 : 0

  field_manager {
    name            = "Terraform"
    force_conflicts = true
  }

  manifest = {
    apiVersion = "workers.spacelift.io/v1beta1"
    kind       = "WorkerPool"

    metadata = {
      name      = module.this.id
      namespace = var.kubernetes_namespace
      labels    = local.kubernetes_labels
    }

    spec = {
      poolSize = var.worker_pool_size

      # keepSuccessfulPods indicates whether run Pods should automatically be removed as soon
      # as they complete successfully, or be kept so that they can be inspected later. By default
      # run Pods are removed as soon as they complete successfully. Failed Pods are not automatically
      # removed to allow debugging.
      keepSuccessfulPods = var.keep_successful_pods

      # `token` and `privateKey` are used by the workers to communicate with Spacelift servers
      token = {
        secretKeyRef = {
          name = module.this.name
          key  = "token"
        }
      }

      privateKey = {
        secretKeyRef = {
          name = module.this.name
          key  = "privateKey"
        }
      }

      pod = merge({
        serviceAccountName           = local.kubernetes_service_account_enabled ? var.kubernetes_service_account_name : null
        automountServiceAccountToken = local.kubernetes_service_account_enabled ? true : false

        # activeDeadlineSeconds defines the length of time in seconds before which the Pod will
        # be marked as failed. This can be used to set a deadline for your runs.
        activeDeadlineSeconds = var.worker_spec.active_deadline_seconds

        terminationGracePeriodSeconds = var.worker_spec.termination_grace_period_seconds

        annotations  = var.worker_spec.annotations
        nodeSelector = var.worker_spec.node_selector
        tolerations  = var.worker_spec.tolerations

        labels = local.kubernetes_labels

        # Init container resource limits only matter if they are greater than the worker container resources.
        # See: https://kubernetes.io/docs/concepts/workloads/pods/init-containers/#resource-sharing-within-containers
        # So we give the init container the same resources as the worker container.
        initContainer = {
          resources = var.worker_spec.resources
        }

        grpcServerContainer = {
          resources = var.grpc_server_resources
        }

        workerContainer = {
          resources = var.worker_spec.resources
          env = [
            {
              "name"  = "AWS_CONFIG_FILE"
              "value" = var.aws_config_file
            },
            {
              "name"  = "AWS_PROFILE"
              "value" = coalesce(var.aws_profile, "${module.this.namespace}-identity")
            },
            {
              "name"  = "AWS_SDK_LOAD_CONFIG"
              "value" = true
            },
            {
              name  = "SPACELIFT_IN_KUBERNETES"
              value = true
            },
            {
              name  = "SPACELIFT_WHITELIST_ENVS"
              value = "AWS_ACCESS_KEY_ID,AWS_SECRET_ACCESS_KEY,AWS_SESSION_TOKEN,AWS_SDK_LOAD_CONFIG,AWS_CONFIG_FILE,AWS_PROFILE,GITHUB_TOKEN,INFRACOST_API_KEY,ATMOS_BASE_PATH,TF_VAR_terraform_user"
            },
            {
              name  = "SPACELIFT_MASK_ENVS"
              value = "AWS_SECRET_ACCESS_KEY,AWS_SESSION_TOKEN,GITHUB_TOKEN,INFRACOST_API_KEY"
            },
            {
              name  = "SPACELIFT_LAUNCHER_LOGS_TIMEOUT"
              value = "30m"
            },
            {
              name  = "SPACELIFT_LAUNCHER_RUN_TIMEOUT"
              value = "120m"
            }
          ]
        }
        },

        var.worker_spec.tmpfs_enabled ? {
          workspaceVolume = {
            name = "workspace"
            emptyDir = {
              medium = "Memory"
            }
          }
        } : {}
      )
    }
  }


  depends_on = [
    kubernetes_secret.default,
    kubernetes_service_account_v1.default,
    kubernetes_role_v1.default,
    kubernetes_role_binding_v1.default
  ]
}
