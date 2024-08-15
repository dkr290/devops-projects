#installing important addons by default
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
  description = "Name of the EKS cluster. Also used as a prefix in names of related resources."
  type        = string
}
variable "cluster_id" {
  description = "The EKS cluster id"

}
variable "node_group_name" {
  description = "The node group name"
  type        = string

}
variable "environment" {
  description = "The environment"
}
variable "subnet_ids" {
  description = "List of subnet IDs for the VPC"
  type        = list(string)
}
variable "cluster_version" {
  description = "The version of the EKS cluster"
  type        = string
  default     = "" # Default to an empty string if not provided
}
variable "desired_size" {
  description = "The desired number of instances in the node group"
  type        = number
  default     = 1 # Default desired size
}

variable "max_size" {
  description = "The maximum number of instances in the node group"
  type        = number
  default     = 3 # Default maximum size
}

variable "min_size" {
  description = "The minimum number of instances in the node group"
  type        = number
  default     = 1 # Default minimum size
}
variable "ami_type" {
  description = "The ami type"
  type        = string
  default     = "AL2_x86_64"
}
variable "capacity_type" {
  description = "Choosing between ON_DEMAND or SPOT"
  type        = string
  default     = "ON_DEMAND"

}
variable "instance_types" {
  description = "Instance types list"
  type        = list(string)
  default     = ["t2.small"]


}
variable "disk_size" {
  description = "The disk size for the instances"
  type        = string
  default     = "20"

}
variable "ec2_ssh_key" {
  description = "The ssh key for connection to the nodes"
  type        = string

}
variable "update_max_unavailable" {
  description = "Max unavailable by updates of EKS nodes"
  type        = string
  default     = "1"

}
variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default = {
    Name = "EKS nodegroup" # Default tag value
  }
}
