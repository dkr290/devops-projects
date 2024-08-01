output "BastionSG" {
  value       = aws_security_group.BastionSG.id
  description = "The generated security group id"
}
output "AppSG" {
  value       = aws_security_group.AppSG.id
  description = "The generated security group id"
}
