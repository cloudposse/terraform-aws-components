module "alb_controller" {
  source  = "cloudposse/helm-release/aws"
  version = "0.10.0"

  chart           = var.chart
  repository      = var.chart_repository
  description     = var.chart_description
  chart_version   = var.chart_version
  wait            = true # required for installing IngressClassParams
  atomic          = var.atomic
  cleanup_on_fail = var.cleanup_on_fail
  timeout         = var.timeout

  create_namespace_with_kubernetes = var.create_namespace
  kubernetes_namespace             = var.kubernetes_namespace
  kubernetes_namespace_labels      = merge(module.this.tags, { name = var.kubernetes_namespace })

  eks_cluster_oidc_issuer_url = replace(module.eks.outputs.eks_cluster_identity_oidc_issuer, "https://", "")

  service_account_name      = module.this.name
  service_account_namespace = var.kubernetes_namespace

  iam_role_enabled = true
  # See distributed-iam-policy.tf
  iam_source_policy_documents = [local.overridable_distributed_iam_policy]

  values = compact([
    # standard k8s object settings
    yamlencode({
      fullnameOverride = module.this.name,
      serviceAccount = {
        name = module.this.name
      },
      resources = var.resources
      rbac = {
        create = var.rbac_enabled
      }
    }),
    # alb-controller-specific values
    yamlencode({
      aws = {
        region = var.region
      }
      clusterName                = module.eks.outputs.eks_cluster_id
      createIngressClassResource = var.default_ingress_enabled
      ingressClass               = var.default_ingress_class_name
      ingressClassParams = {
        name   = var.default_ingress_class_name
        create = var.default_ingress_enabled
        spec = {
          group = {
            name = var.default_ingress_group
          }
          scheme                 = var.default_ingress_scheme
          ipAddressType          = var.default_ingress_ip_address_type
          tags                   = [for k, v in merge(module.this.tags, var.default_ingress_additional_tags) : { key = k, value = v }]
          loadBalancerAttributes = var.default_ingress_load_balancer_attributes
        }
      }
      ingressClassConfig = {
        default = var.default_ingress_enabled
      }
      defaultTags = module.this.tags
    }),
    # additional values
    yamlencode(var.chart_values)
  ])

  context = module.this.context
}
