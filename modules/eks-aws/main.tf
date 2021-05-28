locals {
  cluster_name = "atmos-gbl-test-eks-aws-cluster"
}

module "label" {
  source  = "cloudposse/label/null"
  version = "0.24.1"

  attributes = ["cluster"]

  context = module.this.context
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "16.2.0"

  cluster_name = module.label.id
  tags         = module.label.tags

  vpc_id  = module.vpc.outputs.vpc.id
  subnets = module.vpc.outputs.subnets.private.ids

  cluster_version = "1.20"

  # worker_additional_security_group_ids = [aws_security_group.all_worker_mgmt.id]
  map_roles = [
    {
      rolearn  = "arn:aws:iam::314028178888:role/atmos-gbl-test-admin"
      username = "atmos-gbl-test-admin"
      groups   = ["system:masters"]
    },
  ]
  map_users    = var.map_users
  map_accounts = var.map_accounts

  node_groups = {
    example = {
      desired_capacity = 1
      max_capacity     = 2
      min_capacity     = 1

      instance_types = ["t3.small"]
      capacity_type  = "ON_DEMAND"
      k8s_labels     = module.label.tags
    }
  }

  worker_groups = [
    {
      name          = "worker-group-1"
      instance_type = "t3.small"
      # additional_userdata           = "echo foo bar"
      asg_desired_capacity = 1
      # additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
    },
    # {
    #   name                          = "worker-group-2"
    #   instance_type                 = "t3.medium"
    #   additional_userdata           = "echo foo bar"
    #   additional_security_group_ids = [aws_security_group.worker_group_mgmt_two.id]
    #   asg_desired_capacity          = 1
    # },
  ]
}
