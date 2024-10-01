locals {
  enabled = module.this.enabled
  name    = length(module.this.name) > 0 ? module.this.name : "promtail"

  # Assume basic auth is enabled if the loki component has a basic auth username output
  basic_auth_enabled = local.enabled && length(module.loki.outputs.basic_auth_username) > 0

  # These are the default values required to connect to eks/loki in the same namespace
  loki_write_chart_values = {
    config = {
      clients = [
        {
          # Intentionally choose the loki-write service not loki-gateway. Loki gateway is disabled
          url       = "http://loki-write:3100/loki/api/v1/push"
          tenant_id = "1"
          basic_auth = local.basic_auth_enabled ? {
            username = module.loki.outputs.basic_auth_username
            password = data.aws_ssm_parameter.basic_auth_password[0].value
          } : {}
        }
      ]
    }
  }

  # These are optional values used to expose an endpoint for the Push API
  # https://grafana.com/docs/loki/latest/send-data/promtail/configuration/#loki_push_api
  push_api_enabled               = local.enabled && var.push_api.enabled
  ingress_host_name              = local.push_api_enabled ? format("%s.%s.%s", local.name, module.this.environment, module.dns_gbl_delegated[0].outputs.default_domain_name) : ""
  ingress_group_name             = local.push_api_enabled ? module.alb_controller_ingress_group[0].outputs.group_name : ""
  default_push_api_scrape_config = <<-EOT
  - job_name: push
    loki_push_api:
      server:
        http_listen_port: 3500
        grpc_listen_port: 3600
      labels:
        push: default
  EOT
  push_api_chart_values = {
    config = {
      snippets = {
        extraScrapeConfigs = length(var.push_api.scrape_config) > 0 ? var.push_api.scrape_config : local.default_push_api_scrape_config
      }
    }
    extraPorts = {
      push = {
        name          = "push"
        containerPort = "3500"
        protocol      = "TCP"
        service = {
          type = "ClusterIP"
          port = "3500"
        }
        ingress = {
          annotations = {
            "kubernetes.io/ingress.class"                = "alb"
            "external-dns.alpha.kubernetes.io/hostname"  = local.ingress_host_name
            "alb.ingress.kubernetes.io/group.name"       = local.ingress_group_name
            "alb.ingress.kubernetes.io/backend-protocol" = "HTTP"
            "alb.ingress.kubernetes.io/listen-ports"     = "[{\"HTTP\": 80},{\"HTTPS\":443}]"
            "alb.ingress.kubernetes.io/ssl-redirect"     = "443"
            "alb.ingress.kubernetes.io/target-type"      = "ip"
          }
          hosts = [
            local.ingress_host_name
          ]
          tls = [
            {
              secretName = "${module.this.id}-tls"
              hosts      = [local.ingress_host_name]
            }
          ]
        }
      }
    }
  }

  scrape_config = join("\n", [for scrape_config_file in var.scrape_configs : file("${path.module}/${scrape_config_file}")])
  scrape_config_chart_values = {
    config = {
      snippets = {
        scrapeConfigs = local.scrape_config
      }
    }
  }
}

data "aws_ssm_parameter" "basic_auth_password" {
  count = local.basic_auth_enabled ? 1 : 0

  name = module.loki.outputs.ssm_path_basic_auth_password
}

module "chart_values" {
  source  = "cloudposse/config/yaml//modules/deepmerge"
  version = "1.0.2"

  count = local.enabled ? 1 : 0

  maps = [
    local.loki_write_chart_values,
    jsondecode(local.push_api_enabled ? jsonencode(local.push_api_chart_values) : jsonencode({})),
    local.scrape_config_chart_values,
    var.chart_values
  ]
}

module "promtail" {
  source  = "cloudposse/helm-release/aws"
  version = "0.10.1"

  enabled = local.enabled

  name          = local.name
  chart         = var.chart
  description   = var.chart_description
  repository    = var.chart_repository
  chart_version = var.chart_version

  kubernetes_namespace = var.kubernetes_namespace
  create_namespace     = var.create_namespace

  verify          = var.verify
  wait            = var.wait
  atomic          = var.atomic
  cleanup_on_fail = var.cleanup_on_fail
  timeout         = var.timeout

  eks_cluster_oidc_issuer_url = replace(module.eks.outputs.eks_cluster_identity_oidc_issuer, "https://", "")

  values = compact([
    yamlencode(module.chart_values[0].merged),
  ])

  context = module.this.context
}
