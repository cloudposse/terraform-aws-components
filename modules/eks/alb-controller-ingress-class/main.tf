resource "kubernetes_ingress_class_v1" "default" {
  metadata {
    name = var.class_name
    annotations = {
      "ingressclass.kubernetes.io/is-default-class" = "true"
    }
  }

  spec {
    controller = "ingress.k8s.aws/alb"
    parameters {
      api_group = "elbv2.k8s.aws"
      kind      = "IngressClassParams"
      name      = var.class_name
    }
  }

  depends_on = [kubernetes_manifest.alb_controller_class_params]
}

resource "kubernetes_manifest" "alb_controller_class_params" {
  manifest = {
    apiVersion = "elbv2.k8s.aws/v1beta1"
    kind       = "IngressClassParams"
    metadata = {
      name = var.class_name
    }
    spec = {
      group = {
        name = var.group
      }
      scheme                 = var.scheme
      ipAddressType          = var.ip_address_type
      tags                   = [for k, v in merge(module.this.tags, var.additional_tags) : { key = k, value = v }]
      loadBalancerAttributes = var.load_balancer_attributes
    }
  }
}
