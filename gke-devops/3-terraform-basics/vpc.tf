resource "google_compute_network" "myvpc" {
  name                    = "vpc1"
  auto_create_subnetworks = false


}


// subnet resources 


resource "google_compute_subnetwork" "mysubnet" {
  name          = "my-subnet-1"
  region        = "europe-west1"
  ip_cidr_range = "10.128.0.0/28"
  network       = google_compute_network.myvpc.id

}
