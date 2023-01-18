resource "google_compute_instance" "vm-from-tf" {
  name         = "vm-from-tf"
  machine_type = "e2-small"
  zone         = var.zone

  tags = ["terraform", "vm-instance"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      size = 20
      labels = {
        environment = "Development"
      }
    }
  }



  network_interface {
    network = "default"

    access_config {
      // Ephemeral public IP
    }
  }

 
 # metadata_startup_script = "echo hi > /test.txt"

 
}