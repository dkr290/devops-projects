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