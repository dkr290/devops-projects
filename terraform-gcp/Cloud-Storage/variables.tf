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
variable "uniform_bucket_level_access" {}

variable "storage_class" {
  type = bool
  description = "The storage class for the bucket"
  default = true
}