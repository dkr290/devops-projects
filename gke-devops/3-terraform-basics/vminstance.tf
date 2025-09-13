resource "google_compute_instance" "myapp1" {
  count        = 2
  name         = "myapp1-${count.index}"
  machine_type = var.machine_type
  zone         = "europe-west1-b"

  tags = concat(tolist(google_compute_firewall.fw_ssh.target_tags), tolist(google_compute_firewall.fw_http.target_tags))

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      labels = {
        my_label = "debian_machine"
      }
    }
  }


  network_interface {
    subnetwork = google_compute_subnetwork.mysubnet1.id

    access_config {
      // Ephemeral public IP
    }
  }


  metadata_startup_script = file("${path.module}/startup-script.sh")

}
