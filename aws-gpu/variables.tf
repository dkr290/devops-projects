variable "key_name" {
  description = "Name of your AWS key pair"
  type        = string
  default     = "gpu-vm-ssh" # Set your key name here
}

variable "instance_type" {
  description = "Type of instance to create: 'spot' or 'ondemand'"
  type        = string
}

variable "spot_max_price" {
  description = "Maximum spot price you're willing to pay"
  type        = string
  default     = "" # Leave empty for on-demand price
}

variable "ssh_inbound" {
  description = "Allow only for certain IP"
  type        = list(string)

}
