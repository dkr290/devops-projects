output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.network[0].vpc_id
}
output "route_table_id" {
  value       = module.network[0].route_table_id
  description = "The generated route table"
}

output "tenancy" {
  value       = module.network[0].tenancy
  description = "The default tenancy"
}

output "dhcp_options_id" {
  value       = module.network[0].dhcp_options_id
  description = "The default dhcp_options_id"
}

output "default_security_group_id" {
  value       = module.network[0].default_security_group_id
  description = "The default security group id"
}

output "publicSubnetA" {
  value = module.network[0].publicSubnetA
}

output "publicSubnetB" {
  value = module.network[0].publicSubnetB
}

output "publicSubnetC" {
  value = module.network[0].publicSubnetC
}
output "WorkersSubnetA" {
  value = module.network[0].WorkersSubnetA
}
output "WorkersSubnetB" {
  value = module.network[0].WorkersSubnetB
}
output "WorkersSubnetC" {
  value = module.network[0].WorkersSubnetC
}


output "DatabaseSubnetsA" {
  value = module.network[0].DatabaseSubnetsA

}

output "DatabaseSubnetB" {
  value = module.network[0].DatabaseSubnetB

}

output "DatabaseSubnetC" {
  value = module.network[0].DatabaseSubnetC
}
##EKS outputs
output "cluster_id" {
  description = "The name/id of the EKS cluster."
  value       = module.eks_control.cluster_id
}

output "cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster."
  value       = module.eks_control.cluster_arn
}

output "cluster_certificate_authority_data" {
  description = "Nested attribute containing certificate-authority-data for your cluster. This is the base64 encoded certificate data required to communicate with your cluster."
  value       = module.eks_control.cluster_certificate_authority_data
}

output "cluster_endpoint" {
  description = "The endpoint for your EKS Kubernetes API."
  value       = module.eks_control.cluster_endpoint
}

output "cluster_version" {
  description = "The Kubernetes server version for the EKS cluster."
  value       = module.eks_control.cluster_version
}
output "aws_updete_kubeconfig" {
  value = "aws eks update-kubeconfig --region <region> --name <cluster_name>"
}
## nodegroup

output "node_group_id" {
  description = "Node Group ID"
  value       = module.eks_public_nodes.node_group_id
}

output "priv_node_group_id" {
  description = "Node Group ID"
  value       = module.eks_private_nodes.node_group_id
}



output "node_group_status" {
  description = "Node Group status"
  value       = module.eks_public_nodes.node_group_status
}
output "private_node_group_status" {
  description = "Node Group status"
  value       = module.eks_private_nodes.node_group_status
}


output "node_group_version" {
  description = "Node Group Kubernetes Version"
  value       = module.eks_public_nodes.node_group_version
}

output "node_group_arn" {
  description = "The node group arn"
  value       = module.eks_public_nodes.node_group_arn

}
output "priv_node_group_arn" {
  description = "The node group arn"
  value       = module.eks_private_nodes.node_group_arn

}

output "eks_nodegroup_role_name" {
  value       = module.eks_control.eks_nodegroup_role_name
  description = "This is important to be used for creation of autoscaler node role"

}

output "eks_nodegroup_role_arn" {
  value       = module.eks_control.eks_nodegroup_role_arn
  description = "Eks nodegroup role arn for node group"

}
output "aws_iam_openid_connect_provider_arn" {
  description = "AWS IAM Open ID Connect Provider ARN"
  value       = module.eks_control.aws_iam_openid_connect_provider_arn
}
output "aws_iam_oidc_connect_provider_exctract_from_arn" {
  value = module.eks_control.aws_iam_oidc_connect_provider_exctract_from_arn
}
output "alb_controller_metadata" {
  value = module.alb-controller.lbc_helm_metadata
}
