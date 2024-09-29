resource "aws_eks_addon" "aws_ebs_csi" {
  cluster_name                = var.cluster_id
  addon_name                  = var.addon_name
  addon_version               = var.addon_version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  service_account_role_arn    = aws_iam_role.ebs_csi_iam_role.arn
}

