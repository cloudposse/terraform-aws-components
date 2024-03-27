locals {
  enabled          = module.this.enabled
  create_namespace = local.enabled

  routes = join(",", concat(var.routes, [for k, v in data.aws_subnet.vpc_subnets : v.cidr_block]))
}

module "store_read" {
  source  = "cloudposse/ssm-parameter-store/aws"
  version = "0.10.0"

  parameter_read = [
    "/tailscale/client_id",
    "/tailscale/client_secret",
  ]
}

resource "kubernetes_secret" "operator_oauth" {
  metadata {
    name      = "operator-oauth"
    namespace = var.kubernetes_namespace
  }
  data = {
    client_id     = module.store_read.map["/tailscale/client_id"]
    client_secret = module.store_read.map["/tailscale/client_secret"]
  }
}

resource "kubernetes_namespace" "default" {
  count = local.create_namespace ? 1 : 0

  metadata {
    name = var.kubernetes_namespace

    labels = module.this.tags
  }
}


resource "kubernetes_service_account" "proxies" {
  metadata {
    name      = "proxies"
    namespace = var.kubernetes_namespace
  }
}

resource "kubernetes_role" "proxies" {
  metadata {
    name      = "proxies"
    namespace = var.kubernetes_namespace
  }

  rule {
    verbs      = ["*"]
    api_groups = [""]
    resources  = ["secrets"]
  }
}

resource "kubernetes_role_binding" "proxies" {
  metadata {
    name      = "proxies"
    namespace = var.kubernetes_namespace
  }

  subject {
    kind      = "ServiceAccount"
    name      = "proxies"
    namespace = var.kubernetes_namespace
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "proxies"
  }
}

resource "kubernetes_service_account" "operator" {
  metadata {
    name      = "operator"
    namespace = var.kubernetes_namespace
  }
}

resource "kubernetes_cluster_role" "tailscale_operator" {
  metadata {
    name = "tailscale-operator"
  }

  rule {
    verbs      = ["*"]
    api_groups = [""]
    resources  = ["services", "services/status"]
  }
}

resource "kubernetes_cluster_role_binding" "tailscale_operator" {
  metadata {
    name = "tailscale-operator"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "operator"
    namespace = var.kubernetes_namespace
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "tailscale-operator"
  }
}

resource "kubernetes_role" "operator" {
  metadata {
    name      = "operator"
    namespace = var.kubernetes_namespace
  }

  rule {
    verbs      = ["*"]
    api_groups = [""]
    resources  = ["secrets"]
  }

  rule {
    verbs      = ["*"]
    api_groups = ["apps"]
    resources  = ["statefulsets"]
  }
}

resource "kubernetes_role_binding" "operator" {
  metadata {
    name      = "operator"
    namespace = var.kubernetes_namespace
  }

  subject {
    kind      = "ServiceAccount"
    name      = "operator"
    namespace = var.kubernetes_namespace
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "operator"
  }
}

resource "kubernetes_deployment" "operator" {
  metadata {
    name      = coalesce(var.deployment_name, "tailscale-operator")
    namespace = var.kubernetes_namespace
    labels = {
      app = "tailscale"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "operator"
      }
    }

    template {
      metadata {
        labels = {
          app = "operator"
        }
      }

      spec {
        volume {
          name = "oauth"

          secret {
            secret_name = "operator-oauth"
          }
        }

        container {
          image = format("%s:%s", var.image_repo, var.image_tag)
          name  = "tailscale"

          env {
            name  = "OPERATOR_HOSTNAME"
            value = format("%s-%s-%s-%s", "tailscale-operator", var.tenant, var.environment, var.stage)
          }

          env {
            name  = "OPERATOR_SECRET"
            value = "operator"
          }

          env {
            name  = "OPERATOR_LOGGING"
            value = "info"
          }

          env {
            name = "OPERATOR_NAMESPACE"

            value_from {
              field_ref {
                field_path = "metadata.namespace"
              }
            }
          }

          env {
            name  = "CLIENT_ID_FILE"
            value = "/oauth/client_id"
          }

          env {
            name  = "CLIENT_SECRET_FILE"
            value = "/oauth/client_secret"
          }

          env {
            name  = "PROXY_IMAGE"
            value = "tailscale/tailscale:unstable"
          }

          env {
            name  = "PROXY_TAGS"
            value = "tag:k8s"
          }

          env {
            name  = "AUTH_PROXY"
            value = "false"
          }

          resources {
            requests = {
              cpu = "500m"

              memory = "100Mi"
            }
          }

          volume_mount {
            name       = "oauth"
            read_only  = true
            mount_path = "/oauth"
          }
        }

        service_account_name = "operator"
      }
    }

    strategy {
      type = "Recreate"
    }
  }
}
