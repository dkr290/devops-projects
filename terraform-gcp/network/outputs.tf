output "custom_vpc_id" {
    value =  module.custom-vpc.custom_vpc_id
}

output "custom_vpc_name" {
    value = module.custom-vpc.custom_vpc_name
}

output "auto_vpc_id" {
    value = google_compute_network.auto_vpc_network.id
}