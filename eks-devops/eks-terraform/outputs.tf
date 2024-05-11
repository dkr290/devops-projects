output "eks_cluster_id" {
  description = "EKS cluster ID"
  value       = resource.aws_eks_cluster.eks.id
  
}


