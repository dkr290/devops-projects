
locals {
  instance_public_ip = var.instance_type == "spot" ? (length(aws_spot_instance_request.gpu_spot) > 0 ? aws_spot_instance_request.gpu_spot[0].public_ip : "") : (length(aws_instance.gpu_ondemand) > 0 ? aws_instance.gpu_ondemand[0].public_ip : "")
}

