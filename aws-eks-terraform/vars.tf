
variable "aws_region" {
  description = "The region where the resources will be created"
  type        = string
  default     = "eu-central-1"

}

variable "environment" {
    description = "This is the default envirenment"
    default = "dev"
  
}



variable "cluster_name" {
   default =  "demo-eks-cluster01"

}

variable "kubernetes_version" {
  default = "1.21"
}

variable "vpc_name" {
  description = "VPC Name"
  type = string 
  default = "my-VPC"
}

# VPC CIDR Block
variable "vpc_cidr_block" {
  description = "VPC cidr block"
  type = string
  default = "10.0.0.0/16"
}

# VPC Availability Zones
variable "vpc_availability_zones" {
  description = "VPC Availability Zones"
  type = list(string)
  default = ["eu-central-1a", "eu-central-1b"]
}

# VPC Public Subnets
variable "vpc_public_subnets" {
  description = "VPC Public Subnets"
  type = list(string)
  default = ["10.0.101.0/24", "10.0.102.0/24"]
}

# VPC Private Subnets
variable "vpc_private_subnets" {
  description = "VPC Private Subnets"
  type = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}


# The DB subnets
variable "vpc_database_subnets" {
    description = "VPC Database subnets"
    type = list(string)
    default = [ "10.0.251.0/24", "10.0.252.0/24" ]
}


# VPC Create Database Subnet Group (True / False)
variable "vpc_create_database_subnet_group" {
  description = "VPC Create Database Subnet Group"
  type = bool
  default = true 
}

# VPC Create Database Subnet Route Table (True or False)
variable "vpc_create_database_subnet_route_table" {
  description = "VPC Create Database Subnet Route Table"
  type = bool
  default = true   
}

  
# VPC Enable NAT Gateway (True or False) 
variable "vpc_enable_nat_gateway" {
  description = "Enable NAT Gateways for Private Subnets Outbound Communication"
  type = bool
  default = true  
}

# VPC Single NAT Gateway (True or False)
variable "vpc_single_nat_gateway" {
  description = "Enable only single NAT Gateway in one Availability Zone to save costs during our demos"
  type = bool
  default = true
}