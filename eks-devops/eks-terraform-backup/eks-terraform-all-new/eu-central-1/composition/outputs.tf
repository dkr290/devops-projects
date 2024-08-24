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


output "DatabaseSubnetsA" {
  value = module.network[0].DatabaseSubnetsA

}

output "DatabaseSubnetB" {
  value = module.network[0].DatabaseSubnetB

}

output "DatabaseSubnetC" {
  value = module.network[0].DatabaseSubnetC
}
output "BastionSecurityGroupID" {
  value = module.bastionhost[0].BastionSecurityGroupID
}


output "bastion_host_ids" {
  description = "IDs of the Bastion Hosts"
  value       = module.bastionhost[0].bastion_host_ids
}

output "private_key_path" {
  description = "Path to the private key file"
  value       = module.bastionhost[0].private_key_path
}
