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
}

variable "labels" {
  type = map
  description = "The labels for the bucket"
  
}
variable "uniform_bucket_level_access" {}

variable "storage_class" {
  type = string
  description = "The storage class for the bucket"
  
}
variable "bucket_object_name"{}
variable "image_source" {}
