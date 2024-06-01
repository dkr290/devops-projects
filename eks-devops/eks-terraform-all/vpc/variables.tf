variable "aws_region" {
  description = "the region"
  default     = "eu-central-1"

}

variable "vpc_cidr_block" {
  description = "The cidr block for vpc 10.0.0.0/16"
  default     = "10.0.0.0/16"
}
variable "cluster_name" {

  description = "The eks cluster name"
  default     = "eks-cluster"
}

