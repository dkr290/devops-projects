output "secondary_subnets" {
    value = [for sec_subnet_name, subnet in var.subnet_names: subnet]
}