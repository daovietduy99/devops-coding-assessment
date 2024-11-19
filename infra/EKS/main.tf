# Create the EKS cluster
resource "aws_eks_cluster" "my_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.my_cluster_role.arn
  version  = "1.29"

  vpc_config {
    subnet_ids              = aws_subnet.private_subnets[*].id
    endpoint_private_access = false
    endpoint_public_access  = true
  }
  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = false
  }
}

# # AWS EBS CSI driver
# resource "aws_iam_role" "eks_ebs_csi_driver_role" {
#   name               = "AmazonEKS_EBS_CSI_DriverRole"
#   assume_role_policy = jsonencode({
#     "Version" : "2012-10-17",
#     "Statement" : [
#       {
#         "Effect" : "Allow",
#         "Principal" : {
#           "Service" : "eks.amazonaws.com"
#         },
#         "Action" : "sts:AssumeRole"
#       }
#     ]
#   })
# }

# resource "aws_iam_policy_attachment" "eks_ebs_csi_driver_attachment" {
#   name       = "AmazonEKS_EBS_CSI_DriverAttachment"
#   roles      = [aws_iam_role.eks_ebs_csi_driver_role.name]
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
# }
