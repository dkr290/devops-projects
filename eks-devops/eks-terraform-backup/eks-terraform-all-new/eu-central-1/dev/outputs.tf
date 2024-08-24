output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.composition.vpc_id
}
output "route_table_id" {
  value       = module.composition.route_table_id
  description = "The generated route table"
}

output "tenancy" {
  value       = module.composition.tenancy
  description = "The default tenancy"
}

output "dhcp_options_id" {
  value       = module.composition.dhcp_options_id
  description = "The default dhcp_options_id"
}

output "default_security_group_id" {
  value       = module.composition.default_security_group_id
  description = "The default security group id"
}

output "publicSubnetA" {
  value = module.composition.publicSubnetA
}

output "publicSubnetB" {
  value = module.composition.publicSubnetB
}

output "publicSubnetC" {
  value = module.composition.publicSubnetC
}
output "WorkersSubnetA" {
  value = module.composition.WorkersSubnetA
}
output "WorkersSubnetB" {
  value = module.composition.WorkersSubnetB
}
output "WorkersSubnetC" {
  value = module.composition.WorkersSubnetC
}


output "DatabaseSubnetsA" {
  value = module.composition.DatabaseSubnetsA

}

output "DatabaseSubnetB" {
  value = module.composition.DatabaseSubnetB

}

output "DatabaseSubnetC" {
  value = module.composition.DatabaseSubnetC
}
output "BastionSecurityGroupID" {
  value = module.composition.BastionSecurityGroupID
}


output "bastion_host_ids" {
  description = "IDs of the Bastion Hosts"
  value       = module.composition.bastion_host_ids
}

output "private_key_path" {
  description = "Path to the private key file"
  value       = module.composition.private_key_path
}
