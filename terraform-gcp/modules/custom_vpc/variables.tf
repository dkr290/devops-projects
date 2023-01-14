variable "custom_vpc_name" {}
variable "subnets" {}
variable "project_id" {

    type = string
    description = "The project id"
  
}

variable "zone" {
  
  type = string
  description = "The location"
}

variable "region" {
  
  type = string
  description = "Region"
 
}