
resource "aws_iam_openid_connect_provider" "oidc-provider" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["d89e3bd43d5d909b47a18977aa9d5ce36cee184c"]
  url             = aws_eks_cluster.my_cluster.identity[0].oidc[0].issuer
}

################################################################################
# Create the IAM role for the EKS cluster
################################################################################
resource "aws_iam_role" "my_cluster_role" {
  name = "my-cluster-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Attach the necessary policies to the IAM role
resource "aws_iam_role_policy_attachment" "my_cluster_role_policy_attachment" {
  role       = aws_iam_role.my_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

################################################################################
# Create the IAM role for the EKS Node group
################################################################################
resource "aws_iam_role" "eks_node_role" {
  name = "eksWorkerNodeRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "AmazonEC2ContainerRegistryReadOnly" {
  name = "AmazonEC2ContainerRegistryReadOnly"
  role = aws_iam_role.eks_node_role.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:GetRepositoryPolicy",
                "ecr:DescribeRepositories",
                "ecr:ListImages",
                "ecr:DescribeImages",
                "ecr:BatchGetImage",
                "ecr:GetLifecyclePolicy",
                "ecr:GetLifecyclePolicyPreview",
                "ecr:ListTagsForResource",
                "ecr:DescribeImageScanFindings"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "AmazonEKSWorkerNodePolicy" {
  name = "AmazonEKSWorkerNodePolicy"
  role = aws_iam_role.eks_node_role.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "WorkerNodePermissions",
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeInstances",
                "ec2:DescribeInstanceTypes",
                "ec2:DescribeRouteTables",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeSubnets",
                "ec2:DescribeVolumes",
                "ec2:DescribeVolumesModifications",
                "ec2:DescribeVpcs",
                "eks:DescribeCluster",
                "eks-auth:AssumeRoleForPodIdentity"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "AmazonEKS_CNI_Policy" {
  name = "AmazonEKS_CNI_Policy"
  role = aws_iam_role.eks_node_role.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:AssignPrivateIpAddresses",
                "ec2:AttachNetworkInterface",
                "ec2:CreateNetworkInterface",
                "ec2:DeleteNetworkInterface",
                "ec2:DescribeInstances",
                "ec2:DescribeTags",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DescribeInstanceTypes",
                "ec2:DetachNetworkInterface",
                "ec2:ModifyNetworkInterfaceAttribute",
                "ec2:UnassignPrivateIpAddresses"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateTags"
            ],
            "Resource": [
                "arn:aws:ec2:*:*:network-interface/*"
            ]
        }
    ]
}
EOF
}


# ################################################################################
# # IAM Role: aws-load-balancer-controller
# ################################################################################
# resource "aws_iam_policy" "AWSLoadBalancerControllerIAMPolicy" {
#   name        = "AWSLoadBalancerControllerIAMPolicy"
#   path        = "/"
#   description = "IAM policy for the AWS Load Balancer Controller"
#   policy      = file("policies/iam-policy.json")
# }

# resource "aws_iam_role" "AmazonEKSLoadBalancerControllerRole" {
#   name = "AmazonEKSLoadBalancerControllerRole"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRoleWithWebIdentity"
#         Effect = "Allow"
#         Sid    = ""
#         Principal = {
#           Federated = "${aws_iam_openid_connect_provider.oidc-provider.arn}"
#         }
#         Condition = {
#           StringEquals = {
#             "${aws_iam_openid_connect_provider.oidc-provider.url}:aud" = "sts.amazonaws.com",
#             "${aws_iam_openid_connect_provider.oidc-provider.url}:sub" = "system:serviceaccount:default:aws-load-balancer-controller"
#           }
#         }
#       },
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "test-attach" {
#   role       = aws_iam_role.AmazonEKSLoadBalancerControllerRole.name
#   policy_arn = aws_iam_policy.AWSLoadBalancerControllerIAMPolicy.arn
# }

# ################################################################################
# # iam role for aws-ebs-csi-driver
# ################################################################################

# resource "aws_iam_policy" "kms_key_for_encryption_on_ebs_policy" {
#   name        = "KMSKeyForEncryptionOnEBSPolicy"
#   path        = "/"
#   description = "IAM policy for the AWS Load Balancer Controller"
#   policy      = file("policies/KMSKeyForEncryptionOnEBSPolicy.json")
# }

# resource "aws_iam_role" "eks_ebs_csi_driver_role" {
#   name = "AmazonEKS_EBS_CSI_DriverRole"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRoleWithWebIdentity"
#         Effect = "Allow"
#         Sid    = ""
#         Principal = {
#           Federated = "${aws_iam_openid_connect_provider.oidc-provider.arn}"
#         }
#         Condition = {
#           StringEquals = {
#             "${aws_iam_openid_connect_provider.oidc-provider.url}:aud" = "sts.amazonaws.com",
#           }
#         }
#       },
#     ]
#   })
# }

# resource "aws_iam_policy_attachment" "eks_ebs_csi_driver_attachment" {
#   name       = "AmazonEKS_EBS_CSI_DriverAttachment"
#   roles      = [aws_iam_role.eks_ebs_csi_driver_role.name]
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
# }

# resource "aws_iam_role_policy_attachment" "eks_ebs_csi_driver_attachment_role_policy_attach" {
#   role       = aws_iam_role.eks_ebs_csi_driver_role.name
#   policy_arn = aws_iam_policy.kms_key_for_encryption_on_ebs_policy.arn
# }



# resource "aws_eks_addon" "example" {
#   cluster_name = aws_eks_cluster.my_cluster.name
#   addon_name   = "aws-ebs-csi-driver"
#   service_account_role_arn = aws_iam_role.eks_ebs_csi_driver_role.arn
# }

