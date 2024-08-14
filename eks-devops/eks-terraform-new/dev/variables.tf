variable "aws_region" {
  description = "AWS region"
  default     = "eu-central-1"
  type        = string
}



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
# Example tfvars
# aws_region         = "eu-central-1"
# vpc_cidr_block     = "10.0.0.0/16"
# PublicA_CIDR       = "10.0.101.0/24"
# PublicB_CIDR       = "10.0.102.0/24"
# PublicC_CIDR       = "10.0.103.0/24"
# WorkersA_cidr      = "10.0.1.0/24"
# WorkersB_cidr      = "10.0.2.0/24"
# WorkersC_cidr      = "10.0.3.0/24"
# DbACIDR            = "10.0.151.0/24"
# DbBCIDR            = "10.0.152.0/24"
# DbCCIDR            = "10.0.153.0/24"
# azA                = "eu-central-1a"
# azB                = "eu-central-1b"
# azC                = "eu-central-1c"
# enable_vpc_network = true
# eks_cluster_name   = "dev_eks_cluster"
# #bastion host related variables
# bastion_instance_type = "t2.micro"
# ssh_keypair           = "eks-tf-key"
# enable_bastion_host   = true
# ingress_from_port     = "22"
# ingress_to_port       = "22"

