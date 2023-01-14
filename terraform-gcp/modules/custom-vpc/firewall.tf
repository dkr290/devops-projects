resource "google_compute_firewall" "allow-gke" {
  name    = "allow-gke"
  network = google_compute_network.custom_vpc_network.id

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["80", "443", "1024-65535"]

  }

  source_tags = ["kubernetes"]
  #source_ranges = [ "value" ]
  priority = 500

}

