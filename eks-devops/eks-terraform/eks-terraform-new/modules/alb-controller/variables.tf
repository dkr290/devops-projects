variable "aws_region" {
  description = "AWS region"
  type        = string
}

# Environment Variable
variable "environment" {
  description = "Environment Variable used as a prefix"
  type        = string
}
# Business Division
variable "business_divsion" {
  description = "Business Division in the large organization this Infrastructure belongs"
  type        = string
}
variable "eks_cluster" {
  type        = string
  description = "Eks cluster name"

}
variable "aws_iam_openid_connect_provider_arn" {
  description = "Tis value with the same name should be passed from eks module"
  type        = string
}
variable "aws_iam_openid_connect_provider_extract_from_arn" {
  description = "This also is related to openid and should be passed from eks module"
  type        = string

}
variable "eks_endpoint" {
  type        = string
  description = "Eks cluster endpoint like aws_eks_cluster.eks.endpoint"
}
variable "eks_certificate_authority_data" {
  type        = string
  description = "Eks certificate authority data"
}
variable "vpc_id" {
  description = "The vpc id"


}

variable "eks_cluster_id" {
  description = "the eks cluster id"

}

variable "image_repo" {
  description = "The image repo depending on the region"
  default     = "602401143452.dkr.ecr.us-east-1.amazonaws.com/amazon/aws-load-balancer-controller"

}
