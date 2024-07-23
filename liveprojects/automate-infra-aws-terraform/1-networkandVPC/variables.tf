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
