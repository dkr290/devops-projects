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

variable "bucket_name" {
type = string
description = "Bucket name" 
default = "daninewstorageaccount80" 
}

variable "labels" {
  type = map
  description = "The labels for the bucket"
  default = {
    "env" = "development",
    "type"= "standart",
  }
  
}
variable "uniform_bucket_level_access" {
  type = bool
  description = "The bucket level acess true or false"
  default = false
}

variable "storage_class" {
  type = string
  description = "The storage class for the bucket"
  default = "STANDARD"
}