variable "key_pair_name" {
  type        = string
  description = "key pair name"
}
variable "publicSubnetA" {
  type = object({
    subnet_id = string
    bastionSG = string
    tags      = map(string)
  })
}
variable "publicSubnetB" {
  type = object({
    subnet_id = string
    bastionSG = string
    tags      = map(string)
  })
}

variable "publicSubnetC" {
  type = object({
    subnet_id = string
    bastionSG = string
    tags      = map(string)
  })
}
variable "appSubnetA" {
  type = object({
    subnet_id = string
    AppSG     = string
    tags      = map(string)
  })
}


variable "appSubnetB" {
  type = object({
    subnet_id = string
    AppSG     = string
    tags      = map(string)
  })
}
variable "appSubnetC" {
  type = object({
    subnet_id = string
    AppSG     = string
    tags      = map(string)
  })
}

