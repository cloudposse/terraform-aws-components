# module "eks-node-group" {
#   source = "umotif-public/eks-node-group/aws"
#   version = "~> 3.0.0"

#   cluster_name = aws_eks_cluster.cluster.id

#   subnet_ids = ["subnet-1","subnet-2","subnet-3"]

#   desired_size = 1
#   min_size     = 1
#   max_size     = 1

#   instance_types = ["t3.large","t2.large"]
#   capacity_type  = "SPOT"

#   ec2_ssh_key = "eks-test"

#   kubernetes_labels = {
#     lifecycle = "OnDemand"
#   }

#   force_update_version = true

#   tags = {
#     Environment = "test"
#   }
# }
