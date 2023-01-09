variable "db_name" {
    description = "AWS RDS Database name"
    type = string
  
}

variable "db_instance_identifier" {
  description = "AWS RDS Database Instance Identifier"
  type = string
}

variable "db_username" {
  description = "AWS RDS Database Administrator Username"
  type = string
}

variable "db_password" {
    description = "AWS RDS Database Administrator Password"
    type = string
    sensitive = true
  
}