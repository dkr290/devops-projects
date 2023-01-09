variable "aws_region" {
  description = "The region where the resources will be created"
  type        = string
  default     = "eu-central-1"



}

# EC2 ionstance type
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"


}

#AWS EC2 instnace keypair

variable "inst_keypair" {
  type        = string
  default     = "ec2testkey"
  description = "AWS EC2 Key Pair"

}

# AWS EC2 instance type list

variable "instance_type_list" {
  description = "EC2 instance type list"
  type = list(string)
  default = [ "t3.micro","t3.small" ]

  
}


# AWS instance type map

variable "instance_type_map" {
  description = "EC2 instance type map"
  type = map(string)
  default = {
    "dev" = "t3.micro"
    "qa"  = "t3.small"
    "prod" = "t3.large"
  }

  
}