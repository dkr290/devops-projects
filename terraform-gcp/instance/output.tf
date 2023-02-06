output "all_instances" {
    value = values(google_compute_instance.vm-from-tf[*]).hostname
    
}