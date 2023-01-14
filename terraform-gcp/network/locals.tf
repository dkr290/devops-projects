locals {
    subnets = {
        gke_nodepools = {
          name = "gke-nodepools"
          cidr = "10.151.0.0/23"
          region = "europe-north1"
          private_ip_google_access = true



        }
          gke-linux-hosts = {
            name = "gke-linux-hosts"
            cidr = "10.151.10.0/24"
            region = "europe-north1"
            private_ip_google_access = true



          }
          gke-windows-hosts = {
            name          = "gke-windows-hosts"
            cidr          = "10.151.11.0/24"
            region        = "europe-north1"
            private_ip_google_access = true
          }

          gke-private-links = {
               name          = "gke-private-links"
               cidr          = "10.151.12.0/24"
               region        = "europe-north1"
               private_ip_google_access = true
          }
    }
}