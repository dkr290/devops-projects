output "security_group_bastion_id" {
    value = aws_security_group.public_bastion_sg.id
    description = "The ID of the security group"
}

output "security_group_bastion_name" {
    description = "The name of the private security group"
    value = aws_security_group.public_bastion_sg.name
}

output "security_group_bastion_vpc_id" {
     description = "The VPC ID"
    value = aws_security_group.public_bastion_sg.vpc_id
}



output "security_group_privatesg_id" {
    description = "The ID of the security group"
    value = aws_security_group.private_sg.id
}
output "security_group_privatesg_vpc_id" {
    value = aws_security_group.private_sg.vpc_id
    description = "The VPC ID"
}

output "security_group_privatesg_name" {
    value = aws_security_group.private_sg.name
    description = "The name of the private security group"
}

