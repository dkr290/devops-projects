variable "resource_group_name" {
  default     = "test-rg"
  description = "The name of an existing Resource Group"
}

variable "linuxvm_name"{
    default="scaleset-servers"
}

# Environment Variable
variable "environment" {
  description = "Environment Variable used as a prefix"
  type = string
  default = "dev"
}
# Azure Resources Location
variable "resource_group_location" {
  description = "Region in which Azure Resources to be created"
  type = string
  default = "northeurope"  
}

variable "application" {
  description = "The applicatiuon for the tags"
  type = string
  default = "Build Server"  
}

variable "technical_owner" {
  description = "The technical Owner"
  type = string
  default = "Some Technical owner"  
}

# variable "subscription" {
#   type        = string
#   description = "Our Subscription ID in tfvars file"
#   default = "Subscr-id-xxxxxxxxxx"             
# }

# variable "tenant" {
#   type        = string
#   description = "Our Tenant ID it cn be replaced in tfvars file"
#   default = "tenant-id-xxxxxxxx" 
# }


variable "numberOfWorkerNodes" {
  type        = number
  default     = 1
  description = "The default number of nodes to provision in the scaleset, after joining scaleset as an agent pool, ADO takes over and manages this number."
}



variable "deployment_prefix" {
  default     = "build-dev-servers"
  description = "prefix for resource"
}