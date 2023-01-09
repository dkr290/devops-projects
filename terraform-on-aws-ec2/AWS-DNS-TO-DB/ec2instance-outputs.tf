

# EC2 Bastion outputs
output "ec2_bastion_id" {
  description = "The ID of the instance"
  value       = module.ec2_public.id
}


output "ec2_bastion_public_ip" {
  description = "The public IP address assigned to the instance"
  value       = module.ec2_public.public_ip
}

output "ec2_private_id_app1" {
  description = "The ID of the instance"
  value       = [for instance in module.ec2_private_app1: instance.id]
}
output "ec2_private_id_app2" {
  description = "The ID of the instance"
  value       = [for instance in module.ec2_private_app2: instance.id]
}


output "ec2_private_ip_app1" {
  description = "List of private IP adresses of the instance"
  value       = [for instance in module.ec2_private_app1: instance.private_ip]
}

output "ec2_private_ip_app2" {
  description = "List of private IP adresses of the instance"
  value       = [for instance in module.ec2_private_app2: instance.private_ip]
}


output "app3_primary_network_interface_id" {

    description = "The ID of the instance's primary network interface."
    value = [ for instance in aws_instance.ec2-private-app3: instance.primary_network_interface_id ]
  
}
