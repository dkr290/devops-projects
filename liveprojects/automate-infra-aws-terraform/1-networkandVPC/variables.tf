variable "region" {
  description = "AWS region"
  default     = "eu-central-1"
  type        = string
}
variable "ssh_keypair" {
  description = "optional ssh keypair to use for EC2 instance"
  default     = null #B
  type        = string
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
variable "AppACIDR" {
  description = "app A CIDR"
}
variable "AppBCIDR" {

}

variable "AppCCIDR" {

}
variable "DbACIDR" {
  description = "Cidr range for db A"
}
variable "DbBCIDR" {

}
variable "DbCCIDR" {

}
