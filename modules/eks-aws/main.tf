data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
}

# data "aws_availability_zones" "available" {
# }

locals {
  cluster_name = "atmos-gbl-test-eks-aws-cluster"
}

# resource "random_string" "suffix" {
#   length  = 8
#   special = false
# }

# resource "aws_security_group" "worker_group_mgmt_one" {
#   name_prefix = "worker_group_mgmt_one"
#   vpc_id      = module.vpc.vpc_id

#   ingress {
#     from_port = 22
#     to_port   = 22
#     protocol  = "tcp"

#     cidr_blocks = [
#       "10.0.0.0/8",
#     ]
#   }
# }

# resource "aws_security_group" "worker_group_mgmt_two" {
#   name_prefix = "worker_group_mgmt_two"
#   vpc_id      = module.vpc.vpc_id

#   ingress {
#     from_port = 22
#     to_port   = 22
#     protocol  = "tcp"

#     cidr_blocks = [
#       "192.168.0.0/16",
#     ]
#   }
# }

# resource "aws_security_group" "all_worker_mgmt" {
#   name_prefix = "all_worker_management"
#   vpc_id      = module.vpc.vpc_id

#   ingress {
#     from_port = 22
#     to_port   = 22
#     protocol  = "tcp"

#     cidr_blocks = [
#       "10.0.0.0/8",
#       "172.16.0.0/12",
#       "192.168.0.0/16",
#     ]
#   }
# }

# module "vpc" {
#   source  = "terraform-aws-modules/vpc/aws"
#   version = "~> 2.47"

#   name                 = "test-vpc"
#   cidr                 = "10.0.0.0/16"
#   azs                  = data.aws_availability_zones.available.names
#   private_subnets      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
#   public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
#   enable_nat_gateway   = true
#   single_nat_gateway   = true
#   enable_dns_hostnames = true

#   public_subnet_tags = {
#     "kubernetes.io/cluster/${local.cluster_name}" = "shared"
#     "kubernetes.io/role/elb"                      = "1"
#   }

#   private_subnet_tags = {
#     "kubernetes.io/cluster/${local.cluster_name}" = "shared"
#     "kubernetes.io/role/internal-elb"             = "1"
#   }
# }

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "16.2.0"

  cluster_name    = local.cluster_name
  cluster_version = "1.20"
  subnets         = module.vpc.outputs.subnets.private.ids

  tags = {
    Environment = "test"
    GithubRepo  = "terraform-aws-eks"
    GithubOrg   = "terraform-aws-modules"
  }

  vpc_id = module.vpc.outputs.vpc.id

  worker_groups = [
    {
      name                          = "worker-group-1"
      instance_type                 = "t3.small"
      # additional_userdata           = "echo foo bar"
      asg_desired_capacity          = 1
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

  node_groups = {
    example = {
      desired_capacity = 1
      max_capacity     = 2
      min_capacity     = 1

      instance_types = ["t3.small"]
      capacity_type  = "ON_DEMAND"
      k8s_labels = {
        Environment = "test"
        GithubRepo  = "terraform-aws-eks"
        GithubOrg   = "terraform-aws-modules"
      }
      additional_tags = {
        ExtraTag = "example"
      }
    }
  }

  # worker_additional_security_group_ids = [aws_security_group.all_worker_mgmt.id]
  map_roles                            = [
    {
      rolearn  = "arn:aws:iam::314028178888:role/atmos-gbl-test-admin"
      username = "atmos-gbl-test-admin"
      groups   = ["system:masters"]
    },
  ]
  map_users                            = var.map_users
  map_accounts                         = var.map_accounts
}
