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

## EKS cluster variables 
variable "cluster_service_ipv4_cidr" {
  description = "service ipv4 cidr for the kubernetes cluster"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes minor version to use for the EKS cluster (for example 1.21)"
  type        = string
}
variable "cluster_endpoint_private_access" {
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled."
  type        = bool
}

variable "cluster_endpoint_public_access" {
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled. When it's set to `false` ensure to have a proper private access with `cluster_endpoint_private_access = true`."
  type        = bool
}
variable "cluster_endpoint_public_access_cidrs" {
  description = "List of CIDR blocks which can access the Amazon EKS public API server endpoint."
  type        = list(string)
}
variable "environment" {
  description = "The environment"
}

variable "node_group_name" {
  description = "The node group name"
  type        = string

}
variable "addons" {
  type = list(object({
    name    = string
    version = string
  }))
}
variable "max_size" {
  description = "The maximum number of instances in the node group"
  type        = number
}

variable "min_size" {
  description = "The minimum number of instances in the node group"
  type        = number
}
variable "desired_size" {
  description = "The desired number of instances in the node group"
  type        = number
}


# Example tfvars
# aws_region         = "eu-north-1"
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
# azA                = "us-east-2a"
# azB                = "us-east-2b"
# azC                = "us-east-2c"
# enable_vpc_network = true
# eks_cluster_name   = "dev_eks_cluster"
# #bastion host related variables
# bastion_instance_type = "t2.micro"
# ssh_keypair           = "eks-tf-key"
# enable_bastion_host   = true
# ingress_from_port     = "22"
# ingress_to_port       = "22"
# #Eks variables
# cluster_version                      = "1.29"
# cluster_service_ipv4_cidr            = "172.20.0.0/16"
# cluster_endpoint_private_access      = false
# cluster_endpoint_public_access       = true
# cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]
# environment                          = "dev"
# node_group_name                      = "default-ng"
# desired_size                         = 2
# min_size                             = 2
# max_size                             = 6
# addons = [
#   {
#     name    = "kube-proxy"
#     version = "v1.29.3-eksbuild.2"
#   },
#   {
#     name    = "vpc-cni"
#     version = "v1.18.3-eksbuild.1"
#   },
#   {
#     name    = "coredns"
#     version = "v1.11.1-eksbuild.9"
#   }
#   # {
#   #   name    = "aws-ebs-csi-driver"
#   #   version = "v1.33.0-eksbuild.1"
#   # },
#   # {
#   #   name    = "aws-efs-csi-driver"
#   #   version = "v2.0.6-eksbuild.1"
#   # }
#
# ]
#
