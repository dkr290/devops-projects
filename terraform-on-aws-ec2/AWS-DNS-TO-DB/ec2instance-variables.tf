# EC2 ionstance type
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"


}


variable "private_key_file" {

  default =  "ec2testkey4.pem"
  
}




#AWS EC2 instnace keypair

variable "inst_keypair" {
  type        = string
  default     = "ec2testkey4"
  description = "AWS EC2 Key Pair"

}




