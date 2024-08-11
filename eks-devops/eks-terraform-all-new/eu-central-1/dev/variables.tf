variable "aws_region" {
  description = "AWS region"
  default     = "eu-central-1"
  type        = string
}

variable "vpc_cidr_block" {
  description = "the vpc cidr block"
  type        = string
}
variable "enable_vpc_network" {
  description = "Whether to create or not VPC or enable or disable the module"

}

variable "PublicA_CIDR" {
  description = "publicSubnetA CIDR"
}
variable "PublicB_CIDR" {
  description = "publicSubnetB CIDR"
}
variable "PublicC_CIDR" {
  description = "publicSubnetC CIDR"
}
variable "WorkersA_cidr" {
  description = "workers A CIDR"
}
variable "WorkersB_cidr" {
  description = "Cidr for Workers B"
}

variable "WorkersC_cidr" {
  description = "Workers C cidr"
}
variable "DbACIDR" {
  description = "Cidr range for db A"
}
variable "DbBCIDR" {
  description = "cidr for db A"
}
variable "DbCCIDR" {
  description = "Cidr for workers B"
}
variable "azA" {
  description = "az for  A subnet"
}

variable "azB" {
  description = "az for  B subnet"
}

variable "azC" {
  description = "az for  C subnet"
}
variable "common_tags" {
  type = map(string)
  default = {
    "organization" = "MyOrg"
    "environment"  = "dev"
  }
}
variable "eks_cluster_name" {
  description = "The eks cluster name"

}
