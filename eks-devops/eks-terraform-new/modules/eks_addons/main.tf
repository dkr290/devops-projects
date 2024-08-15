resource "aws_eks_addon" "addons" {
  for_each                    = { for addon in var.addons : addon.name => addon }
  cluster_name                = var.cluster_id
  addon_name                  = each.value.name
  addon_version               = each.value.version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
}

