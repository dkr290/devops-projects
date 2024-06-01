
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.eks_vpc.id
}

output "vpc_arn" {
  description = "The ARN of the VPC"
  value       = aws_vpc.eks_vpc.arn
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.eks_vpc.cidr_block
}

output "default_security_group_id" {
  description = "The ID of the default security group"
  value       = aws_vpc.eks_vpc.default_security_group_id
}

output "default_network_acl_id" {
  description = "The ID of the default network ACL"
  value       = aws_vpc.eks_vpc.default_network_acl_id
}

output "default_route_table_id" {
  description = "The ID of the default route table"
  value       = aws_vpc.eks_vpc.default_route_table_id
}
output "public_subnet_ids" {

  value = aws_subnet.public[*].id

}
output "private_subnet_ids" {

  value = aws_subnet.private[*].id

}


