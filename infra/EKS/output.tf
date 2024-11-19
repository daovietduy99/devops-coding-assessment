output "cluster_name" {
  value = aws_eks_cluster.my_cluster.name
}

output "autoscaling_group_name" {
  value = aws_eks_node_group.eks-workers-node-group.resources.*.autoscaling_groups
}
