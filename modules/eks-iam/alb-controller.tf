# https://github.com/kubernetes-sigs/cluster-proportional-autoscaler

module "alb-controller" {
  source = "./modules/service-account"

  service_account_name      = "alb-controller"
  service_account_namespace = "kube-system"
  # https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json
  aws_iam_policy_document = file("${path.module}/alb-controller-iam-policy.json")

  cluster_context = local.cluster_context
  context         = module.this.context
}
