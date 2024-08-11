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
#Bastion host variables
variable "enable_bastion_host" {
  description = "Enable or disable bastion host module"
}
variable "bastion_instance_type" {
  description = "EC2 instance type"
  type        = string
}
variable "ssh_keypair" {
  description = "optional ssh keypair to use for EC2 instance"
  default     = null #B
  type        = string
}
variable "ingress_from_port" {
  description = "The from port for Ingress of bastion host"
}
variable "ingress_to_port" {
  description = "the ingress to port of bastion host"
}
variable "public_subnets" {
  description = "List of public subnets"
  type = map(object({
    subnet_id = string
    tags      = map(string)
  }))
}
variable "common_tags" {
  type = map(string)
  default = {
    "organization" = "MyOrg"
    "environment"  = "dev"
  }
}

