data "terraform_remote_state" "example" {
  backend = "gcs"
  config = {
    bucket  = "terraformstate80"
    prefix  = "terraform/state"
  }
}
