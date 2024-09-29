output "ebs_eks_addon_arn" {
  description = "EKS ebs addon arn"
  value       = aws_eks_addon.aws_ebs_csi.arn
}



