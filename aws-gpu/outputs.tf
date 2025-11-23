
# Outputs


output "instance_type" {
  value = var.instance_type
}
output "cost_estimate" {
  value = var.instance_type == "spot" ? "Spot instance: ~$0.35-0.40/hour" : "On-demand instance: ~$1.20/hour"
}

output "deep_learning_ami_info" {
  value = "Using Deep Learning AMI: ${data.aws_ami.ubuntu.name}"
}
