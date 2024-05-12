# aws eks describe-addon-versions 
variable "addons" {
  type = list(object({
    name    = string
    version = string
  }))

  default = [
    {
      name    = "kube-proxy"
      version = "v1.29.3-eksbuild.2"
    },
    {
      name    = "vpc-cni"
      version = "v1.18.1-eksbuild.1"
    },
    {
      name    = "coredns"
      version = "v1.11.1-eksbuild.9"
    },
    {
      name    = "aws-ebs-csi-driver"
      version = "v1.30.0-eksbuild.1"
    },
    {
      name    = "aws-efs-csi-driver"
      version = "v2.0.1-eksbuild.1"
    }

  ]
}
variable "cluster_name" {

  description = "The eks cluster name"
}
variable "aws_region" {
  description = "the region"

}
