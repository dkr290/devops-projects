variable "vpc_name" {
  default = "eks_vpc"
}
variable "vpc_cidr_block" {

}

variable "publicA" {
  type = object({
    cidr_block = string
    az         = string
    tags       = map(string)
  })
}
variable "publicB" {
  type = object({
    cidr_block = string
    az         = string
    tags       = map(string)
  })


}
variable "publicC" {
  type = object({
    cidr_block = string
    az         = string
    tags       = map(string)
  })


}
variable "WorkerA" {
  type = object({
    cidr_block = string
    az         = string
    tags       = map(string)
  })


}
variable "WorkerB" {
  type = object({
    cidr_block = string
    az         = string
    tags       = map(string)
  })


}
variable "WorkerC" {
  type = object({
    cidr_block = string
    az         = string
    tags       = map(string)
  })


}
variable "DbA" {
  type = object({
    cidr_block = string
    az         = string
    tags       = map(string)
  })


}
variable "DbB" {
  type = object({
    cidr_block = string
    az         = string
    tags       = map(string)
  })


}
variable "DbC" {
  type = object({
    cidr_block = string
    az         = string
    tags       = map(string)
  })


}
variable "natEipA" {
  type = object({
    domain = string
  })


}

