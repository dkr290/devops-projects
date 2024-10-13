# Define Local Values in Terraform
locals {
  environment = var.environment
  common_tags = {
    owners      = var.owners
    environment = local.environment
  }


  configmap_roles = [
    {
      rolearn  = data.terraform_remote_state.eks.outputs.eks_nodegroup_role_arn
      username = "system:node:{{EC2PrivateDNSName}}"
      groups   = ["system:bootstrappers", "system:nodes"]
    },
  ]

  configmap_users = [
    {
      userarn  = "${aws_iam_user.admin_user.arn}"
      username = "${aws_iam_user.admin_user.name}"
      groups   = ["system:masters"]
    },

    {
      userarn  = "${aws_iam_user.basic-user.arn}"
      username = "${aws_iam_user.basic-user.name}"
      groups   = ["system-masters"]
    },
  ]
}
