#installing important addons by default
# aws eks describe-addon-versions 
variable "addons" {
  type = list(object({
    name    = string
    version = string
  }))

}
variable "cluster_id" {
  description = "The EKS cluster id"

}

