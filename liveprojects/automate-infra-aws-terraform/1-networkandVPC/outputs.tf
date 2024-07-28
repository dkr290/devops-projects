output "vpc_id" {
  value       = module.network.vpc_id
  description = "The generated vpc id"
}
output "route_table_id" {
  value       = module.network.route_table_id
  description = "The generated route table"
}

output "tenancy" {
  value       = module.network.tenancy
  description = "The default tenancy"
}

output "dhcp_options_id" {
  value       = module.network.dhcp_options_id
  description = "The default dhcp_options_id"
}

output "default_security_group_id" {
  value       = module.network.default_security_group_id
  description = "The default security group id"
}

output "publicSubnetA" {
  value = module.network.publicSubnetA
}

output "publicSubnetB" {
  value = module.network.publicSubnetB
}

output "publicSubnetC" {
  value = module.network.publicSubnetC
}


