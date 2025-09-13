output "vm_instanceid" {
  description = "VM instance ID"
  value       = [for instance in google_compute_instance.myapp1 : instance.id]

}


# output "vm_external_ip" {
#
#   value = google_compute_instance.myapp1.network_interface[0].access_config[0].nat_ip
# }

output "vm_name" {
  value = [for instance in google_compute_instance.myapp1 : instance.name]

}


output "for_output_map" {

  value = { for instance in google_compute_instance.myapp1 : instance.name => instance.instance_id }
}

output "for_output_map2" {

  value = { for c, instance in google_compute_instance.myapp1 : c => instance.instance_id }
}
output "for_output_map3" {

  value = { for c, instance in google_compute_instance.myapp1 : instance.name => instance.instance_id }
}


output "for_legacy" {

  value = google_compute_instance.myapp1[*].name

}



# output "vm_machine_type" {
#   value = google_compute_instance.myapp1.machine_type
#
# }


