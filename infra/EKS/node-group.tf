# resource "aws_launch_template" "foo" {
#   name                   = "spot-instance"
#   key_name               = "eks-keypair"
#   instance_type          = "t2.large"
#   vpc_security_group_ids = [aws_security_group.eks_sg.id]
#   instance_market_options {
#     market_type = "spot"
#   }

#   block_device_mappings {
#     device_name = "/dev/sdf"

#     ebs {
#       volume_size = 20
#     }
#   }

#   image_id = "ami-07802316f68368a59"

#   monitoring {
#     enabled = true
#   }

#   network_interfaces {
#     associate_public_ip_address = true
#   }

#   placement {
#     availability_zone = "ap-southeast-2a"
#   }

#   tag_specifications {
#     resource_type = "instance"

#     tags = {
#       Name = "dev"
#     }
#   }
# }

resource "aws_eks_node_group" "eks-workers-node-group" {
  cluster_name    = aws_eks_cluster.my_cluster.name
  node_group_name = "eks-workers"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = aws_subnet.public_subnets[*].id
  
  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy.AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy.AmazonEKS_CNI_Policy,
  ]
}
