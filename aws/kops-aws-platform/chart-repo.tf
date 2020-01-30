module "kops_chart_repo" {
  source          = "git::https://github.com/cloudposse/terraform-aws-kops-chart-repo.git?ref=tags/0.3.0"
  namespace       = "${var.namespace}"
  stage           = "${var.stage}"
  name            = "chart-repo"
  cluster_name    = "${var.region}.${var.zone_name}"
  permitted_nodes = "${var.permitted_nodes}"

  iam_role_max_session_duration = "${var.iam_role_max_session_duration}"

  tags = {
    Cluster = "${var.region}.${var.zone_name}"
  }
}

output "kops_chart_repo_bucket_domain_name" {
  value = "${module.kops_chart_repo.bucket_domain_name}"
}

output "kops_chart_repo_bucket_id" {
  value = "${module.kops_chart_repo.bucket_id}"
}

output "kops_chart_repo_bucket_arn" {
  value = "${module.kops_chart_repo.bucket_arn}"
}

output "kops_chart_repo_role_name" {
  value = "${module.kops_chart_repo.role_name}"
}

output "kops_chart_repo_role_unique_id" {
  value = "${module.kops_chart_repo.role_unique_id}"
}

output "kops_chart_repo_role_arn" {
  value = "${module.kops_chart_repo.role_arn}"
}

output "kops_chart_repo_policy_name" {
  value = "${module.kops_chart_repo.policy_name}"
}

output "kops_chart_repo_policy_id" {
  value = "${module.kops_chart_repo.policy_id}"
}

output "kops_chart_repo_policy_arn" {
  value = "${module.kops_chart_repo.policy_arn}"
}
