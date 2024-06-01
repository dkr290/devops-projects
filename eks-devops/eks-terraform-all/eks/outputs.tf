output "eks_cluster_id" {
  description = "EKS cluster ID"
  value       = resource.aws_eks_cluster.eks.id

}
output "eks_cluster_endpoint" {
  description = "Eks cluster endpoint"
  value       = resource.aws_eks_cluster.eks.endpoint
}

output "kubernetes_version" {
  description = "kubernetes version"
  value       = resource.aws_eks_cluster.eks.platform_version
}


output "eks_get_creds" {

  value       = "aws eks update-kubeconfig --region eu-central-1 --name <cluster_name>"
  description = "Output the eks command to connect"

}


