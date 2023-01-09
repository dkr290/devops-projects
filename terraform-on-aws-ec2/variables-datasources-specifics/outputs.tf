output "instance_public_ip" {
  value       = aws_instance.myec2vm.public_ip
  description = "EC2 instance public ip"
}

output "instance_dns" {
  value       = aws_instance.myec2vm.public_dns
  description = "EC2 public DNS"
}