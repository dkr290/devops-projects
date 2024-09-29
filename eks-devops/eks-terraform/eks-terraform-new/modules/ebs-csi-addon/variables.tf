
variable "cluster_id" {
  description = "The EKS cluster id"

}

variable "iam_policy" {
  type        = string
  default     = "https://raw.githubusercontent.com/kubernetes-sigs/aws-ebs-csi-driver/master/docs/example-iam-policy.json"
  description = "Iam policy for EFS from github for the EFS csi driver , change if nessesairy"

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
variable "addon_name" {
  description = "the addon name"
  default     = "aws-ebs-csi-driver"
}
variable "addon_version" {
  description = "The addon version"
}
