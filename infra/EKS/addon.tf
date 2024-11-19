# resource "aws_iam_role" "vpc_cni_role" {
#   name               = "${var.cluster_name}-vpc-cni-role"
#   assume_role_policy = data.aws_iam_policy_document.vpc_cni_assume_role_policy.json
# }

# data "aws_iam_policy_document" "vpc_cni_assume_role_policy" {
#   statement {
#     actions = ["sts:AssumeRole"]
#     principals {
#       type        = "Service"
#       identifiers = ["eks.amazonaws.com"]
#     }
#   }
# }

# resource "aws_iam_role_policy_attachment" "vpc_cni_policy_attachment" {
#   role       = aws_iam_role.vpc_cni_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
# }

# resource "aws_eks_addon" "vpc_cni" {
#   cluster_name          = var.cluster_name
#   addon_name            = "vpc-cni"
#   service_account_role_arn = aws_iam_role.vpc_cni_role.arn
# }

resource "aws_eks_addon" "eks-pod-identity-agent" {
  cluster_name          = var.cluster_name
  addon_name            = "eks-pod-identity-agent"
}
