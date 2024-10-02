locals {
  enabled         = module.this.enabled
  enabled_runners = { for k, v in var.runners : k => v if v.enabled && local.enabled }

  # Default chart names
  controller_chart_name = "gha-runner-scale-set-controller"
  runner_chart_name     = "gha-runner-scale-set"

  image_pull_secret_enabled = local.enabled && var.image_pull_secret_enabled
  create_image_pull_secret  = local.image_pull_secret_enabled && var.create_image_pull_kubernetes_secret
  image_pull_secret         = one(data.aws_ssm_parameter.image_pull_secret[*].value)
  image_pull_secret_name    = var.image_pull_kubernetes_secret_name

  controller_namespace     = var.controller.kubernetes_namespace
  controller_namespace_set = toset([local.controller_namespace])
  runner_namespaces        = toset([for v in values(local.enabled_runners) : coalesce(v.kubernetes_namespace, local.controller_namespace)])
  runner_only_namespaces   = setsubtract(local.runner_namespaces, local.controller_namespace_set)

  # We have the possibility of several deployments to the same namespace,
  # with some deployments configured to create the namespace and others not.
  # We choose to create any namespace that is asked to be created, even if
  # other deployments to the same namespace do not ask for it to be created.
  all_runner_namespaces_to_create = local.enabled ? toset([
    for v in values(local.enabled_runners) : coalesce(v.kubernetes_namespace, local.controller_namespace) if v.create_namespace
  ]) : []

  # Potentially, the configuration calls for the controller's namespace to be created for the runner,
  # even if the controller does not specify that its namespace be created. As before,
  # we create the namespace if any deployment to the namespace asks for it to be created.
  # Here, however, we have to be careful to create the controller's namespace
  # using the controller's namespace resource, even if the request came from the runner.
  create_controller_namespace = local.enabled && (var.controller.create_namespace || contains(local.all_runner_namespaces_to_create, local.controller_namespace))
  runner_namespaces_to_create = setsubtract(local.all_runner_namespaces_to_create, local.controller_namespace_set)

  #  github_secret_namespaces     = local.enabled ? local.runner_namespaces : []
  #  image_pull_secret_namespaces = setunion(local.controller_namespace, local.runner_namespaces)

}

data "aws_ssm_parameter" "image_pull_secret" {
  count = local.create_image_pull_secret ? 1 : 0

  name            = var.ssm_image_pull_secret_path
  with_decryption = true
  provider        = aws.ssm
}

# We want to completely deploy the controller before deploying the runners,
# so we need separate resources for the controller and the runners, or
# else there will be a circular dependency as the runners depend on the controller
# and the controller resources are mixed in with the runners.
resource "kubernetes_namespace" "controller" {
  for_each = local.create_controller_namespace ? local.controller_namespace_set : []

  metadata {
    name = each.value
  }

  # During destroy, we may need the IAM role preserved in order to run finalizers
  # which remove resources. This depends_on ensures that the IAM role is not
  # destroyed until after the namespace is destroyed.
  depends_on = [module.gha_runner_controller.service_account_role_unique_id]
}


resource "kubernetes_secret_v1" "controller_image_pull_secret" {
  for_each = local.create_image_pull_secret ? local.controller_namespace_set : []

  metadata {
    name      = local.image_pull_secret_name
    namespace = each.value
  }

  binary_data = { ".dockercfg" = local.image_pull_secret }

  type = "kubernetes.io/dockercfg"

  depends_on = [kubernetes_namespace.controller]
}

resource "kubernetes_secret_v1" "controller_ns_github_secret" {
  for_each = local.create_github_secret && contains(local.runner_namespaces, local.controller_namespace) ? local.controller_namespace_set : []

  metadata {
    name      = local.github_secret_name
    namespace = each.value
  }

  data = local.github_secrets[local.github_app_enabled ? "app" : "pat"]

  depends_on = [kubernetes_namespace.controller]
}


module "gha_runner_controller" {
  source  = "cloudposse/helm-release/aws"
  version = "0.10.0"

  chart           = coalesce(var.charts["controller"].chart, local.controller_chart_name)
  repository      = var.charts["controller"].chart_repository
  description     = var.charts["controller"].chart_description
  chart_version   = var.charts["controller"].chart_version
  wait            = var.charts["controller"].wait
  atomic          = var.charts["controller"].atomic
  cleanup_on_fail = var.charts["controller"].cleanup_on_fail
  timeout         = var.charts["controller"].timeout

  # We need the module to wait for the namespace to be created before creating
  # resources in the namespace, but we need it to create the IAM role first,
  # so we cannot directly depend on the namespace resources, because that
  # would create a circular dependency. So instead we make the kubernetes
  # namespace depend on the resource, while the service_account_namespace
  # (which is used to create the IAM role) does not.
  kubernetes_namespace             = try(kubernetes_namespace.controller[local.controller_namespace].metadata[0].name, local.controller_namespace)
  create_namespace_with_kubernetes = false

  eks_cluster_oidc_issuer_url = module.eks.outputs.eks_cluster_identity_oidc_issuer

  service_account_name      = module.this.name
  service_account_namespace = local.controller_namespace

  iam_role_enabled = false

  values = compact([
    # hardcoded values
    try(file("${path.module}/resources/values-controller.yaml"), null),
    # standard k8s object settings
    yamlencode({
      fullnameOverride = module.this.name,
      serviceAccount = {
        name = module.this.name
      },
      affinity          = var.controller.affinity,
      labels            = var.controller.labels,
      nodeSelector      = var.controller.node_selector,
      priorityClassName = var.controller.priority_class_name,
      replicaCount      = var.controller.replicas,
      tolerations       = var.controller.tolerations,
      flags = {
        logLevel       = var.controller.log_level
        logFormat      = var.controller.log_format
        updateStrategy = var.controller.update_strategy
      }
    }),
    # filter out null values
    var.controller.resources == null ? null : yamlencode({
      resources = merge(
        try(var.controller.resources.requests, null) == null ? {} : { requests = { for k, v in var.controller.resources.requests : k => v if v != null } },
        try(var.controller.resources.limits, null) == null ? {} : { limits = { for k, v in var.controller.resources.limits : k => v if v != null } },
      )
    }),
    var.controller.image == null ? null : yamlencode(merge(
      try(var.controller.image.repository, null) == null ? {} : { repository = var.controller.image.repository },
      try(var.controller.image.tag, null) == null ? {} : { tag = var.controller.image.tag },
      try(var.controller.image.pull_policy, null) == null ? {} : { pullPolicy = var.controller.image.pull_policy },
    )),
    local.image_pull_secret_enabled ? yamlencode({
      # We need to wait until the secret is created before creating the controller,
      # but we cannot explicitly make the whole module depend on the secret, because
      # the secret depends on the namespace, and the namespace depends on the IAM role created by the module,
      # even if no IAM role is created (because Terraform uses static dependencies).
      imagePullSecrets = [{ name = try(kubernetes_secret_v1.controller_image_pull_secret[local.controller_namespace].metadata[0].name, var.image_pull_kubernetes_secret_name) }]
    }) : null,
    # additional values
    yamlencode(var.controller.chart_values)
  ])

  context = module.this.context

  # Cannot depend on the namespace directly, because that would create a circular dependency (see above)
  # depends_on = [kubernetes_namespace.default]
}
