data "terraform_remote_state" "gke-cluster"{
    backend = "gcs"
    config = {
         bucket  = "terraformstate80"
         prefix  = "terraform/gke"
   
    }
}