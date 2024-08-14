variable "bastion_instancew_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
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
