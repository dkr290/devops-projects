# Output - For loop with list



output "instance_publicip" {
    value = [for instance in aws_instance.myec2vm: instance.public_ip]
    description = "The instance public ip address"
}


output "for_output_list" {
    
    value = [for instance in aws_instance.myec2vm: instance.public_dns]
    description = "for loop with list"
}

# Output - For loop map


output "instance_publicdns2" {
    value = {for az, instance in aws_instance.myec2vm: az => instance.public_dns}
    description = "for loop with map advanced"
}
