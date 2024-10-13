output "node_group_id" {
  description = "Node Group ID"
  value       = aws_eks_node_group.eks_ng.id
}

output "node_group_arn" {
  description = "Node Group ARN"
  value       = aws_eks_node_group.eks_ng.arn
}

output "node_group_status" {
  description = "Node Group status"
  value       = aws_eks_node_group.eks_ng.status
}

output "node_group_version" {
  description = "Node Group Kubernetes Version"
  value       = aws_eks_node_group.eks_ng.version
}
output "eks_cluster_name" {

  value = aws_eks_node_group.eks_ng.cluster_name
}
output "node_group_role_arn" {
  value = aws_eks_node_group.eks_ng.node_role_arn
}
