
# Outputs
output "public_ip" {
  value = local.instance_public_ip
}

output "ssh_command" {
  value = "ssh -i ~/.ssh/${var.key_name}.pem ubuntu@${local.instance_public_ip}"
}

output "jupyter_url" {
  value = "http://${local.instance_public_ip}:8888"
}

output "instance_type" {
  value = var.instance_type
}
output "cost_estimate" {
  value = var.instance_type == "spot" ? "Spot instance: ~$0.35-0.40/hour" : "On-demand instance: ~$1.20/hour"
}

output "deep_learning_ami_info" {
  value = "Using Deep Learning AMI: ${data.aws_ami.gpu_ami.name}"
}
