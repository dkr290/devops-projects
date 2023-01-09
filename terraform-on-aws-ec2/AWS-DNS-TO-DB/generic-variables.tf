
variable "aws_region" {
  description = "The region where the resources will be created"
  type        = string
  default     = "eu-central-1"

}

variable "environment" {
    description = "This is the default envirenment"
    default = "dev"
  
}


variable "business_divsion" {
  description = "Business Division in the large organization this Infrastructure belongs"
  type = string
  default = "SAP"
}