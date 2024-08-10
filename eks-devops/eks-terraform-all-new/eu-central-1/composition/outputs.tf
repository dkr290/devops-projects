output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.network[0].vpc_id
}
output "route_table_id" {
  value       = module.network[0].route_table_id
  description = "The generated route table"
}

output "tenancy" {
  value       = module.network[0].tenancy
  description = "The default tenancy"
}

output "dhcp_options_id" {
  value       = module.network[0].dhcp_options_id
  description = "The default dhcp_options_id"
}

output "default_security_group_id" {
  value       = module.network[0].default_security_group_id
  description = "The default security group id"
}

output "publicSubnetA" {
  value = module.network[0].publicSubnetA
}

output "publicSubnetB" {
  value = module.network[0].publicSubnetB
}

output "publicSubnetC" {
  value = module.network[0].publicSubnetC
}
output "WorkersSubnetA" {
  value = module.network[0].WorkersSubnetA
}
output "WorkersSubnetB" {
  value = module.network[0].WorkersSubnetB
}
output "WorkersSubnetC" {
  value = module.network[0].WorkersSubnetC
}


