output "custom_vpc_id" {
    value = google_compute_network.custom_vpc_network.id
}

output "custom_vpc_name" {
    value = google_compute_network.custom_vpc_network.name
}