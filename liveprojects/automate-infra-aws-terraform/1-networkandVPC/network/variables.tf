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
variable "AppA" {
  type = object({
    cidr_block = string
    az         = string
    tags       = map(string)
  })


}
variable "AppB" {
  type = object({
    cidr_block = string
    az         = string
    tags       = map(string)
  })


}
variable "AppC" {
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
variable "natEipB" {
  type = object({
    domain = string
  })


}
variable "natEipC" {
  type = object({
    domain = string
  })


}
