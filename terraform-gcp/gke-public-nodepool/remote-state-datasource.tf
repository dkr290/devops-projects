data "terraform_remote_state" "gke-cluster"{
    backend = "gcp"
    config = {
         bucket  = "terraformstate80"
         prefix  = "terraform/gke"
   
    }
}