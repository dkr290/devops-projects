## module variables for creation of VPC
variable "enable_vpc_network" {

  description = "Whether this module to be enabled"
}
variable "vpc_cidr_block" {
  description = "the vpc cidr block"
  type        = string
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
  description = "az for  B subnet"
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
##bastion host module variables
variable "enable_bastion_host" {

  description = "Whether this module to be enabled"
}
variable "bastion_instancew_type" {
  description = "EC2 instance type"
  type        = string
}
variable "ssh_keypair" {
  description = "optional ssh keypair to use for EC2 instance"
  default     = null #B
  type        = string
}
variable "vpc_id" {
  description = "The VPC id"

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
