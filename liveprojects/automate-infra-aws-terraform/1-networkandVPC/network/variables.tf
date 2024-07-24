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
