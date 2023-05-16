locals {
  enabled = module.this.enabled

  create_namespace = local.enabled && var.create_namespace

  kubernetes_namespace = local.create_namespace ? join("", kubernetes_namespace.default.*.id) : var.kubernetes_namespace

  kubernetes_service_enabled = local.enabled && var.kubernetes_service_enabled

  global_accelerator_enabled = module.this.enabled && var.global_accelerator_enabled

  waf_enabled = module.this.enabled && var.waf_enabled

  waf_acl_arn = local.waf_enabled ? tomap({ "alb.ingress.kubernetes.io/wafv2-acl-arn" = module.waf.outputs.acl.arn }) : {}

  alb_logging_annotation = var.alb_access_logs_enabled ? tomap({
    "alb.ingress.kubernetes.io/load-balancer-attributes" = "access_logs.s3.enabled=true,access_logs.s3.bucket=${var.alb_access_logs_s3_bucket_name},access_logs.s3.prefix=${var.alb_access_logs_s3_bucket_prefix}",
  }) : {}

  global_accelerator_listener_ids = [
    for global_accelerator in module.global_accelerator :
    global_accelerator.outputs.listener_ids[0]
  ]

  ingress_controller_group_name = coalesce(var.alb_group_name, module.this.name)

  kube_tags = join(",", [for k, v in module.this.tags : "${k}=${v}"])

  default_rule = "default-404-rule"

  message_body = templatefile(var.fixed_response_template, var.fixed_response_vars)

  # for outputs
  annotations           = try(kubernetes_ingress_v1.default[0].metadata.0.annotations, null)
  group_name_annotation = try(lookup(kubernetes_ingress_v1.default[0].metadata.0.annotations, "alb.ingress.kubernetes.io/group.name", null), null)
  load_balancer_name    = join("", data.aws_lb.default[*].name)
  host                  = join(".", [module.this.environment, module.dns_delegated.outputs.default_domain_name])
}

resource "kubernetes_namespace" "default" {
  count = local.create_namespace ? 1 : 0

  metadata {
    name = var.kubernetes_namespace

    labels = module.this.tags
  }
}

resource "kubernetes_service" "default" {
  count = local.kubernetes_service_enabled ? 1 : 0

  metadata {
    annotations = {}
    labels      = {}
    name        = module.this.id
    namespace   = local.kubernetes_namespace
  }

  spec {
    external_ips                = []
    load_balancer_source_ranges = []
    selector                    = {}
    port {
      port        = var.kubernetes_service_port
      target_port = 80
    }
  }

  depends_on = [
    kubernetes_namespace.default,
  ]
}

module "load_balancer_name" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  # Maximum number of characters for load balancer
  id_length_limit = 32

  context = module.this.context
}

resource "kubernetes_ingress_v1" "default" {
  count = local.enabled ? 1 : 0

  metadata {
    labels    = {}
    name      = module.this.id
    namespace = local.kubernetes_namespace
    annotations = merge(
      local.waf_acl_arn,
      local.alb_logging_annotation,
      {
        # The annotation "alb.ingress.kubernetes.io/certificate-arn" isn't needed due to the aws lb controller's
        # auto discovery using the host
        "alb.ingress.kubernetes.io/load-balancer-name" = module.load_balancer_name.id
        "alb.ingress.kubernetes.io/group.name"         = local.ingress_controller_group_name
        "external-dns.alpha.kubernetes.io/hostname"    = local.host
        "alb.ingress.kubernetes.io/ssl-redirect"       = "443"
        "alb.ingress.kubernetes.io/actions.ssl-redirect" = jsonencode({
          Type = "redirect"
          RedirectConfig = {
            Protocol   = "HTTPS"
            Port       = "443"
            StatusCode = "HTTP_301"
          }
        })
        "alb.ingress.kubernetes.io/tags"                                        = local.kube_tags
        "service.beta.kubernetes.io/aws-load-balancer-additional-resource-tags" = local.kube_tags
        "alb.ingress.kubernetes.io/actions.${local.default_rule}" = jsonencode({
          type = "fixed-response"
          fixedResponseConfig = merge({
            contentType = "text/html"
            statusCode  = "404"
            messageBody = local.message_body
          }, var.fixed_response_config)
        })
      },
      var.default_annotations,
      var.additional_annotations,
    )
  }

  spec {
    default_backend {
      service {
        name = local.default_rule
        port {
          name = "use-annotation"
        }
      }
    }

    dynamic "rule" {
      for_each = var.kubernetes_service_enabled ? [true] : []

      content {
        host = local.host
        http {
          path {
            backend {
              service {
                name = kubernetes_service.default[0].metadata[0].name
                port {
                  number = var.kubernetes_service_port
                }
              }
            }
            path = var.kubernetes_service_path
          }
        }
      }
    }

    tls {
      hosts = [local.host]
    }
  }

  wait_for_load_balancer = true

  depends_on = [
    kubernetes_namespace.default,
  ]
}

data "aws_lb" "default" {
  count = local.enabled ? 1 : 0

  tags = {
    "ingress.k8s.aws/resource" = "LoadBalancer"
    "ingress.k8s.aws/stack"    = local.ingress_controller_group_name
    "elbv2.k8s.aws/cluster"    = module.eks.outputs.eks_cluster_id
  }

  depends_on = [
    kubernetes_ingress_v1.default
  ]
}

resource "aws_globalaccelerator_endpoint_group" "default" {
  for_each = toset(local.global_accelerator_listener_ids)

  listener_arn                  = each.value
  endpoint_group_region         = var.region
  health_check_interval_seconds = null
  health_check_path             = null
  health_check_port             = null
  health_check_protocol         = null
  threshold_count               = null
  traffic_dial_percentage       = null

  endpoint_configuration {
    endpoint_id                    = join("", data.aws_lb.default[*].id)
    client_ip_preservation_enabled = false

    ## Weight > 0 is required for working GA multi-region fallback
    weight = 1
  }
}
