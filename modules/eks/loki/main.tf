locals {
  enabled = module.this.enabled

  name               = length(module.this.name) > 0 ? module.this.name : "loki"
  ingress_host_name  = format("%s.%s.%s", local.name, module.this.environment, module.dns_gbl_delegated.outputs.default_domain_name)
  ingress_group_name = module.alb_controller_ingress_group.outputs.group_name

  ssm_path_password = format(var.ssm_path_template, module.this.id, "password")
}

resource "random_pet" "basic_auth_username" {
  count = local.enabled && var.basic_auth_enabled ? 1 : 0
}

resource "random_string" "basic_auth_password" {
  count = local.enabled && var.basic_auth_enabled ? 1 : 0

  length  = 12
  special = true
}

module "basic_auth_ssm_parameters" {
  source  = "cloudposse/ssm-parameter-store/aws"
  version = "0.13.0"

  enabled = local.enabled && var.basic_auth_enabled

  parameter_write = [
    {
      name        = format(var.ssm_path_template, module.this.id, "username")
      value       = random_pet.basic_auth_username[0].id
      description = "Basic Auth Username for ${module.this.id}"
      type        = "SecureString"
      overwrite   = true
    },
    {
      name        = local.ssm_path_password
      value       = random_string.basic_auth_password[0].result
      description = "Basic Auth Password for ${module.this.id}"
      type        = "SecureString"
      overwrite   = true
    }
  ]

  context = module.this.context
}

module "loki_storage" {
  source  = "cloudposse/s3-bucket/aws"
  version = "4.2.0"

  for_each = toset(["chunks", "ruler", "admin"])

  name       = local.name
  attributes = [each.key]

  enabled = local.enabled

  context = module.this.context
}

module "loki_tls_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  enabled = local.enabled

  attributes = ["tls"]

  context = module.this.context
}

module "loki" {
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

  iam_role_enabled = true
  iam_policy = [{
    statements = [
      {
        sid    = "AllowLokiStorageAccess"
        effect = "Allow"
        resources = [
          module.loki_storage["chunks"].bucket_arn,
          module.loki_storage["ruler"].bucket_arn,
          module.loki_storage["admin"].bucket_arn,
          format("%s/*", module.loki_storage["chunks"].bucket_arn),
          format("%s/*", module.loki_storage["ruler"].bucket_arn),
          format("%s/*", module.loki_storage["admin"].bucket_arn),
        ]
        actions = [
          "s3:ListBucket",
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject"
        ]
      },
    ]
  }]

  values = compact([
    yamlencode({
      loki = {
        # For new installations, schema config doesnt change. See the following:
        # https://grafana.com/docs/loki/latest/operations/storage/schema/#new-loki-installs
        schemaConfig = {
          configs = concat(var.default_schema_config, var.additional_schema_config)
        }
        storage = {
          bucketNames = {
            chunks = module.loki_storage["chunks"].bucket_id
            ruler  = module.loki_storage["ruler"].bucket_id
            admin  = module.loki_storage["admin"].bucket_id
          },
          type = "s3",
          s3 = {
            region = var.region
          }
        }
      }
      # Do not use the default nginx gateway
      gateway = {
        enabled = false
      }
      # Instead, we want to use AWS ALB Ingress Controller
      ingress = {
        enabled = true
        annotations = {
          "kubernetes.io/ingress.class"               = "alb"
          "external-dns.alpha.kubernetes.io/hostname" = local.ingress_host_name
          "alb.ingress.kubernetes.io/group.name"      = local.ingress_group_name
          # We dont need to supply "alb.ingress.kubernetes.io/certificate-arn" because of AWS ALB controller's auto discovery using the given host
          "alb.ingress.kubernetes.io/backend-protocol" = "HTTP"
          "alb.ingress.kubernetes.io/listen-ports"     = "[{\"HTTP\": 80},{\"HTTPS\":443}]"
          "alb.ingress.kubernetes.io/ssl-redirect"     = "443"
          "alb.ingress.kubernetes.io/scheme"           = "internal"
          "alb.ingress.kubernetes.io/target-type"      = "ip"
        }
        hosts = [
          local.ingress_host_name
        ]
        tls = [
          {
            secretName = module.loki_tls_label.id
            hosts      = [local.ingress_host_name]
          }
        ]
      }
      # Loki Canary does not work when gateway is disabled
      # https://github.com/grafana/loki/issues/11208
      test = {
        enabled = false
      }
      lokiCanary = {
        enabled = false
      }
    }),
    yamlencode(
      var.basic_auth_enabled ? {
        basicAuth = {
          enabled  = true
          username = random_pet.basic_auth_username[0].id
          password = random_string.basic_auth_password[0].result
        }
      } : {}
    ),
    yamlencode(var.chart_values),
  ])

  context = module.this.context
}
