resource "google_compute_firewall" "fw_ssh" {
  name    = "fw-allow-ssh22"
  network = google_compute_network.myvpc.id

  

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  direction = "INGRESS"
  priority = 1000
  source_ranges =["0.0.0.0/0"]


  target_tags = ["ssh-tag"]
}
resource "google_compute_firewall" "fw_http" {
  name    = "fw-allow-http80"
  network = google_compute_network.myvpc.id

  

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  direction = "INGRESS"
  priority = 1001
  source_ranges =["0.0.0.0/0"]


  target_tags = ["webserver-tag"]
}

