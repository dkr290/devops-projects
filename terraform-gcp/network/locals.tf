locals {
    subnets {
  gke_nodepools{
    name = "gke-nodepools"
    cidr = "10.151.0.0/23"
    region = "europe-north1"



  }
  gke-linux-hosts{
    name = "gke-linux-hosts"
    cidr = "10.151.10.0/24"
    region = "europe-north1"



  }
    }
}