output "BastionSecurityGroupID" {
  value = aws_security_group.BastionSG.id
}

output "BastionSecurityGroupArn" {
  value = aws_security_group.BastionSG.arn
}
output "bastion_host_ids" {
  description = "IDs of the Bastion Hosts"
  value       = [for instance in aws_instance.BastionHost : instance.id]
}

output "private_key_path" {
  description = "Path to the private key file"
  value       = local_file.private_key.filename
}
