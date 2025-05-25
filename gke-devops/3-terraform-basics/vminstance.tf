resource "google_compute_instance" "myapp1" {
  name         = "myapp1"
  machine_type = "e2-micro"
  zone         = "europe-west1-a"

  tags = [google_compute_firewall.fw_ssh.target_tags[0], google_compute_firewall.fw_http.target_tags[0]]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      labels = {
        my_label = "Debian machine"
      }
    }
  }

  // Local SSD disk
  scratch_disk {
    interface = "NVME"
  }

  network_interface {
    subnetwork = google_compute_subnetwork.mysubnet.id

    access_config {
      // Ephemeral public IP
    }
  }

 
  metadata_startup_script =  file("${path.module}/startup-script.sh")

}
