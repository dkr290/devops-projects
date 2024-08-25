variable "eks_nodegroup_role_name" {
  type        = string
  description = "The eks_nodegroup role name needs to be passed fropm the module eks from the root"
}
variable "cluster_oidc_issuer_url" {
  type        = string
  description = "Oidc issuer url"

}
variable "aws_iam_openid_connect_provider" {
  type        = string
  description = "Openid connect provider"
}
variable "eks_cluster" {
  type        = string
  description = "Eks cluster name"

}
variable "eks_endpoint" {
  type        = string
  description = "Eks cluster endpoint like aws_eks_cluster.eks.endpoint"
}


variable "eks_certificate_authority_data" {
  type        = string
  description = "Eks certificate authority data"
}
variable "aws_region" {

  type        = string
  description = "Aws Region"
}

variable "cluster_id" {
  type        = string
  description = "Cluster id "
}
