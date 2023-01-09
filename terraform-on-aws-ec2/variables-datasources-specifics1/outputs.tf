# Output - For loop with list

output "for_output_list" {
    
    value = [for instance in aws_instance.myec2vm: instance.public_dns]
    description = "for loop with list"
}

# Output - For loop with map

output "for_output_map" {
    value = { for instance in aws_instance.myec2vm: instance.id => instance.public_dns }
    description = "For loop with map"
}

# Output - For loop advanced


output "for_loop_map2" {
    value = {for c, instance in aws_instance.myec2vm: c => instance.public_dns}
    description = "for loop with map advanced"
}


# outpuit legacy splat operator

output "legacy_splat_instance_publicdns" {

    value = aws_instance.myec2vm.*.public_dns
  
}

output "latest_splat_instance_publicdns" {

    value = aws_instance.myec2vm[*].public_dns
  
}