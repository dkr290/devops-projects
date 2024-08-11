output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}
output "route_table_id" {
  value       = aws_vpc.main.default_route_table_id
  description = "The generated route table"
}

output "tenancy" {
  value       = aws_vpc.main.instance_tenancy
  description = "The default tenancy"
}

output "dhcp_options_id" {
  value       = aws_vpc.main.dhcp_options_id
  description = "The default dhcp_options_id"
}

output "default_security_group_id" {
  value       = aws_vpc.main.default_security_group_id
  description = "The default security group id"
}

output "publicSubnetA" {
  value = aws_subnet.public["publicA"].id
}

output "publicSubnetB" {
  value = aws_subnet.public["publicB"].id
}

output "publicSubnetC" {
  value = aws_subnet.public["publicC"].id
}
output "WorkersSubnetA" {
  value = aws_subnet.workers["WorkerA"].id
}
output "WorkersSubnetB" {
  value = aws_subnet.workers["WorkerB"].id
}
output "WorkersSubnetC" {
  value = aws_subnet.workers["WorkerC"].id
}

output "DatabaseSubnetsA" {
  value = aws_subnet.privateDb["DbA"].id

}

output "DatabaseSubnetB" {
  value = aws_subnet.privateDb["DbB"].id

}
output "DatabaseSubnetC" {
  value = aws_subnet.privateDb["DbC"].id

}
